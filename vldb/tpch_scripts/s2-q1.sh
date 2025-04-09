#!/bin/bash

SIZE=100000

OUTPUT=log-s2-q1.txt

QUERY=$(
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

echo "Starting S2 Q1"

docker compose -p vldb logs -n 0 -f > $OUTPUT &
pid=$!

docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"$QUERY\" --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 0 --timeout 3000000000"

sleep 1

kill $pid

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
