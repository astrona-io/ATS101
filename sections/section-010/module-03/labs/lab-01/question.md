# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** Project security policies

## Scenario

The project `payments` holds images for the payment services. The security team wants every push scanned, wants Harbor to refuse to serve images with a high or critical vulnerability, wants only signed images served, and wants the project hidden from people who are not members. One vulnerability, `CVE-2024-3094`, is accepted for this project only, because the affected package is not used.

Run every Harbor command in the workstation pod. The built-in system administrator is `admin` with the password `Harbor12345`. The users `alice` and `bob` have the passwords `AlicePass1` and `BobPass1`.

## Your task

For the project `payments`:

1. Scan every pushed image automatically.
2. Refuse to serve images with a vulnerability of severity `high` or above.
3. Serve only images with a cosign signature.
4. Accept `CVE-2024-3094` in the project allowlist, and do not use the system allowlist.
5. Make the project private.

## Constraints

- Do not change the `admin` password.
- Do not remove `alice` or `bob` from the project.
- Do not change the settings of any other project.

## Done when

- The project metadata has `auto_scan`, `prevent_vul` and `enable_content_trust_cosign` set to `"true"` and `severity` set to `"high"`.
- The project allowlist holds `CVE-2024-3094` and `reuse_sys_cve_allowlist` is `"false"`.
- The project is private, so an unauthenticated request for it is refused.
