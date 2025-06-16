#!/bin/bash
mongoimport \
  --uri mongodb://localhost:27017 \
  --db agile_data_science \
  --collection origin_dest_distances \
  --file /docker-entrypoint-initdb.d/origin_dest_distances.jsonl \
  --type json
