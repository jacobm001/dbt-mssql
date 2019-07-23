from contextlib import contextmanager

import pyodbc

import dbt.compat
import dbt.exceptions
from dbt.adapters.base import Credentials
from dbt.adapters.sql import SQLConnectionManager

from dbt.logger import GLOBAL_LOGGER as logger

MSSQL_CREDENTIALS_CONTRACT = {
    'type': 'object',
    'additionalProperties': False,
    'properties': {
        'driver': {
            'type': 'string',
        },
        'host': {
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

    # @contextmanager
    # def exception_handler(self, sql):
    #     try:
    #         yield

    #     except psycopg2.DatabaseError as e:
    #         logger.debug('Postgres error: {}'.format(str(e)))

    #         try:
    #             # attempt to release the connection
    #             self.release()
    #         except psycopg2.Error:
    #             logger.debug("Failed to release connection!")
    #             pass

    #         raise dbt.exceptions.DatabaseException(
    #             dbt.compat.to_string(e).strip())

    #     except Exception as e:
    #         logger.debug("Error running SQL: %s", sql)
    #         logger.debug("Rolling back transaction.")
    #         self.release()
    #         if isinstance(e, dbt.exceptions.RuntimeException):
    #             # during a sql query, an internal to dbt exception was raised.
    #             # this sounds a lot like a signal handler and probably has
    #             # useful information, so raise it without modification.
    #             raise

    #         raise dbt.exceptions.RuntimeException(e)

    @classmethod
    def open(cls, connection):
        if connection.state == 'open':
            logger.debug('Connection is already open, skipping open.')
            return connection
        
        credentials = connection.credentials

        try:
            con_str = []
            con_str.append(f"DRIVER={{ODBC Driver 17 for SQL Server}}")
            con_str.append(f"SERVER='{credentials.host}'")
            con_str.append(f"UID='{credentials.UID}'")
            con_str.append(f"PWD='{credentials.PWD}'")            
            
            con_str_concat = ';'.join(con_str)
            handle = pyodbc.connect(con_str_concat)
            
            connection.state = 'open'
            connection.handle = handle
        
        except pyodbc.Error as e:
            logger.debug(f"Could not connect to db: {e}")

            connection.handle = None
            connection.state = 'fail'

            raise dbt.exceptions.FailedToConnectException(str(e))

        return connection

    # def cancel(self, connection):
    #     connection_name = connection.name
    #     pid = connection.handle.get_backend_pid()

    #     sql = "select pg_terminate_backend({})".format(pid)

    #     logger.debug("Cancelling query '{}' ({})".format(connection_name, pid))

    #     _, cursor = self.add_query(sql)
    #     res = cursor.fetchone()

    #     logger.debug("Cancel query '{}': {}".format(connection_name, res))

    @classmethod
    def get_credentials(cls, credentials):
        return credentials

    @classmethod
    def get_status(cls, cursor):
        # return cursor.statusmessage
        return 'OK'
