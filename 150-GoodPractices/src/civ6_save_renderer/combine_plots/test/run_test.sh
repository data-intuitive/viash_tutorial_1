#!/usr/bin/env bash

set -e

# Run our component
png_files=`ls *.png`
png_args=""
for i in "$png_files"; do
  png_args="$png_args $i"
done
png_args_parsed=`echo -n $png_args | sed 's/ /:/g'`

combine_plots -i "$png_args_parsed" -o output.webm --framerate 1

[[ ! -f output.webm ]] && echo "No output generated!" && exit 1

echo ">>> Test finished successfully"
