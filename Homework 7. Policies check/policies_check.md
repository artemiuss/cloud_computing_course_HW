# Policies check

**The goal**: check your project compliance with standard policies.

- Scan your project with [checkov](https://github.com/bridgecrewio/checkov)
- Fix at least two different failed checks

## Deliveries

### How to reproduce the results

Run `checkov -d .` in the root of the project.

### Result of initial scan

```
checkov -d .
       _               _
   ___| |__   ___  ___| | _______   __
  / __| '_ \ / _ \/ __| |/ / _ \ \ / /
 | (__| | | |  __/ (__|   < (_) \ V /
  \___|_| |_|\___|\___|_|\_\___/ \_/

By bridgecrew.io | version: 2.3.240

terraform scan results:

Passed checks: 34, Failed checks: 49, Skipped checks: 0
```

The full result of the scan can be found in the `init_scan_result.log` file.

### The checks fixed



### Result of scan after fixes applied

```
       _               _              
   ___| |__   ___  ___| | _______   __
  / __| '_ \ / _ \/ __| |/ / _ \ \ / /
 | (__| | | |  __/ (__|   < (_) \ V / 
  \___|_| |_|\___|\___|_|\_\___/ \_/  
                                      
By bridgecrew.io | version: 2.3.240 

terraform scan results:

Passed checks: 43, Failed checks: 46, Skipped checks: 0
```

The full result of the scan can be found in the `fixed_scan_result.log` file.