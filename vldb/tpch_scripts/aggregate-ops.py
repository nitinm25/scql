import sys
import re
from collections import defaultdict

#!/usr/bin/env python3

def parse_file(file_path):
    costs = {'alice': defaultdict(int), 'bob': defaultdict(int)}
    with open(file_path, 'r') as file:
        for line in file:
            for name in ('alice', 'bob'):
                if name in line and 'node' in line and 'cost' in line and 'finished' in line:
                    match = re.search(r'op\((.*?)\), cost\((\d+)\)ms', line)
                    if match:
                        op = match.group(1)
                        cost = int(match.group(2))
                        costs[name][op] += cost
    return costs

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: ./aggregate-ops.py <file_path>")
        sys.exit(1)

    file_path = sys.argv[1]
    result = parse_file(file_path)
    for name, ops in result.items():
        print(f"Results for {name}:")
        for op, total_cost in sorted(ops.items(), key=lambda x: x[1], reverse=True):
            print(f"  {op}: {total_cost}ms")