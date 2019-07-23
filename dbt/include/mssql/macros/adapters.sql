{% macro mssql__list_schemas(database) %}
    {% call statement('list_schemas', fetch_result=True, auto_begin=False) -%}
        select distinct schema_name
        from "{{ database }}".information_schema.schemata
        where catalog_name = '{{ database }}'
    {%- endcall %}

    {{ return(load_result('list_schemas').table) }}
{% endmacro %}

{% macro mssql__create_schema(database_name, schema_name, auto_begin=False) %}
    {% call statement('create_schema') -%}
        CREATE SCHEMA {{ schema_name }}
    {%- endcall %}
{% endmacro %}

{% macro mssql__drop_relation(relation) -%}
    {% call statement('drop_relation', auto_begin=False) -%}
        if object_id('{{ relation.schema }}.{{ relation.identifier }}') is not null
	        drop {{ relation.type }} {{ relation.schema }}.{{ relation.identifier }}
    {%- endcall %}
{% endmacro %}

{% macro mssql__check_schema_exists(database, schema) -%}
    {% call statement('check_schema_exists', fetch_result=True, auto_begin=False) -%}
        select 
            decode(count(*), 0, null)
        from 
            {{ database }}.information_schema.schemata
        where 
            catalog_name    = '{{ database }}'
            and schema_name = '{{ schema }}'
    {%- endcall %}

    {{ return(load_result('check_schema_exists').table) }}
{% endmacro %}

{% macro mssql__list_relations_without_caching(information_schema, schema) %}
    {% call statement('list_relations_without_caching', fetch_result=True) %}
        select
            '{{ information_schema.database.lower() }}' as "database"
            , table_name as name
            , table_schema as "schema"
            , 'table' as type
        from 
            {{ information_schema.database }}.information_schema.TABLES
        where 
            table_schema = '{{ schema }}'
        
        union all

                select
            '{{ information_schema.database.lower() }}' as "database"
            , table_name as name
            , table_schema as "schema"
            , 'view' as type
        from 
            {{ information_schema.database }}.information_schema.VIEWS
        where 
            table_schema = '{{ schema }}'
    {% endcall %}

    {{ return(load_result('list_relations_without_caching').table) }}
{% endmacro %}

{% macro mssql__create_view_as(relation, sql, auto_begin=False) -%}
  create view {{ relation.schema }}.{{ relation.identifier }} as (
    {{ sql }}
  );
{% endmacro %}

{% macro mssql__rename_relation(from_relation, to_relation) -%}
  {% call statement('rename_relation') -%}
    EXEC sp_rename '{{ from_relation.schema }}.{{ from_relation.identifier }}', '{{ to_relation.identifier }}'
  {%- endcall %}
{% endmacro %}
