from dbt.adapters.mssql.connections import MSSQLConnectionManager
from dbt.adapters.mssql.connections import MSSQLCredentials
from dbt.adapters.mssql.impl import MSSQLAdapter

from dbt.adapters.base import AdapterPlugin
from dbt.include import mssql


Plugin = AdapterPlugin(
    adapter=MSSQLAdapter,
    credentials=MSSQLCredentials,
    include_path=mssql.PACKAGE_PATH)
