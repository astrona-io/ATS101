# Set Project Security Policies

Two projects on the same Harbor often need different rules. A project for public base images can be open and unscanned. A project for payment services must scan every push, refuse to serve images with serious vulnerabilities and accept only signed images. Harbor keeps those rules as settings of the project, so an administrator can set them per project without touching the rest of the registry.

A project stores its settings in a map called **metadata**. Every value in the map is a string, even when it looks like a boolean, so `"true"` is a string and not the JSON value `true`. Keep one sentence in mind for the whole module: **a project's metadata decides what Harbor does to an artifact when it arrives and when somebody tries to pull it.**

The module has four parts. **Project Metadata And The Project API** reads and changes the metadata map. **Vulnerability Scanning And Pull Blocking** turns on automatic scans and blocks the pull of risky images. **The CVE Allowlist** accepts known vulnerabilities for one project. **Content Trust With Cosign** lets a project serve only signed images. A graded lab follows the fourth part.

## Learning objectives

After this module you can:

- Read a project and its metadata through the REST API.
- Name the metadata keys that control visibility, scanning, pull blocking and signatures.
- Change one metadata key without changing the others.
- Turn on automatic scanning and set the severity at which pulls are blocked.
- Add a Common Vulnerabilities and Exposures (CVE) entry to a project allowlist and choose between the project list and the system list.
- Require cosign signatures for a project.

## Before you start

You need to know what a Harbor project is and how to call the REST API with `curl`. You do not need to know how scanning works inside; the module explains what Harbor does with the result.

Your playground is a single-node `kind` cluster with **Harbor v2.15.4** at `https://harbor.localtest.me:8443`. Trivy, Harbor's built-in vulnerability scanner, is installed. The `workstation` pod holds `harbor` (v0.0.27), `oras`, `cosign`, `curl` and `jq`. Harbor holds:

| Object | What it is |
| --- | --- |
| `admin` | The built-in system administrator, with the lab-only password `Harbor12345` |
| `alice`, `bob` | Local users with the lab-only passwords `AlicePass1` and `BobPass1` |
| `payments` | A private project with default metadata, where `alice` is Project Admin and `bob` is Guest |

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
