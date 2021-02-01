#!/bin/bash

input_dir="$par_input"
temp_dir="$par_temp"
output="$par_output"

# $component_dir is target/ by default
BIN="$par_component_dir/docker/civ6_save_renderer"
# $SED resolves to GNU sed
SED=`eval "$par_sed"`

mkdir -p "$temp_dir"

function msg {
  echo ">>>>>>> $1"
}

for save_file in $input_dir/*.Civ6Save; do
  file_basename=$(basename $save_file)
  yaml_file="$temp_dir/${file_basename/Civ6Save/yaml}"
  tsv_file="$temp_dir/${file_basename/Civ6Save/tsv}"
  pdf_file="$temp_dir/${file_basename/Civ6Save/pdf}"
  png_file="$temp_dir/${file_basename/Civ6Save/png}"

  if [ ! -f "$yaml_file" ]; then
    msg "parse header '$save_file'"
    $BIN/parse_header/parse_header -i "$save_file" -o "$yaml_file"
  fi

  if [ ! -f "$tsv_file" ]; then
    msg "parse map '$save_file'"
    $BIN/parse_map/parse_map -i "$save_file" -o "$tsv_file"
  fi

  if [ ! -f "$pdf_file" ]; then
    msg "plot map '$save_file'"
    $BIN/plot_map/plot_map -y "$yaml_file" -t "$tsv_file" -o "$pdf_file"
  fi

  if [ ! -f "$png_file" ]; then
    msg "convert plot '$save_file'"
    $BIN/convert_plot/convert_plot -i "$pdf_file" -o "$png_file"
  fi
done

png_inputs=`find "$temp_dir" -name "*.png" | $SED "s#.*#&:#" | tr -d '\n' | $SED 's#:$#\n#'`

if [ ! -f "$output" ]; then
  msg "combine plots"
  $BIN/combine_plots/combine_plots -i "$png_inputs" -o "$output" --framerate 1
fi

msg "DONE"
