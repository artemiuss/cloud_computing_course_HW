# Haunting CVEs

**The goal**: find CVEs in real docker image.

Scan image `ghcr.io/mlflow/mlflow:v2.3.0` with [grype](https://github.com/anchore/grype) and [trivy](https://github.com/aquasecurity/trivy) only for fixed HIGH and CRITICAL vulnerabilities.

## Deliveries

### Scan with trivy
```
trivy --severity HIGH,CRITICAL image --ignore-unfixed ghcr.io/mlflow/mlflow:v2.3.0
```

Scan results:
```
2023-05-07T12:08:50.222+0300    INFO    Vulnerability scanning is enabled
2023-05-07T12:08:50.222+0300    INFO    Secret scanning is enabled
2023-05-07T12:08:50.222+0300    INFO    If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2023-05-07T12:08:50.222+0300    INFO    Please see also https://aquasecurity.github.io/trivy/v0.41/docs/secret/scanning/#recommendation for faster secret detection
2023-05-07T12:08:51.280+0300    INFO    Detected OS: debian
2023-05-07T12:08:51.280+0300    INFO    Detecting Debian vulnerabilities...
2023-05-07T12:08:51.315+0300    INFO    Number of language-specific files: 1
2023-05-07T12:08:51.315+0300    INFO    Detecting python-pkg vulnerabilities...

ghcr.io/mlflow/mlflow:v2.3.0 (debian 11.6)

Total: 4 (HIGH: 4, CRITICAL: 0)

┌──────────────┬────────────────┬──────────┬───────────────────┬────────────────────────┬────────────────────────────────────────────┐
│   Library    │ Vulnerability  │ Severity │ Installed Version │     Fixed Version      │                   Title                    │
├──────────────┼────────────────┼──────────┼───────────────────┼────────────────────────┼────────────────────────────────────────────┤
│ libncursesw6 │ CVE-2022-29458 │ HIGH     │ 6.2+20201114-2    │ 6.2+20201114-2+deb11u1 │ ncurses: segfaulting OOB read              │
│              │                │          │                   │                        │ https://avd.aquasec.com/nvd/cve-2022-29458 │
├──────────────┤                │          │                   │                        │                                            │
│ libtinfo6    │                │          │                   │                        │                                            │
│              │                │          │                   │                        │                                            │
├──────────────┤                │          │                   │                        │                                            │
│ ncurses-base │                │          │                   │                        │                                            │
│              │                │          │                   │                        │                                            │
├──────────────┤                │          │                   │                        │                                            │
│ ncurses-bin  │                │          │                   │                        │                                            │
│              │                │          │                   │                        │                                            │
└──────────────┴────────────────┴──────────┴───────────────────┴────────────────────────┴────────────────────────────────────────────┘
2023-05-07T12:08:51.342+0300    INFO    Table result includes only package filenames. Use '--format json' option to get the full path to the package file.

Python (python-pkg)

Total: 3 (HIGH: 1, CRITICAL: 2)

┌───────────────────┬─────────────────────┬──────────┬───────────────────┬───────────────┬─────────────────────────────────────────────────────────────┐
│      Library      │    Vulnerability    │ Severity │ Installed Version │ Fixed Version │                            Title                            │
├───────────────────┼─────────────────────┼──────────┼───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ Flask (METADATA)  │ CVE-2023-30861      │ HIGH     │ 2.2.3             │ 2.2.5, 2.3.2  │ Flask is a lightweight WSGI web application framework. When │
│                   │                     │          │                   │               │ all of the...                                               │
│                   │                     │          │                   │               │ https://avd.aquasec.com/nvd/cve-2023-30861                  │
├───────────────────┼─────────────────────┼──────────┼───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ mlflow (METADATA) │ CVE-2023-2356       │ CRITICAL │ 2.3.0             │ 2.3.1         │ Relative path traversal in mlflow                           │
│                   │                     │          │                   │               │ https://avd.aquasec.com/nvd/cve-2023-2356                   │
│                   ├─────────────────────┤          │                   │               ├─────────────────────────────────────────────────────────────┤
│                   │ GHSA-83fm-w79m-64r5 │          │                   │               │ Remote file access vulnerability in `mlflow server` and     │
│                   │                     │          │                   │               │ `mlflow ui` CLIs                                            │
│                   │                     │          │                   │               │ https://github.com/advisories/GHSA-83fm-w79m-64r5           │
└───────────────────┴─────────────────────┴──────────┴───────────────────┴───────────────┴─────────────────────────────────────────────────────────────┘
```

### Scan with grype
```
grype --only-fixed docker:ghcr.io/mlflow/mlflow:v2.3.0 | grep -v "(suppressed)" | sed 's/[[:space:]]*$//' | grep "High$\|Critical$"
```

Scan results:
```
 ✔ Vulnerability DB        [no update available]
 ✔ Loaded image
 ✔ Parsed image
 ✔ Cataloged packages      [164 packages]
 ✔ Scanning image...       [112 vulnerabilities]
   ├── 3 critical, 26 high, 15 medium, 8 low, 59 negligible (1 unknown)
   └── 12 fixed
Flask             2.2.3               2.2.5                   python  GHSA-m2qf-hxjv-5gpq  High
libncursesw6      6.2+20201114-2      6.2+20201114-2+deb11u1  deb     CVE-2022-29458       High
libtinfo6         6.2+20201114-2      6.2+20201114-2+deb11u1  deb     CVE-2022-29458       High
mlflow            2.3.0               2.3.1                   python  GHSA-83fm-w79m-64r5  Critical
mlflow            2.3.0               2.3.1                   python  GHSA-x422-6qhv-p29g  Critical
ncurses-base      6.2+20201114-2      6.2+20201114-2+deb11u1  deb     CVE-2022-29458       High
ncurses-bin       6.2+20201114-2      6.2+20201114-2+deb11u1  deb     CVE-2022-29458       High
```


