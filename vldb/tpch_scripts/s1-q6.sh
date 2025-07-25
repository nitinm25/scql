#!/bin/bash

SIZE=100000

OUTPUT=log-s1-q6.txt

QUERY=$(
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

echo "Starting S1 Q6"

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
