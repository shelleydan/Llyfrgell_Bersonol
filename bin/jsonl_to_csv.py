import json
import csv
import os

# Get paths from environment variables (in bash: export workdir=/path/to/dir)
workdir = os.environ.get("workdir", ".")
input_path = os.path.join(workdir, "metadata.jsonl")
output_path = os.path.join(workdir, "metadata.csv")

# Step 1: Read and merge reports
merged_reports = []
with open(input_path, "r", encoding="utf-8") as f:
    for line in f:
        if line.strip():
            obj = json.loads(line)
            merged_reports.extend(obj.get("reports", []))

# Step 2: Flatten nested dictionaries
def flatten(d, parent_key='', sep='.'):
    items = []
    for k, v in d.items():
        new_key = f"{parent_key}{sep}{k}" if parent_key else k
        if isinstance(v, dict):
            items.extend(flatten(v, new_key, sep=sep).items())
        elif isinstance(v, list):
            if all(isinstance(i, dict) and "name" in i and "value" in i for i in v):
                items.extend((f"{new_key}.{i['name']}", i['value']) for i in v)
            else:
                items.append((new_key, json.dumps(v)))
        else:
            items.append((new_key, v))
    return dict(items)

flat_reports = [flatten(r) for r in merged_reports]
all_keys = sorted(set().union(*(r.keys() for r in flat_reports)))

# Step 3: Write to CSV
with open(output_path, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=all_keys)
    writer.writeheader()
    for row in flat_reports:
        writer.writerow(row)

print(f"Merged {len(merged_reports)} reports into CSV: {output_path}")

