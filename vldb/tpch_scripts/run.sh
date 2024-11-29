set +ex

docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select sum(l_extendedprice*l_discount) as revenue from ((select l_extendedprice, l_discount, l_shipdate, l_quantity from alice_lineitem limit 500) union all (select l_extendedprice, l_discount, l_shipdate, l_quantity from bob_lineitem limit 500)) as lineitem where l_shipdate >= STR_TO_DATE('1995-02-06','%Y-%m-%d') and l_shipdate < ADDDATE(STR_TO_DATE('1995-01-01','%Y-%m-%d'), interval 1 year) and l_discount >= 0.05 - 0.01 and l_discount <= 0.05 + 0.01 and l_quantity < 60;\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select l_returnflag, l_linestatus, sum(l_quantity) as sum_qty, sum(l_extendedprice) as sum_base_price, sum(l_extendedprice * (1 - l_discount)) as sum_disc_price, sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) as sum_charge, sum(l_quantity)/count(*) as avg_qty, sum(l_extendedprice)/count(*) as avg_price, sum(l_discount)/count(*) as avg_disc, count(*) as count_order from ((select l_returnflag, l_linestatus, l_quantity, l_extendedprice, l_shipdate, l_discount, l_tax from alice_lineitem limit 500) union all (select l_returnflag, l_linestatus, l_quantity, l_extendedprice, l_shipdate, l_discount, l_tax from bob_lineitem limit 500)) as lineitem where l_shipdate <= SUBDATE(STR_TO_DATE('1996-01-01','%Y-%m-%d'), INTERVAL 37 DAY) group by l_returnflag, l_linestatus;\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select 100.00 * sum(case when isv.type_promo then ant.l_extendedprice*(1-ant.l_discount) else 0.0 end) / sum(ant.l_extendedprice * (1 - ant.l_discount)) as promo_revenue from (select * from alice_lineitem limit 1000) as ant join (select p_partkey, p_type LIKE 'PROMO%' as type_promo from bob_part limit 1000) as isv where ant.l_partkey = isv.p_partkey and ant.l_shipdate >= STR_TO_DATE('1995-02-06','%Y-%m-%d') and ant.l_shipdate <ADDDATE(STR_TO_DATE('1996-01-01','%Y-%m-%d'), interval 11 MONTH);\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select ant.l_shipmode, sum(case when isv.o_orderpriority ='1-URGENT' or isv.o_orderpriority ='2-HIGH' then 1 else 0 end) as high_line_count, sum(case when isv.o_orderpriority <> '1-URGENT' and isv.o_orderpriority <> '2-HIGH' then 1 else 0 end) as low_line_count from (select * from alice_lineitem limit 1000) as ant, (select * from bob_orders limit 1000) as isv where isv.o_orderkey = ant.l_orderkey and ant.l_shipmode1 in ('AIR', 'SHIP','RAIL') and ant.l_commitdate < ant.l_receiptdate and ant.l_shipdate < ant.l_commitdate and ant.l_receiptdate >= STR_TO_DATE('1995-02-06','%Y-%m-%d') and ant.l_receiptdate < ADDDATE(STR_TO_DATE('1995-01-01','%Y-%m-%d'), interval 1 year) group by ant.l_shipmode;\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"SELECT ant.l_returnflag,isv.l_linestatus,sum(ant.l_quantity) AS sum_qty,sum(ant.l_extendedprice) AS sum_base_price,sum(ant.l_extendedprice * (1 - ant.l_discount)) AS sum_disc_price,sum(ant.l_extendedprice * (1 - ant.l_discount) * (1 + ant.l_tax)) AS sum_charge,sum(ant.l_quantity)/count(*) AS avg_qty,sum(ant.l_extendedprice)/count(*) AS avg_price,sum(ant.l_discount)/count(*) AS avg_disc,count(*) AS count_order FROM (select * from alice_lineitem limit 1000) AS ant JOIN (select * from bob_lineitem limit 1000) AS isv ON ant.l_orderkey = isv.l_orderkey WHERE ant.l_shipdate <= SUBDATE(STR_TO_DATE('1996-01-01','%Y-%m-%d'), INTERVAL 37 DAY) GROUP BY ant.l_returnflag,isv.l_linestatus\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"

docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select sum(l_extendedprice*l_discount) as revenue from ((select l_extendedprice, l_discount, l_shipdate, l_quantity from alice_lineitem limit 5000) union all (select l_extendedprice, l_discount, l_shipdate, l_quantity from bob_lineitem limit 5000)) as lineitem where l_shipdate >= STR_TO_DATE('1995-02-06','%Y-%m-%d') and l_shipdate < ADDDATE(STR_TO_DATE('1995-01-01','%Y-%m-%d'), interval 1 year) and l_discount >= 0.05 - 0.01 and l_discount <= 0.05 + 0.01 and l_quantity < 60;\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select l_returnflag, l_linestatus, sum(l_quantity) as sum_qty, sum(l_extendedprice) as sum_base_price, sum(l_extendedprice * (1 - l_discount)) as sum_disc_price, sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) as sum_charge, sum(l_quantity)/count(*) as avg_qty, sum(l_extendedprice)/count(*) as avg_price, sum(l_discount)/count(*) as avg_disc, count(*) as count_order from ((select l_returnflag, l_linestatus, l_quantity, l_extendedprice, l_shipdate, l_discount, l_tax from alice_lineitem limit 5000) union all (select l_returnflag, l_linestatus, l_quantity, l_extendedprice, l_shipdate, l_discount, l_tax from bob_lineitem limit 5000)) as lineitem where l_shipdate <= SUBDATE(STR_TO_DATE('1996-01-01','%Y-%m-%d'), INTERVAL 37 DAY) group by l_returnflag, l_linestatus;\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select 100.00 * sum(case when isv.type_promo then ant.l_extendedprice*(1-ant.l_discount) else 0.0 end) / sum(ant.l_extendedprice * (1 - ant.l_discount)) as promo_revenue from (select * from alice_lineitem limit 10000) as ant join (select p_partkey, p_type LIKE 'PROMO%' as type_promo from bob_part limit 10000) as isv where ant.l_partkey = isv.p_partkey and ant.l_shipdate >= STR_TO_DATE('1995-02-06','%Y-%m-%d') and ant.l_shipdate <ADDDATE(STR_TO_DATE('1996-01-01','%Y-%m-%d'), interval 11 MONTH);\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select ant.l_shipmode, sum(case when isv.o_orderpriority ='1-URGENT' or isv.o_orderpriority ='2-HIGH' then 1 else 0 end) as high_line_count, sum(case when isv.o_orderpriority <> '1-URGENT' and isv.o_orderpriority <> '2-HIGH' then 1 else 0 end) as low_line_count from (select * from alice_lineitem limit 10000) as ant, (select * from bob_orders limit 10000) as isv where isv.o_orderkey = ant.l_orderkey and ant.l_shipmode1 in ('AIR', 'SHIP','RAIL') and ant.l_commitdate < ant.l_receiptdate and ant.l_shipdate < ant.l_commitdate and ant.l_receiptdate >= STR_TO_DATE('1995-02-06','%Y-%m-%d') and ant.l_receiptdate < ADDDATE(STR_TO_DATE('1995-01-01','%Y-%m-%d'), interval 1 year) group by ant.l_shipmode;\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"SELECT ant.l_returnflag,isv.l_linestatus,sum(ant.l_quantity) AS sum_qty,sum(ant.l_extendedprice) AS sum_base_price,sum(ant.l_extendedprice * (1 - ant.l_discount)) AS sum_disc_price,sum(ant.l_extendedprice * (1 - ant.l_discount) * (1 + ant.l_tax)) AS sum_charge,sum(ant.l_quantity)/count(*) AS avg_qty,sum(ant.l_extendedprice)/count(*) AS avg_price,sum(ant.l_discount)/count(*) AS avg_disc,count(*) AS count_order FROM (select * from alice_lineitem limit 10000) AS ant JOIN (select * from bob_lineitem limit 10000) AS isv ON ant.l_orderkey = isv.l_orderkey WHERE ant.l_shipdate <= SUBDATE(STR_TO_DATE('1996-01-01','%Y-%m-%d'), INTERVAL 37 DAY) GROUP BY ant.l_returnflag,isv.l_linestatus\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"

docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select sum(l_extendedprice*l_discount) as revenue from ((select l_extendedprice, l_discount, l_shipdate, l_quantity from alice_lineitem limit 50000) union all (select l_extendedprice, l_discount, l_shipdate, l_quantity from bob_lineitem limit 50000)) as lineitem where l_shipdate >= STR_TO_DATE('1995-02-06','%Y-%m-%d') and l_shipdate < ADDDATE(STR_TO_DATE('1995-01-01','%Y-%m-%d'), interval 1 year) and l_discount >= 0.05 - 0.01 and l_discount <= 0.05 + 0.01 and l_quantity < 60;\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select l_returnflag, l_linestatus, sum(l_quantity) as sum_qty, sum(l_extendedprice) as sum_base_price, sum(l_extendedprice * (1 - l_discount)) as sum_disc_price, sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) as sum_charge, sum(l_quantity)/count(*) as avg_qty, sum(l_extendedprice)/count(*) as avg_price, sum(l_discount)/count(*) as avg_disc, count(*) as count_order from ((select l_returnflag, l_linestatus, l_quantity, l_extendedprice, l_shipdate, l_discount, l_tax from alice_lineitem limit 50000) union all (select l_returnflag, l_linestatus, l_quantity, l_extendedprice, l_shipdate, l_discount, l_tax from bob_lineitem limit 50000)) as lineitem where l_shipdate <= SUBDATE(STR_TO_DATE('1996-01-01','%Y-%m-%d'), INTERVAL 37 DAY) group by l_returnflag, l_linestatus;\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select 100.00 * sum(case when isv.type_promo then ant.l_extendedprice*(1-ant.l_discount) else 0.0 end) / sum(ant.l_extendedprice * (1 - ant.l_discount)) as promo_revenue from (select * from alice_lineitem limit 100000) as ant join (select p_partkey, p_type LIKE 'PROMO%' as type_promo from bob_part limit 100000) as isv where ant.l_partkey = isv.p_partkey and ant.l_shipdate >= STR_TO_DATE('1995-02-06','%Y-%m-%d') and ant.l_shipdate <ADDDATE(STR_TO_DATE('1996-01-01','%Y-%m-%d'), interval 11 MONTH);\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select ant.l_shipmode, sum(case when isv.o_orderpriority ='1-URGENT' or isv.o_orderpriority ='2-HIGH' then 1 else 0 end) as high_line_count, sum(case when isv.o_orderpriority <> '1-URGENT' and isv.o_orderpriority <> '2-HIGH' then 1 else 0 end) as low_line_count from (select * from alice_lineitem limit 100000) as ant, (select * from bob_orders limit 100000) as isv where isv.o_orderkey = ant.l_orderkey and ant.l_shipmode1 in ('AIR', 'SHIP','RAIL') and ant.l_commitdate < ant.l_receiptdate and ant.l_shipdate < ant.l_commitdate and ant.l_receiptdate >= STR_TO_DATE('1995-02-06','%Y-%m-%d') and ant.l_receiptdate < ADDDATE(STR_TO_DATE('1995-01-01','%Y-%m-%d'), interval 1 year) group by ant.l_shipmode;\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"SELECT ant.l_returnflag,isv.l_linestatus,sum(ant.l_quantity) AS sum_qty,sum(ant.l_extendedprice) AS sum_base_price,sum(ant.l_extendedprice * (1 - ant.l_discount)) AS sum_disc_price,sum(ant.l_extendedprice * (1 - ant.l_discount) * (1 + ant.l_tax)) AS sum_charge,sum(ant.l_quantity)/count(*) AS avg_qty,sum(ant.l_extendedprice)/count(*) AS avg_price,sum(ant.l_discount)/count(*) AS avg_disc,count(*) AS count_order FROM (select * from alice_lineitem limit 100000) AS ant JOIN (select * from bob_lineitem limit 100000) AS isv ON ant.l_orderkey = isv.l_orderkey WHERE ant.l_shipdate <= SUBDATE(STR_TO_DATE('1996-01-01','%Y-%m-%d'), INTERVAL 37 DAY) GROUP BY ant.l_returnflag,isv.l_linestatus\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"

docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select sum(l_extendedprice*l_discount) as revenue from ((select l_extendedprice, l_discount, l_shipdate, l_quantity from alice_lineitem limit 500000) union all (select l_extendedprice, l_discount, l_shipdate, l_quantity from bob_lineitem limit 500000)) as lineitem where l_shipdate >= STR_TO_DATE('1995-02-06','%Y-%m-%d') and l_shipdate < ADDDATE(STR_TO_DATE('1995-01-01','%Y-%m-%d'), interval 1 year) and l_discount >= 0.05 - 0.01 and l_discount <= 0.05 + 0.01 and l_quantity < 60;\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select l_returnflag, l_linestatus, sum(l_quantity) as sum_qty, sum(l_extendedprice) as sum_base_price, sum(l_extendedprice * (1 - l_discount)) as sum_disc_price, sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) as sum_charge, sum(l_quantity)/count(*) as avg_qty, sum(l_extendedprice)/count(*) as avg_price, sum(l_discount)/count(*) as avg_disc, count(*) as count_order from ((select l_returnflag, l_linestatus, l_quantity, l_extendedprice, l_shipdate, l_discount, l_tax from alice_lineitem limit 500000) union all (select l_returnflag, l_linestatus, l_quantity, l_extendedprice, l_shipdate, l_discount, l_tax from bob_lineitem limit 500000)) as lineitem where l_shipdate <= SUBDATE(STR_TO_DATE('1996-01-01','%Y-%m-%d'), INTERVAL 37 DAY) group by l_returnflag, l_linestatus;\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select 100.00 * sum(case when isv.type_promo then ant.l_extendedprice*(1-ant.l_discount) else 0.0 end) / sum(ant.l_extendedprice * (1 - ant.l_discount)) as promo_revenue from (select * from alice_lineitem limit 1000000) as ant join (select p_partkey, p_type LIKE 'PROMO%' as type_promo from bob_part limit 1000000) as isv where ant.l_partkey = isv.p_partkey and ant.l_shipdate >= STR_TO_DATE('1995-02-06','%Y-%m-%d') and ant.l_shipdate <ADDDATE(STR_TO_DATE('1996-01-01','%Y-%m-%d'), interval 11 MONTH);\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select ant.l_shipmode, sum(case when isv.o_orderpriority ='1-URGENT' or isv.o_orderpriority ='2-HIGH' then 1 else 0 end) as high_line_count, sum(case when isv.o_orderpriority <> '1-URGENT' and isv.o_orderpriority <> '2-HIGH' then 1 else 0 end) as low_line_count from (select * from alice_lineitem limit 1000000) as ant, (select * from bob_orders limit 1000000) as isv where isv.o_orderkey = ant.l_orderkey and ant.l_shipmode1 in ('AIR', 'SHIP','RAIL') and ant.l_commitdate < ant.l_receiptdate and ant.l_shipdate < ant.l_commitdate and ant.l_receiptdate >= STR_TO_DATE('1995-02-06','%Y-%m-%d') and ant.l_receiptdate < ADDDATE(STR_TO_DATE('1995-01-01','%Y-%m-%d'), interval 1 year) group by ant.l_shipmode;\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"SELECT ant.l_returnflag,isv.l_linestatus,sum(ant.l_quantity) AS sum_qty,sum(ant.l_extendedprice) AS sum_base_price,sum(ant.l_extendedprice * (1 - ant.l_discount)) AS sum_disc_price,sum(ant.l_extendedprice * (1 - ant.l_discount) * (1 + ant.l_tax)) AS sum_charge,sum(ant.l_quantity)/count(*) AS avg_qty,sum(ant.l_extendedprice)/count(*) AS avg_price,sum(ant.l_discount)/count(*) AS avg_disc,count(*) AS count_order FROM (select * from alice_lineitem limit 1000000) AS ant JOIN (select * from bob_lineitem limit 1000000) AS isv ON ant.l_orderkey = isv.l_orderkey WHERE ant.l_shipdate <= SUBDATE(STR_TO_DATE('1996-01-01','%Y-%m-%d'), INTERVAL 37 DAY) GROUP BY ant.l_returnflag,isv.l_linestatus\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"

docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select sum(l_extendedprice*l_discount) as revenue from ((select l_extendedprice, l_discount, l_shipdate, l_quantity from alice_lineitem limit 5000000) union all (select l_extendedprice, l_discount, l_shipdate, l_quantity from bob_lineitem limit 5000000)) as lineitem where l_shipdate >= STR_TO_DATE('1995-02-06','%Y-%m-%d') and l_shipdate < ADDDATE(STR_TO_DATE('1995-01-01','%Y-%m-%d'), interval 1 year) and l_discount >= 0.05 - 0.01 and l_discount <= 0.05 + 0.01 and l_quantity < 60;\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select l_returnflag, l_linestatus, sum(l_quantity) as sum_qty, sum(l_extendedprice) as sum_base_price, sum(l_extendedprice * (1 - l_discount)) as sum_disc_price, sum(l_extendedprice * (1 - l_discount) * (1 + l_tax)) as sum_charge, sum(l_quantity)/count(*) as avg_qty, sum(l_extendedprice)/count(*) as avg_price, sum(l_discount)/count(*) as avg_disc, count(*) as count_order from ((select l_returnflag, l_linestatus, l_quantity, l_extendedprice, l_shipdate, l_discount, l_tax from alice_lineitem limit 5000000) union all (select l_returnflag, l_linestatus, l_quantity, l_extendedprice, l_shipdate, l_discount, l_tax from bob_lineitem limit 5000000)) as lineitem where l_shipdate <= SUBDATE(STR_TO_DATE('1996-01-01','%Y-%m-%d'), INTERVAL 37 DAY) group by l_returnflag, l_linestatus;\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select 100.00 * sum(case when isv.type_promo then ant.l_extendedprice*(1-ant.l_discount) else 0.0 end) / sum(ant.l_extendedprice * (1 - ant.l_discount)) as promo_revenue from (select * from alice_lineitem limit 10000000) as ant join (select p_partkey, p_type LIKE 'PROMO%' as type_promo from bob_part limit 10000000) as isv where ant.l_partkey = isv.p_partkey and ant.l_shipdate >= STR_TO_DATE('1995-02-06','%Y-%m-%d') and ant.l_shipdate <ADDDATE(STR_TO_DATE('1996-01-01','%Y-%m-%d'), interval 11 MONTH);\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"select ant.l_shipmode, sum(case when isv.o_orderpriority ='1-URGENT' or isv.o_orderpriority ='2-HIGH' then 1 else 0 end) as high_line_count, sum(case when isv.o_orderpriority <> '1-URGENT' and isv.o_orderpriority <> '2-HIGH' then 1 else 0 end) as low_line_count from (select * from alice_lineitem limit 10000000) as ant, (select * from bob_orders limit 10000000) as isv where isv.o_orderkey = ant.l_orderkey and ant.l_shipmode1 in ('AIR', 'SHIP','RAIL') and ant.l_commitdate < ant.l_receiptdate and ant.l_shipdate < ant.l_commitdate and ant.l_receiptdate >= STR_TO_DATE('1995-02-06','%Y-%m-%d') and ant.l_receiptdate < ADDDATE(STR_TO_DATE('1995-01-01','%Y-%m-%d'), interval 1 year) group by ant.l_shipmode;\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"
docker exec -it vldb-broker_bob-1 bash -c "/home/admin/bin/brokerctl run \"SELECT ant.l_returnflag,isv.l_linestatus,sum(ant.l_quantity) AS sum_qty,sum(ant.l_extendedprice) AS sum_base_price,sum(ant.l_extendedprice * (1 - ant.l_discount)) AS sum_disc_price,sum(ant.l_extendedprice * (1 - ant.l_discount) * (1 + ant.l_tax)) AS sum_charge,sum(ant.l_quantity)/count(*) AS avg_qty,sum(ant.l_extendedprice)/count(*) AS avg_price,sum(ant.l_discount)/count(*) AS avg_disc,count(*) AS count_order FROM (select * from alice_lineitem limit 10000000) AS ant JOIN (select * from bob_lineitem limit 10000000) AS isv ON ant.l_orderkey = isv.l_orderkey WHERE ant.l_shipdate <= SUBDATE(STR_TO_DATE('1996-01-01','%Y-%m-%d'), INTERVAL 37 DAY) GROUP BY ant.l_returnflag,isv.l_linestatus\"  --project-id \"vldb_test\" --host http://localhost:8080 --agg-type 1  --timeout 3000000000"