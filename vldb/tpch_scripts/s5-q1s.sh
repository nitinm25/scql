#!/bin/bash

SIZE=100000

OUTPUT=log-s5-q1s.txt

QUERY=$(
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

echo "Starting S5 Q1*"

docker compose -p vldb logs -n 0 -f > $OUTPUT &
pid=$!

docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"$QUERY\" --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 0 --timeout 3000000000 --sgb-type 1"

sleep 1

kill $pid

echo "<details><summary><b>Plan</b></summary><p>"
echo "\`\`\`"
sed -n '/alice.*digraph/,/| $/p' $OUTPUT | cut -d\| -f2
echo "\`\`\`"
echo "</p></details>"
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
