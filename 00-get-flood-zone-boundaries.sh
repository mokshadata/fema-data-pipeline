#!/usr/bin/env bash

# TODO would be nice to parameterize this some more, but leaving as is for now.

# curl http://epsg.io/trans?data=-96.873,29.054;-95.889,29.881&s_srs=4326&&t_srs=3857
# curl 'http://epsg.io/trans?data=-94.680,29.791;-94.596,29.892&s_srs=4326&&t_srs=3857' | jq '.[].x,.[].y | tonumber / 10000 | floor * 10000'

. ./00-query-flood-plains-in-bounds.sh --source-only

iterate_over_bounds() {
  local x_min=$1
  local y_min=$2

  local x_max=$3
  local y_max=$4

  local grid_size=$5

  shift 5

  parallel \
    -a <(seq ${x_min} ${grid_size} $(($x_max - $grid_size))) \
    -a <(seq ${y_min} ${grid_size} $(($y_max - $grid_size))) \
    -P 4 "$@" {1} {2} $grid_size
}

query_flood_plains() {

  local x_min=$1
  local y_min=$2

  local x_max=$3
  local y_max=$4

  local grid_size=$5

  iterate_over_bounds $x_min $y_min $x_max $y_max $grid_size ./00-query-flood-plains-in-bounds.sh
}

query_flood_plains $1 $2 $3 $4 $5