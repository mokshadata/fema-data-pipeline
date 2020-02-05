#!/usr/bin/env bash

ogr2ogr -f "ESRI Shapefile" ./outputs/result.shp "./outputs/merged-data.geojson"