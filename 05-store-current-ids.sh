#!/usr/bin/env bash

cat outputs/merged-data.geojson | jq '.features | .[] | .id' > ./artifacts/---stored-ids.txt