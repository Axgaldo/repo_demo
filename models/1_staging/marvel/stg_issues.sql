{{ config(
    database='MARVEL_BRONZE_DB',
    schema='STAGING'
) }}

with source as (
    select * from {{ source('marvel_raw', 'raw_comics') }}
),

flattened as (
    select
        -- Identificadores únicos
        json_data:comic_id::int as issue_id,
        json_data:issue_url::string as issue_url,
        
        -- Información de Cabecera
        json_data:title::string as issue_title,
        json_data:cover_url::string as cover_url,
        json_data:description::string as description,
        
        -- Ratings (Limpieza de tipos según tu scraper)
        nullif(json_data:rating_avg::string, '0')::float as rating_avg,
        json_data:ratings_count::int as ratings_count,
        
        -- Estadísticas de usuario (Nivel 'stats' en tu JSON)
        -- UN TEST SINGULAR HIZO VER QUE TENÍAMOS QUE QUITAR LA COMA
        NULLIF(replace(json_data:stats.have::string, ',', ''), '')::int as num_user_owns,
        NULLIF(replace(json_data:stats.read::string, ',', ''), '')::int as num_user_reads,
        NULLIF(replace(json_data:stats.wish::string, ',', ''), '')::int as num_user_wishes,
        
        -- Detalles Técnicos (Nivel 'details' en tu JSON)
        json_data:details.format::string as format_desc,
        json_data:details.pages::int as num_pages,
        
        -- Limpieza de Precio: quitamos el '$' antes de convertir a decimal
        NULLIF(replace(replace(json_data:details.price::string, '$', ''), ',', '.'), '')::decimal(8,2) as price_dollars,
        
        json_data:details.upc::string as upc,
        json_data:details.sku::string as sku,
        json_data:details.cover_date::string as cover_date_raw,
        
        -- Guardamos el array de historias intacto para la siguiente capa
        json_data:stories as stories_raw,
        
        -- Metadatos de auditoría
        file_name as source_file_name,
        ingested_at as loaded_at_raw

    from source
)

select * from flattened