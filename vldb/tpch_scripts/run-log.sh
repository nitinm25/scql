#!/bin/bash

QUERY=$1
SIZE=$2

if [ $# -ne 2 ]; then
    echo "Usage: $0 <query> <size>"
    exit 1
fi

TPCH_=("" Q6 Q1 Q14 Q12 "Q1*")
TPCH="${TPCH_[$QUERY]}"

echo "Execute SecretFlow query $QUERY (TPCH $TPCH) @ size $SIZE"

S1=$(
cat<<HERE
select 
  sum(l_extendedprice * l_discount) as revenue 
from 
  (
    (
      select 
        l_extendedprice, 
        l_discount, 
        l_shipdate, 
        l_quantity 
      from 
        alice_lineitem 
      limit 
        $((SIZE / 2))
    ) 
    union all 
      (
        select 
          l_extendedprice, 
          l_discount, 
          l_shipdate, 
          l_quantity 
        from 
          bob_lineitem 
        limit 
          $((SIZE / 2))
      )
  ) as lineitem 
where 
  l_shipdate >= STR_TO_DATE('1995-02-06', '%Y-%m-%d') 
  and l_shipdate < ADDDATE(
    STR_TO_DATE('1995-01-01', '%Y-%m-%d'), 
    interval 1 year
  ) 
  and l_discount >= 0.05 - 0.01 
  and l_discount <= 0.05 + 0.01 
  and l_quantity < 60;
HERE
)

S2=$(
cat<<HERE
select 
  l_returnflag, 
  l_linestatus, 
  sum(l_quantity) as sum_qty, 
  sum(l_extendedprice) as sum_base_price, 
  sum(
    l_extendedprice * (1 - l_discount)
  ) as sum_disc_price, 
  sum(
    l_extendedprice * (1 - l_discount) * (1 + l_tax)
  ) as sum_charge, 
  sum(l_quantity)/ count(*) as avg_qty, 
  sum(l_extendedprice)/ count(*) as avg_price, 
  sum(l_discount)/ count(*) as avg_disc, 
  count(*) as count_order 
from 
  (
    (
      select 
        l_returnflag, 
        l_linestatus, 
        l_quantity, 
        l_extendedprice, 
        l_shipdate, 
        l_discount, 
        l_tax 
      from 
        alice_lineitem 
      limit 
        $((SIZE / 2))
    ) 
    union all 
      (
        select 
          l_returnflag, 
          l_linestatus, 
          l_quantity, 
          l_extendedprice, 
          l_shipdate, 
          l_discount, 
          l_tax 
        from 
          bob_lineitem 
        limit 
          $((SIZE / 2))
      )
  ) as lineitem 
where 
  l_shipdate <= SUBDATE(
    STR_TO_DATE('1996-01-01', '%Y-%m-%d'), 
    INTERVAL 37 DAY
  ) 
group by 
  l_returnflag, 
  l_linestatus;
HERE
)

S3=$(
cat<<HERE
select 100.00 * sum(
        case
            when isv.type_promo then ant.l_extendedprice *(1 - ant.l_discount)
            else 0.0
        end
    ) / sum(ant.l_extendedprice * (1 - ant.l_discount)) as promo_revenue
from (
        select *
        from alice_lineitem
        limit $SIZE
    ) as ant
    join (
        select p_partkey,
            p_type LIKE 'PROMO%' as type_promo
        from bob_part
        limit $SIZE
    ) as isv
where ant.l_partkey = isv.p_partkey
    and ant.l_shipdate >= STR_TO_DATE('1995-02-06', '%Y-%m-%d')
    and ant.l_shipdate < ADDDATE(
        STR_TO_DATE('1996-01-01', '%Y-%m-%d'),
        interval 11 MONTH
    )
HERE
)

S4=$(
cat<<HERE
select 
  ant.l_shipmode, 
  sum(
    case when isv.o_orderpriority = '1-URGENT' 
    or isv.o_orderpriority = '2-HIGH' then 1 else 0 end
  ) as high_line_count, 
  sum(
    case when isv.o_orderpriority <> '1-URGENT' 
    and isv.o_orderpriority <> '2-HIGH' then 1 else 0 end
  ) as low_line_count 
from 
  (
    select 
      * 
    from 
      alice_lineitem 
    limit 
      $SIZE
  ) as ant, 
  (
    select 
      * 
    from 
      bob_orders 
    limit 
      $SIZE
  ) as isv 
where 
  isv.o_orderkey = ant.l_orderkey 
  and ant.l_shipmode1 in ('AIR', 'SHIP', 'RAIL') 
  and ant.l_commitdate < ant.l_receiptdate 
  and ant.l_shipdate < ant.l_commitdate 
  and ant.l_receiptdate >= STR_TO_DATE('1995-02-06', '%Y-%m-%d') 
  and ant.l_receiptdate < ADDDATE(
    STR_TO_DATE('1995-01-01', '%Y-%m-%d'), 
    interval 1 year
  ) 
group by 
  ant.l_shipmode;

HERE
)

S5=$(
cat<<HERE
SELECT 
  ant.l_returnflag, 
  isv.l_linestatus, 
  sum(ant.l_quantity) AS sum_qty, 
  sum(ant.l_extendedprice) AS sum_base_price, 
  sum(
    ant.l_extendedprice * (1 - ant.l_discount)
  ) AS sum_disc_price, 
  sum(
    ant.l_extendedprice * (1 - ant.l_discount) * (1 + ant.l_tax)
  ) AS sum_charge, 
  sum(ant.l_quantity)/ count(*) AS avg_qty, 
  sum(ant.l_extendedprice)/ count(*) AS avg_price, 
  sum(ant.l_discount)/ count(*) AS avg_disc, 
  count(*) AS count_order 
FROM 
  (
    select 
      * 
    from 
      alice_lineitem 
    limit 
      $SIZE
  ) AS ant 
  JOIN (
    select 
      * 
    from 
      bob_lineitem 
    limit 
      $SIZE
  ) AS isv ON ant.l_orderkey = isv.l_orderkey 
WHERE 
  ant.l_shipdate <= SUBDATE(
    STR_TO_DATE('1996-01-01', '%Y-%m-%d'), 
    INTERVAL 37 DAY
  ) 
GROUP BY 
  ant.l_returnflag, 
  isv.l_linestatus
HERE
)

OUTPUT=(log-s"$QUERY"-"$TPCH".txt)

docker compose -p vldb logs -n 0 -f > $OUTPUT &
pid=$!

ALL_SQL=("" "$S1" "$S2" "$S3" "$S4" "$S5")
SQL=${ALL_SQL[$QUERY]}

docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"$SQL\" --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 0 --timeout 3000000000"

sleep 1

kill $pid

SHOW_PLAN=0

if [ $SHOW_PLAN -eq 1 ]; then
    echo "**Graph:**"
    echo "\`\`\`"
    sed -n '/alice.*digraph/,/| $/p' $OUTPUT | cut -d\| -f2
    echo "\`\`\`"
    echo
    echo "**Alice's Costs:**"
    echo "\`\`\`"
    grep alice $OUTPUT | grep node.*op.*cost.* -o
    echo "\`\`\`"
    echo
    echo "**Bob's Costs**"
    echo "\`\`\`"
    grep bob $OUTPUT | grep node.*op.*cost.* -o
    echo "\`\`\`"
fi