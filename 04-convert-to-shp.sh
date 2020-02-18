#!/usr/bin/env bash

ogr2ogr -s_srs EPSG:3857 -t_srs EPSG:4326 -f "ESRI Shapefile" ./outputs/merged-data.shp "./outputs/merged-data.geojson"