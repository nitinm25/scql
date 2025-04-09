#!/bin/bash

SIZE=100000

OUTPUT=log-s4-q12.txt

QUERY=$(
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

echo "Starting S4 Q12"

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
