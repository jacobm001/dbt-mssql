#!/usr/bin/env python
from setuptools import find_packages
from distutils.core import setup

package_name = "dbt-mssql"
package_version = "1.0.5"
description = """The mssql adpter plugin for dbt (data build tool)"""

setup(
    name=package_name,
    version=package_version,
    description=description,
    long_description=description,
    author='Jacob Mastel',
    author_email='jacob@mastel.org',
    url='',
    packages=find_packages(),
    package_data={
        'dbt': [
            'include/mssql/dbt_project.yml',
            'include/mssql/macros/*.sql',
            'include/mssql/macros/materializations/**/*.sql',
        ]
    },
    install_requires=[
        'dbt-core>=0.14.0',
        'pyodbc'
    ]
)
