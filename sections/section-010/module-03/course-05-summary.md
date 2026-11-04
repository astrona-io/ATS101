# Summary

A Harbor project keeps its rules in a metadata map. Every value is a string, so `"true"` is correct and the JSON boolean is not. The project is read and changed with the same path in the REST API. A `PUT` merges the keys you send into the stored map, so you change one rule without touching the others. Only Project Admins and system administrators may change these settings; every other role receives `403`.

Scanning and blocking are two separate decisions. With `auto_scan`, Harbor asks its scanner adapter, Trivy, to scan every image when it is pushed. With `prevent_vul` and `severity`, Harbor refuses to serve an image whose stored report holds a finding at that severity or above. The push still works, the report does not change until the next scan, and a file artifact with no packages has nothing to scan.

A CVE allowlist makes the blocking rule ignore chosen vulnerabilities. The system list is shared by the registry, a project list belongs to one project, and `reuse_sys_cve_allowlist` picks which one applies. The list you send replaces the stored list, and an expiry time returns the finding to the blocking decision. Content trust adds a second question: not what is inside the image, but whether it is signed. With `enable_content_trust_cosign`, Harbor serves a digest only if a cosign signature exists for it, and the deploy tool should still verify the key. The key facts to remember are these:

- Metadata values are strings.
- `prevent_vul` needs `severity`, and it blocks pulls, not pushes.
- The allowlist applies only when `reuse_sys_cve_allowlist` is `"false"`, or in the system list when it is `"true"`.
- Sign the digest, never the tag.

<!-- astrona:playground:destroy -->
