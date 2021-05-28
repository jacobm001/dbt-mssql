# Archived Note

I'm officially archiving this repo as I don't currently have a need for it and [dbt-sqlserver](https://github.com/dbt-msft/dbt-sqlserver) has long surpassed this repo. I see no current value in maintaining a redundant project and instead encorage people to use that option.

# dbt-mssql

dbt-mssql is a custom adapter for [dbt](https://github.com/fishtown-analytics/dbt) that adds support for Microsoft SQL Server versions 2008 R2 and later. pyodbc is used as the connection driver as that is what is [suggested by Microsoft](https://docs.microsoft.com/en-us/sql/connect/python/python-driver-for-sql-server). The adapter supports both windows auth, and specified user accounts.

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

The example below configures a seperate dev and prod environment for the package, _foo_. You will likely need to alter the `driver` variable to match whatever is installed on your system. In this example, I'm using version 17, which is the newest on my system. If you have something else on your system, it should work as well.

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

## Jaffle Shop

Fishtown Analytic's [jaffle shop](https://github.com/fishtown-analytics/jaffle_shop) package is currently unsupported by this adapter. At the time of this writing, jaffle shop uses the `using()` join, and `group by [ordinal]` notation which is not supported in T-SQL. An alternative version has been forked by the author of dbt-mssql [here](https://github.com/jacobm001/jaffle_shop_mssql).

## Creating indexes on post-hook

- To create a nonclustered index for a specific model, go to that model's SQL and add a `config` macro with a `pre-hook` and `post-hook` key/value pair.  
- Whenever you _create_nonclustered_index_ on a `post-hook`, we recommend you _drop_all_indexes_on_table_ on a `pre-hook`.  
- You can create more than one index on a model in the `post-hook` by submitting a bracketed list of _create_nonclustered_index_ macros. 
- See examples below.

### Macro Syntax

- _create_clustered_index_ takes one argument:
  - column - a quoted string that refers to the column you want to create a clustered index on
- _drop_all_indexes_on_table_ needs no arguments.
- _create_nonclustered_index_ takes two arguments:
  - columns - a list of quoted strings that refer to the column names you want to create the index on
  - includes - a list of quotes strings that refer to the column names that you want to include in the index look-ups.

### Create one index on a model

```jinja2
{{ 
    config({
      "pre-hook": "{{ drop_all_indexes_on_table() }}",
      "post-hook": "{{ create_nonclustered_index(columns = ['some_column'], includes = ['another_column']) }}"
    }) 
}}
```

### Create many indexes on a model 

```jinja2
{{ 
    config({
      "pre-hook": "{{ drop_all_indexes_on_table() }}",
      "post-hook": [
         "{{ create_clustered_index(column = 'some_table_key'}}",
         "{{ create_nonclustered_index(columns = ['some_column']) }}",
         "{{ create_nonclustered_index(columns = ['a_colmumn', 'the_column']) }}",
         "{{ create_nonclustered_index(columns = ['this_column', 'that_column'], includes = ['my_column', 'your_column']) }}"
	 ]
    }) 
}}
```
