echo -e "Sort: 1000\n"

bazel run //vldb/sort-test:sort -c opt -- --numel=1000

echo -e "\n\n\n\n"
echo -e "Sort: 10000\n"

bazel run //vldb/sort-test:sort -c opt -- --numel=10000

echo -e "\n\n\n\n"
echo -e "Sort: 100000\n"

bazel run //vldb/sort-test:sort -c opt -- --numel=100000

echo -e "\n\n\n\n"
echo -e "Sort: 1000000\n"

bazel run //vldb/sort-test:sort -c opt -- --numel=1000000
