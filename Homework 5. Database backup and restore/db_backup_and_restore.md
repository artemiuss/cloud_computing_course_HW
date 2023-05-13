# Database backup and restore

**The goal**: understand what to do if everything is screwed up.

## Deliveries: Documented backup and restore process

### Backup current db instance
```
aws rds create-db-snapshot --db-instance-identifier <DBInstanceIdentifier> --db-snapshot-identifier=<snapshot_identifier>
```

example:
```
aws rds create-db-snapshot --db-instance-identifier "terraform-20230513181752117700000005" --db-snapshot-identifier="mysnapshot"
```

### Restore to a new db instance
```
aws rds restore-db-instance-from-db-snapshot --db-instance-identifier <DBInstanceIdentifier> --db-snapshot-identifier=<snapshot_identifier>
```

example:
```
aws rds restore-db-instance-from-db-snapshot --db-instance-identifier "terraform-20230513181752117700000005-restored" --db-snapshot-identifier="mysnapshot"
```

