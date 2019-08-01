# dbt-mssql

dbt-mssql is a custom adapter for [dbt](https://github.com/fishtown-analytics/dbt) that adds support for Microsoft SQL Server versions 2008 R2 and later. pyodbc is used as the connection driver as that is what is [suggested by Microsoft](https://docs.microsoft.com/en-us/sql/connect/python/python-driver-for-sql-server). The adapter supports both windows auth, and specified user accounts.

dbt-mssql is currently in a beta release. It is passing all of the [dbt integration tests](https://github.com/fishtown-analytics/dbt-integration-tests/) on SQL Server 2008 R2. Considering Microsoft's legendary backwards compatibility, it should work on newer versions, but that testing will come in the near future. 

## Connecting to SQL Server

Your user profile (located in `~/.dbt/profile`) will need an appropriate entry for your package. 

Required parameters are:

- driver
- host
- database
- schema
- one of the login options:
  - SQL Server authentication
    - username
    - password
  - Windows Login
    - windows_login: true

**Example profile:**

The example below configures a seperate dev and prod environment for the package, _foo_.

```yaml
foo:
  target: dev
  outputs:
    dev:
      type: mssql
      driver: 'ODBC Driver 17 for SQL Server'
      host: sqlserver.mydomain.com
      database: dbt_test
      schema: foo_dev
      windows_login: True
    prod:
      type: mssql
      driver: 'ODBC Driver 17 for SQL Server'
      host: sqlserver.mydomain.com
      database: dbt_test
      schema: foo
      username: dbt_user
      password: super_secret_dbt_password
```
