{% macro drop_all_indexes_on_table() %}
{# Altered from https://stackoverflow.com/q/1344401/10415173 #}

declare @drop_xml_indexes_first nvarchar(max);
select @drop_xml_indexes_first = ( 
    select 'DROP INDEX IF EXISTS [' + sys.indexes.[name] + '] ON ' + '[' + SCHEMA_NAME(sys.tables.[schema_id]) + '].[' + OBJECT_NAME(sys.tables.[object_id]) + ']; '
    from sys.indexes 
    inner join sys.tables on sys.indexes.object_id = sys.tables.object_id
    where sys.indexes.[name] is not null 
      and sys.indexes.type_desc = 'XML'
      and sys.tables.[name] = '{{ this.table }}'
    for xml path('')
); exec sp_executesql @drop_xml_indexes_first;

declare @drop_spatial_indexes_second nvarchar(max);
select @drop_spatial_indexes_second = ( 
    select 'DROP INDEX IF EXISTS [' + sys.indexes.[name] + '] ON ' + '[' + SCHEMA_NAME(sys.tables.[schema_id]) + '].[' + OBJECT_NAME(sys.tables.[object_id]) + ']; '
    from sys.indexes 
    inner join sys.tables on sys.indexes.object_id = sys.tables.object_id
    where sys.indexes.[name] is not null 
      and sys.indexes.type_desc = 'Spatial'
      and sys.tables.[name] = '{{ this.table }}'
    for xml path('')
); exec sp_executesql @drop_spatial_indexes_second;

declare @drop_fk_constraints_next nvarchar(max);
select @drop_fk_constraints_next = ( 
    select 'ALTER TABLE [' + SCHEMA_NAME(sys.foreign_keys.[schema_id]) + '].[' + OBJECT_NAME(sys.foreign_keys.[parent_object_id]) + '] DROP CONSTRAINT IF EXISTS [' + sys.foreign_keys.[name]+ '];'
    from sys.foreign_keys 
    inner join sys.tables on sys.foreign_keys.[referenced_object_id] = sys.tables.[object_id]
    where sys.tables.[name] = '{{ this.table }}'
    for xml path('') 
); exec sp_executesql @drop_fk_constraints_next;

declare @drop_pk_constraints_next nvarchar(max);
select @drop_pk_constraints_next = ( 
    select 'ALTER TABLE [' + SCHEMA_NAME(sys.tables.[schema_id]) + '].[' + sys.tables.[name] + '] DROP CONSTRAINT IF EXISTS [' + sys.indexes.[name]+ '];'
    from sys.indexes 
    inner join sys.tables on sys.indexes.[object_id] = sys.tables.[object_id]
    where sys.indexes.is_primary_key = 1
      and sys.tables.[name] = '{{ this.table }}'
    for xml path('') 
); exec sp_executesql @drop_pk_constraints_next;

declare @drop_remaining_indexes_last nvarchar(max);
select @drop_remaining_indexes_last = (
    select 'DROP INDEX IF EXISTS [' + sys.indexes.[name] + '] ON ' + '[' + SCHEMA_NAME(sys.tables.[schema_id]) + '].[' + OBJECT_NAME(sys.tables.[object_id]) + ']; '
    from sys.indexes 
    inner join sys.tables on sys.indexes.object_id = sys.tables.object_id
    where sys.indexes.[name] is not null 
      and sys.tables.[name] = '{{ this.table }}'
    for xml path('')
); exec sp_executesql @drop_remaining_indexes_last;

{% endmacro %}



{% macro create_nonclustered_index(columns, includes) %}

{% if include_names is undefined %}

create nonclustered index 
    {{ this.table }}__index_on_{{ columns|join("_") }}
      on {{ this }} ({{ '[' + columns|join("], [") + ']' }})
 
{% else %}

create nonclustered index 
    {{ this.table }}__index_on_{{ columns|join("_") }}
      on {{ this }} ({{ '[' + columns|join("], [") + ']' }})
      include ({{ '[' + includes|join("], [") + ']' }})

{% endif %}

{% endmacro %}
