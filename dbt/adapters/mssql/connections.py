from contextlib import contextmanager

from dbt.adapters.base import Credentials
from dbt.adapters.sql import SQLConnectionManager


MSSQL_CREDENTIALS_CONTRACT = {
    'type': 'object',
    'additionalProperties': False,
    'properties': {
        'driver': {
            'type': 'string',
        },
        'server': {
            'type': 'string',
        },
        'database': {
            'type': 'string',
        },
        'schema': {
            'type': 'string',
        },
        'UID': {
            'type': 'string',
        },
        'PWD': {
            'type': 'string',
        },
    },
    'required': ['server', 'database', 'schema', 'UID', 'PWD'],
}


class MSSQLCredentials(Credentials):
    SCHEMA = MSSQL_CREDENTIALS_CONTRACT
    ALIASES = {
        'user': 'UID'
        , 'username': 'UID'
        , 'pass': 'PWD'
        , 'password': 'PWD'
    }

    @property
    def type(self):
        return 'mssql'

    def _connection_keys(self):
        # return an iterator of keys to pretty-print in 'dbt debug'
        # raise NotImplementedError
        return ('server', 'database', 'schema', 'UID', 'PWD')


class MSSQLConnectionManager(SQLConnectionManager):
    TYPE = 'mssql'
