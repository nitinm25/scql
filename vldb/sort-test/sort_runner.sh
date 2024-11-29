bazel run //vldb/sort-test:sort -c opt -- --numel=1000
bazel run //vldb/sort-test:sort -c opt -- --numel=10000
bazel run //vldb/sort-test:sort -c opt -- --numel=100000
bazel run //vldb/sort-test:sort -c opt -- --numel=1000000
