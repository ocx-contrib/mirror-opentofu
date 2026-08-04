# mirror-opentofu

OCX mirrors for [OpenTofu](https://opentofu.org) tooling. One repository, one
spec directory per package.

| Package | Spec | Publishes to | Announced as |
|---|---|---|---|
| OpenTofu | [`opentofu/mirror.yml`](opentofu/mirror.yml) | `ghcr.io/ocx-contrib/opentofu/opentofu` | [`ocx.sh/opentofu/opentofu`](https://index.ocx.sh/opentofu/opentofu) |

Each upstream release is discovered, re-bundled, smoke-tested per
`(version, platform)` and only then pushed with cascade tags, after which the
result is announced into the OCX index.

## Layout

`mirror-base.yml` at the root holds the repo-wide policy every spec inherits
via `extends:`. `extends:` is a **shallow** merge — a spec that sets a
top-level key replaces that block whole, which is why `opentofu/mirror.yml`
does not restate `platforms:`.

## Editing

| File | Edit | Regenerate after |
|------|------|------------------|
| `mirror-base.yml`, `opentofu/mirror.yml` | hand | `ocx-mirror package pipeline generate ci --spec opentofu/mirror.yml` |
| `opentofu/tests/smoke.star` | hand | — |
| `opentofu/metadata.json`, `opentofu/CATALOG.md`, `opentofu/logo.*` | hand | — |
| `.github/workflows/*.yml` | **generated — never hand-edit** | re-run when a spec changes |

`--spec` **appends** rather than replaces, so the regenerate command must name
every spec in the repository — today that is `opentofu/mirror.yml` alone.

The repo root is inferred from the enclosing git repository, so `--repo-root`
is needed only when generating outside a checkout.

CI fails on drift via `ocx-mirror package pipeline generate ci --check`.

## Notes for this upstream

- **Version order is not publication order.** OpenTofu maintains parallel patch
  trains: `v1.11.13` was published two months *after* `v1.12.0`, and `v1.10.10`
  after `v1.11.6`. Anything that reasons about "the newest releases" must sort
  by parsed semver, never by `published_at`.
- **Every platform ships both `.tar.gz` and `.zip`.** The spec anchors on
  `.tar.gz` everywhere, windows included; matching both would give two
  candidates per `(os, arch)` and a hard ambiguous error.
- **Distro packages drop the OS token** — `tofu_<V>_amd64.deb` sits beside
  `tofu_<V>_linux_amd64.tar.gz`. The asset patterns are anchored at both ends
  with the OS token spelled out so `.apk`/`.deb`/`.rpm` and the three
  `.gpgsig`/`.pem`/`.sig` sidecars per asset are unreachable.

## Required secrets

| Secret | Use |
|--------|-----|
| `OCX_ANNOUNCE_TOKEN` | opens the index PR from the `ocx-contrib/index` fork |
| `OCX_MIRROR_DISCORD_HOOK` | notify-stage Discord webhook URL |

(Inherited from the `ocx-contrib` org with visibility ALL. GHCR pushes use the
run's own `GITHUB_TOKEN` — no registry secret needed.)

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Upstream assets are out of scope; see
[`NOTICE.md`](NOTICE.md).
