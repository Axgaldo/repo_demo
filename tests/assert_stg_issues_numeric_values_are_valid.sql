-- Este test busca registros donde los valores numéricos no tengan sentido
-- Si devuelve algo, el test fallará.

with issues as (
    select * from {{ ref('stg_issues') }}
)

select
    issue_id,
    price_dollars,
    num_user_owns,
    rating_avg
from issues
where
    -- El precio no puede ser negativo
    price_dollars < 0
    
    -- Los stats de usuario deben ser enteros positivos (o 0)
    or num_user_owns < 0
    or num_user_reads < 0
    or num_user_wishes < 0
    
    -- El rating debe estar en el rango lógico de 0 a 5
    or rating_avg < 0 
    or rating_avg > 5
    
    -- Opcional: Verificar que el precio no sea una cifra astronómica por error de coma
    or price_dollars > 10000