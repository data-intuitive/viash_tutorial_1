#!/bin/bash

input_dir="data"
output_dir="output"
CIV6="target/docker/civ6_save_renderer"

mkdir -p "$output_dir"

# iterate over every Civ6Save file
for save_file in $input_dir/*.Civ6Save; do
  file_basename=$(basename $save_file)

  echo ">>>>>>> parse header '$save_file'"
  yaml_file="$output_dir/${file_basename/Civ6Save/yaml}"
  $CIV6/parse_header/parse_header -i "$save_file" -o "$yaml_file" 2>&1 > /dev/null

  echo ">>>>>>> parse map '$save_file'"
  tsv_file="$output_dir/${file_basename/Civ6Save/tsv}"
  $CIV6/parse_map/parse_map -i "$save_file" -o "$tsv_file" 2>&1 > /dev/null

  echo ">>>>>>> plot map '$save_file'"
  pdf_file="$output_dir/${file_basename/Civ6Save/pdf}"
  $CIV6/plot_map/plot_map -y "$yaml_file" -t "$tsv_file" -o "$pdf_file" 2>&1 > /dev/null

  echo ">>>>>>> convert plot '$save_file'"
  png_file="$output_dir/${file_basename/Civ6Save/png}"
  $CIV6/convert_plot/convert_plot -i "$pdf_file" -o "$png_file" 2>&1 > /dev/null
done

echo ">>>>>>>combine plots"
png_inputs=`find "$output_dir" -name "*.png" | tr '\n' ':'`
$CIV6/combine_plots/combine_plots -i "$png_inputs" -o "$output_dir/movie.webm" --framerate 1 2>&1 > /dev/null

echo ">>>>>>>DONE"
