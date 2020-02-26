#!/usr/bin/env bash

cat outputs/merged-data.geojson | jq '.features | .[] | .id' > ./artifacts/05-stored-ids.txt