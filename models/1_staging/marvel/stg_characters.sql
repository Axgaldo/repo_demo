{{ config(
    database='MARVEL_BRONZE_DB',
    schema='STAGING'
) }}

with source as (
    select * from {{ source('marvel_raw', 'raw_characters') }}
),

renamed as (
    select
        -- Identificación Básica
        json_data:char_id::int as character_id,
        json_data:name::string as character_name,
        json_data:url::string as character_url,
        json_data:image::string as image_url,
        json_data:type::string as character_type,
        
        -- Entidad Multiversal (Solo el nombre)
        nullif(json_data:is_alter_ego_of.name::string, '') as multiversal_entity_name,
        
        -- Metadata
        json_data:metadata.universe::string as universe,
        json_data:metadata.years_active::string as years_active_raw,
        
        -- Biografía: Campos de texto simple (Mapeo completo del JSON de Steve Rogers)
        json_data:biography.franchise::string as franchise,
        json_data:biography.species::string as species,
        json_data:biography.pronouns::string as pronouns,
        json_data:biography.living_status::string as living_status,
        json_data:biography.occupation::string as occupation,
        json_data:biography.place_of_origin::string as place_of_origin,

        -- PRIMERA APARICIÓN (Solo la primera del array)
        json_data:biography.first_appearance[0].issue::string as first_appearance_issue,
        json_data:biography.first_appearance[0].url::string as first_appearance_issue_url,
        
        -- MUERTE (Solo la primera del array)
        json_data:biography.death[0].issue::string as death_issue,
        json_data:biography.death[0].url::string as death_issue_url,

        -- Arrays de Objetos (Para explotar en la capa Intermediate)
        json_data:biography.creators as creators_array,
        json_data:aliases as aliases_array,
        json_data:affiliations as affiliations_json,
        json_data:capabilities as capabilities_json,
        json_data:relationships as relationships_json,
        
        -- Auditoría
        file_name as source_file_name,
        ingested_at as loaded_at
    from source
)

select * from renamed