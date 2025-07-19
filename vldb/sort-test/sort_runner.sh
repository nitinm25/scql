echo -e "Sort: 100000\n"
bazel run //vldb/sort-test:sort_sbk -c opt -- --numel=100000
bazel run //vldb/sort-test:sort_sbk -c opt -- --numel=100000
bazel run //vldb/sort-test:sort_sbk -c opt -- --numel=100000
bazel run //vldb/sort-test:sort_sbk_valid -c opt -- --numel=100000
bazel run //vldb/sort-test:sort_sbk_valid -c opt -- --numel=100000
bazel run //vldb/sort-test:sort_sbk_valid -c opt -- --numel=100000

echo -e "Sort: 1000000\n"
bazel run //vldb/sort-test:sort_sbk -c opt -- --numel=1000000
bazel run //vldb/sort-test:sort_sbk -c opt -- --numel=1000000
bazel run //vldb/sort-test:sort_sbk -c opt -- --numel=1000000
bazel run //vldb/sort-test:sort_sbk_valid -c opt -- --numel=1000000
bazel run //vldb/sort-test:sort_sbk_valid -c opt -- --numel=1000000
bazel run //vldb/sort-test:sort_sbk_valid -c opt -- --numel=1000000

echo -e "Sort: 10000000\n"
bazel run //vldb/sort-test:sort_sbk -c opt -- --numel=10000000
bazel run //vldb/sort-test:sort_sbk -c opt -- --numel=10000000
bazel run //vldb/sort-test:sort_sbk -c opt -- --numel=10000000
bazel run //vldb/sort-test:sort_sbk_valid -c opt -- --numel=10000000
bazel run //vldb/sort-test:sort_sbk_valid -c opt -- --numel=10000000
bazel run //vldb/sort-test:sort_sbk_valid -c opt -- --numel=10000000
