#!/bin/bash

for q in 1 2 3 4 5; do
    ./run-log.sh $q 1000000
    sleep 10
    # ./run-log.sh $q 1000000
    # ./run-log.sh $q 1000000
done