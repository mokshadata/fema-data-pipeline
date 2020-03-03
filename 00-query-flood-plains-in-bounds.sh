#!/usr/bin/env bash

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

if [ "${1}" != "--source-only" ]; then
  query_flood_plains_in_bounds $1 $2 $3 $4 $5
fi