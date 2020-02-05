#!/usr/bin/env bash

sed -i '0,/^/s//{"type":"FeatureCollection","crs":{"type":"name","properties":{"name":"EPSG:3857"}},"features":/; $ s/$/}/' hole.json