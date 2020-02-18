#!/usr/bin/env bash

# TODO would be nice to parameterize this some more, but leaving as is for now.

# curl http://epsg.io/trans?data=-96.873,29.054;-95.889,29.881&s_srs=4326&&t_srs=3857
# curl 'http://epsg.io/trans?data=-94.680,29.791;-94.596,29.892&s_srs=4326&&t_srs=3857' | jq '.[].x,.[].y | tonumber / 10000 | floor * 10000'

iterate_over_bounds() {
  local x_min=$1
  local y_min=$2

  local x_max=$3
  local y_max=$4

  local grid_size=$5

  shift 5

  for x_step in $(eval echo {$x_min..$x_max..$grid_size}); do
    for y_step in $(eval echo {$y_min..$y_max..$grid_size}); do
      "$@" $x_step $y_step $(($x_step + $grid_size)) $(($y_step + $grid_size)) $grid_size
    done
  done
}

do_if_no_file() {

  local filename=$1
  shift;

  if [ -f "$filename" ]; then
    echo "$filename exists, skipping."
  else 
    echo "$filename does not exist, do stuff."
    echo $@
    "$@"
  fi
}

query_flood_plains_in_bounds() {

  local x=$1
  local y=$2

  local x_bound=$3
  local y_bound=$4

  local filename="./data/${x}-${y}-to-${x_bound}-${y_bound}.geojson"

  local rest_url="https://hazards.fema.gov/gis/nfhl/rest/services/FIRMette/NFHLREST_FIRMette/MapServer/27/query"

  local query_string_start="?f=geojson&returnGeometry=true&spatialRel=esriSpatialRelIntersects&"
  local query_string_bounds="geometry=%7B%22xmin%22%3A${x}%2C%22ymin%22%3A${y}%2C%22xmax%22%3A${x_bound}%2C%22ymax%22%3A${y_bound}"
  local query_string_end="%2C%22spatialReference%22%3A%7B%22wkid%22%3A102100%7D%7D&geometryType=esriGeometryEnvelope&inSR=102100&outFields=OBJECTID%2CDFIRM_ID%2CVERSION_ID%2CFLD_AR_ID%2CSTUDY_TYP%2CFLD_ZONE%2CZONE_SUBTY%2CSFHA_TF%2CSTATIC_BFE%2CV_DATUM%2CDEPTH%2CLEN_UNIT%2CVELOCITY%2CVEL_UNIT%2CAR_REVERT%2CAR_SUBTRV%2CBFE_REVERT%2CDEP_REVERT%2CDUAL_ZONE%2CSOURCE_CIT%2CGFID&outSR=102100"

  local firmette_rest_url_bounded="${rest_url}${query_string_start}${query_string_bounds}${query_string_end}"

  do_if_no_file $filename wget -c -O "${filename}" "${firmette_rest_url_bounded}"
}

query_flood_plains() {

  local x_min=$1
  local y_min=$2

  local x_max=$3
  local y_max=$4

  local grid_size=$5

  iterate_over_bounds $x_min $y_min $x_max $y_max $grid_size query_flood_plains_in_bounds
}

query_with_grid_size_change() {
  local x=$1
  local y=$2

  local x_max=$3
  local y_max=$4

  local grid_size=$5
  local grid_size_precise=$(($grid_size/10))

  local filename="./data/${x}-${y}-to-${x_max}-${y_max}.geojson"

  do_if_no_file $filename query_flood_plains $x $y $x_max $y_max $grid_size_precise
}

query_flood_plains_with_precise() {
  local x=$1
  local y=$2

  local x_max=$3
  local y_max=$4

  local grid_size=$5

  iterate_over_bounds $x $y $x_max $y_max $grid_size query_with_grid_size_change
}

query_flood_plains $1 $2 $3 $4 $5