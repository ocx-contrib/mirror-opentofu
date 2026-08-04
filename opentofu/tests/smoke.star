# Smoke test for ocx.sh/opentofu/opentofu.
#
# Bazel `.bzl` dialect: NO top-level `if`/`for`/`while` STATEMENTS. Branch at
# module scope only via an if-EXPRESSION (the ternary below) or a `def` plus a
# top-level call.
#
# Everything here is offline and hermetic. The configurations written into
# scratch declare no provider and no backend, which is why `validate` and
# `console` work with no `tofu init` — init is the only verb that would fetch
# anything, and it is never run. Nothing shells out to git/ssh/tar either, so
# the stock container images need no `containers[].setup:`.

TOFU = "tofu.exe" if ocx.target_platform.os == ocx.os.Windows else "tofu"

# HOME is set to scratch because tofu reads a CLI config from the home
# directory; container legs run as uid 0 with HOME unset or unwritable.
# CHECKPOINT_DISABLE + TF_IN_AUTOMATION keep any update probe off the wire and
# any "next step" advice out of stdout.
ENV = {
    "HOME": ocx.scratch_root,
    "CHECKPOINT_DISABLE": "1",
    "TF_IN_AUTOMATION": "1",
}

# ── Tier 1 + 2: liveness, version SHAPE, and platform identity ──────────────
#
# `tofu version` prints exactly two lines:
#     OpenTofu v1.12.5
#     on linux_amd64
# The second is `runtime.GOOS + "_" + runtime.GOARCH` baked in at build time
# (internal/command/version.go → getproviders.Platform.String()), and Go's
# spellings are the OCI ones verbatim. Asserting it proves the asset regex put
# the RIGHT artifact in the RIGHT bundle — the one bug class the platform gate
# cannot see from inside. Never assert the version TEXT, only its shape.
r_version = ocx.run(TOFU, "version", env = ENV)
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")
expect.contains(
    r_version.stdout,
    "on " + str(ocx.target_platform.os) + "_" + str(ocx.target_platform.arch),
)

# ── Tier 3a: the formatter, with its own output as the check ────────────────
#
# A deliberately mis-indented config. `fmt -check` must REFUSE it (exit 3, and
# it names the offending file), `fmt` must rewrite it, and `fmt -check` must
# then accept it with empty stdout. The rewritten bytes are asserted on the
# formatter's OWN work — the `=` signs aligned into a column — which is the
# negative control for a passthrough: a tool that merely echoed its input would
# pass an exit-code-only check and fail this one.
ocx.write_file("messy.tf", 'variable   "n" {\ntype=number\ndefault=  3\n}\n')

r_check_bad = ocx.run(TOFU, "fmt", "-check", "-list=true", "-no-color", "messy.tf", env = ENV)
expect.eq(r_check_bad.exit_code, 3)
expect.eq(r_check_bad.stdout.count("messy.tf"), 1)

r_fmt = ocx.run(TOFU, "fmt", "-no-color", "messy.tf", env = ENV)
expect.ok(r_fmt)

formatted = ocx.read_file("messy.tf")
expect.eq(formatted.count('variable "n" {'), 1)
expect.eq(formatted.count("  type    = number"), 1)
expect.eq(formatted.count("  default = 3"), 1)

r_check_ok = ocx.run(TOFU, "fmt", "-check", "-list=true", "-no-color", "messy.tf", env = ENV)
expect.ok(r_check_ok)
expect.eq(r_check_ok.stdout.count("messy.tf"), 0)

# ── Tier 3b: the config loader + type checker, BOTH polarities ──────────────
#
# `validate -json` is byte-exact machine output — no colour, no prose — so the
# assertions bind the document, not a rendered message.
ocx.mkdir("ok")
ocx.write_file(
    "ok/main.tf",
    'variable "n" {\n  type    = number\n  default = 3\n}\n\noutput "double" {\n  value = var.n * 2\n}\n',
)

r_valid = ocx.run(TOFU, "validate", "-json", cwd = "ok", env = ENV)
expect.ok(r_valid)
expect.eq(r_valid.stdout.count('"valid": true'), 1)
expect.eq(r_valid.stdout.count('"error_count": 0'), 1)

# Negative control: a config with a truncated type expression. Red must be
# reachable — an artifact that accepted this would make the green above
# meaningless.
ocx.mkdir("bad")
ocx.write_file("bad/main.tf", 'variable "x" {\n  type = \n}\n')

r_invalid = ocx.run(TOFU, "validate", "-json", cwd = "bad", env = ENV)
expect.ne(r_invalid.exit_code, 0)
expect.eq(r_invalid.stdout.count('"valid": false'), 1)
expect.eq(r_invalid.stdout.count('"error_count": 0'), 0)
expect.contains(r_invalid.stdout, '"severity": "error"')

# ── Tier 3c: the HCL evaluator computes a real value ────────────────────────
#
# `console` with piped stdin evaluates against the `ok` module above. The
# marker is computed BY tofu (3 * 2 = 6) rather than echoed, and counting it
# survives any banner a runner might prepend.
r_console = ocx.run(
    TOFU,
    "console",
    cwd = "ok",
    stdin = 'format("OCXSMOKE=%d", var.n * 2)\n',
    env = ENV,
)
expect.ok(r_console)
expect.eq(r_console.stdout.count("OCXSMOKE=6"), 1)
