#!/bin/bash

SIZE=100000

OUTPUT=log-s3-q14.txt

QUERY=$(
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

echo "Starting S3 Q14"

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
