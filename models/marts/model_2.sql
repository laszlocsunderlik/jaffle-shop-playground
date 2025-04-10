with item_count_per_order as (
    select
        order_id,
        count(item_id) as item_count
    from {{ ref('orders_items_view') }}
    group by order_id
),

order_totals as (
    select
        order_id,
        order_total
    from {{ ref('orders_items_view') }}
)

select
    p.name as product_name,
    count(item_id) as items_sold,
    round(
        avg(ot.order_total::numeric / nullif(ico.item_count, 0)), 2
    ) as avg_price_with_tax
from
    {{ ref('orders_items_view') }} as i
inner join
    {{ source('raw_jaffle_shop_data', 'raw_products') }} as p
    on i.sku = p.sku
inner join
    order_totals as ot
    on i.order_id = ot.order_id
inner join
    item_count_per_order as ico
    on i.order_id = ico.order_id
group by p.name
order by items_sold desc
