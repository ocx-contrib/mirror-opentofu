# NOTICE

This repository packages and redistributes upstream software published by the
[OpenTofu](https://github.com/opentofu/opentofu) project. The Apache-2.0
license in [`LICENSE`](LICENSE) covers the OCX pipeline files authored here. It
does **not** cover any upstream-derived asset — each package's redistributed
bytes carry their own license, recorded below.

Each package's logo in this repository reproduces the **upstream project's own
mark** at 512 px, unmodified apart from scaling, solely to identify the
software being mirrored. No endorsement or affiliation is implied, and no
trademark right is claimed.

| Package | GHCR path | Upstream SPDX |
|---|---|---|
| `opentofu` | `ghcr.io/ocx-contrib/opentofu/opentofu` | `MPL-2.0` |

---

## `opentofu`

Upstream: <https://github.com/opentofu/opentofu>
Published to `ghcr.io/ocx-contrib/opentofu/opentofu`.

| Component | SPDX | Holder |
|---|---|---|
| OpenTofu (`tofu`) | **MPL-2.0** | Copyright (c) The OpenTofu Authors; portions Copyright (c) 2023 HashiCorp, Inc. |

Verified at the Phase 1.5 license gate:

```console
$ gh api repos/opentofu/opentofu/license --jq '{spdx: .license.spdx_id}'
{"spdx":"MPL-2.0"}
```

OpenTofu is **not** under the Business Source License. It is the community fork
created when Terraform moved to BSL 1.1, and it is MPL-2.0 throughout.

### Source-code availability (MPL-2.0 § 3.2)

The Mozilla Public License 2.0 is **file-level (weak) copyleft**. It permits
redistribution of the software in Executable Form under any license, on the
condition that recipients are informed how to obtain the Source Code Form of
the Covered Software at no charge. Nothing here is modified — every binary is
republished byte-for-byte inside an OCX bundle — so the obligation is
discharged by pointing at the upstream source of the exact tagged release each
mirrored version is built from:

> **Corresponding Source for version `X.Y.Z`:**
> <https://github.com/opentofu/opentofu/tree/vX.Y.Z>
> (tarball: `https://github.com/opentofu/opentofu/archive/refs/tags/vX.Y.Z.tar.gz`)

Upstream's own `LICENSE` file additionally ships **inside every mirrored
archive**, at the archive root beside the binary, and is republished unmodified
as part of the bundle content.

The published binaries statically link third-party Go modules under permissive
licenses, enumerated in the `go.mod`/`go.sum` of the tagged upstream source for
each mirrored version.

### Trademark

"OpenTofu" and the OpenTofu logo are marks of the OpenTofu project, hosted by
the Linux Foundation. The logo in `opentofu/logo.svg` is taken unmodified
(apart from scaling) from
[`opentofu/brand-artifacts`](https://github.com/opentofu/brand-artifacts) and
used nominatively to identify the software being mirrored, under the
[Linux Foundation Trademark Usage Policy](https://www.linuxfoundation.org/legal/trademark-usage).

No modifications are made to any upstream artifact in this repository; they are
republished byte-for-byte inside an OCX bundle.
