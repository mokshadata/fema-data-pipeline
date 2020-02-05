#!/usr/bin/env bash

# TODO would be nice to parameterize this some more, but leaving as is for now.

grid_size=10000
x_min=-10730000
x_max=-10490000
y_min=3360000
y_max=3600000

# x_min=-10735000 #-10735650
# x_max=-10585000 #-10582914.33
# y_min=3300000 #3304875
# y_max=3460000 #3453119.14

for x_step_min in $(eval echo {$x_min..$x_max..$grid_size}); do
  for y_step_min in $(eval echo {$y_min..$y_max..$grid_size}); do

    x_step_max=$(($x_step_min + $grid_size))
    y_step_max=$(($y_step_min + $grid_size))

    rest_url="https://hazards.fema.gov/gis/nfhl/rest/services/FIRMette/NFHLREST_FIRMette/MapServer/27/query"

    query_string_start="?f=geojson&returnGeometry=true&spatialRel=esriSpatialRelIntersects&"
    query_string_bounds="geometry=%7B%22xmin%22%3A${x_step_min}%2C%22ymin%22%3A${y_step_min}%2C%22xmax%22%3A${x_step_max}%2C%22ymax%22%3A${y_step_max}"
    query_string_end="%2C%22spatialReference%22%3A%7B%22wkid%22%3A102100%7D%7D&geometryType=esriGeometryEnvelope&inSR=102100&outFields=OBJECTID%2CDFIRM_ID%2CVERSION_ID%2CFLD_AR_ID%2CSTUDY_TYP%2CFLD_ZONE%2CZONE_SUBTY%2CSFHA_TF%2CSTATIC_BFE%2CV_DATUM%2CDEPTH%2CLEN_UNIT%2CVELOCITY%2CVEL_UNIT%2CAR_REVERT%2CAR_SUBTRV%2CBFE_REVERT%2CDEP_REVERT%2CDUAL_ZONE%2CSOURCE_CIT%2CGFID&outSR=102100"

    firmette_rest_url_bounded="${rest_url}${query_string_start}${query_string_bounds}${query_string_end}"
    filename="./data/${x_step_min}-${y_step_min}-to-${x_step_max}-${y_step_max}.geojson"

    if [ -f "$filename" ]; then
      echo "$filename exists, skipping."
    else 
      echo "$filename does not exist, query."
      wget -c -O "${filename}" "${firmette_rest_url_bounded}"
    fi

  done
done