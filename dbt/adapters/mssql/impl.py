from dbt.adapters.sql import SQLAdapter
from dbt.adapters.mssql import MSSQLConnectionManager


class MSSQLAdapter(SQLAdapter):
    ConnectionManager = MSSQLConnectionManager

    @classmethod
    def date_function(cls):
        return 'curent_date()'
