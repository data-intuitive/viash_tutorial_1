---
author: Data Intuitive
date: Tuesday - January 26, 2021
mainfont: Roboto Condensed
monobackgroundcolor: lightgrey
monofont: Source Code Pro
monofontoptions: Scale=0.7
title: Viash Workshop 1 - Running the pipeline
---

# Introduction

In this section, we demonstrate how to run the full pipeline for the
Civilization postgame generation.

# Building the namespace

Let's build the namespace from the `src` directory in the root of this
project/repository again, so we keep this directory self-contained:

``` {.sh}
> viash ns build \
+   -n civ6_save_renderer \
+   -s ../src \
+   -p docker
Exporting ../src/civ6_save_renderer/combine_plots/ (civ6_save_renderer) =docker=> target/docker/civ6_save_renderer/combine_plots
Exporting ../src/civ6_save_renderer/convert_plot/ (civ6_save_renderer) =docker=> target/docker/civ6_save_renderer/convert_plot
Exporting ../src/civ6_save_renderer/plot_map/ (civ6_save_renderer) =docker=> target/docker/civ6_save_renderer/plot_map
Exporting ../src/civ6_save_renderer/parse_map/ (civ6_save_renderer) =docker=> target/docker/civ6_save_renderer/parse_map
Exporting ../src/civ6_save_renderer/parse_header/ (civ6_save_renderer) =docker=> target/docker/civ6_save_renderer/parse_header
```

The result is stored under `target/docker` because we chose to only
build the `docker` platform executables.

We have to run the *setup* for the containers that are not just
available on Docker Hub. This can be done in one go by using the
following CLI:

``` {.sh}
cd ..
viash ns build \
  -n civ6_save_renderer \
  -s ../src \
  -p docker
```

Or, we can run them one-by-one.

# A pipeline script

A small dataset with only a few steps from a game are stored under
`../data/`. We will use that as a source for the pipeline. Furthermore,
we'll *eat our own dogfoot* and create a
[viash](https://github.com/data-intuitive/viash) component for the
pipeline code itself:

`src/civ6_save_renderer/pipeline/config.vsh.yaml`:

``` {.yaml}
functionality:
  name: pipeline
  arguments:
    - name: "--input"
      alternatives: [ "-i" ]
      type: file
      description: "Input directory with savegames"
      required: true
    - name: "--temp"
      alternatives: [ "-t" ]
      type: file
      description: "Temporary directory"
      direction: output
      default: "temp"
    - name: "--output"
      alternatives: [ "-o" ]
      type: file
      description: "Output video filename"
      direction: output
      required: true
    - name: "--sed"
      type: string
      description: "Path to the GNU version of sed"
      default: 'which gsed || echo -n "/usr/bin/sed"'
    - name: "--component_dir"
      type: file
      description: "Path to the namespace target dir"
      default: "./target"
  resources:
    - type: bash_script
      path: script.sh
platforms:
  - type: native
```

With the following script:

`src/civ6_save_renderer/pipeline/script.sh`:

``` {.sh}
#!/bin/bash

input_dir="$par_input"
temp_dir="$par_temp"
output="$par_output"

# $BIN is target/ by default
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
```

A few remarks are in place here:

> > TODO

Build the `pipeline` component:

``` {.sh}
> viash ns build -p native
Exporting src/civ6_save_renderer/pipeline/ (civ6_save_renderer) =native=> target/native/civ6_save_renderer/pipeline
```

# Running the pipeline

Make sure you have run the required `--setup`'s. Then:

``` {.sh}
> target/native/civ6_save_renderer/pipeline/pipeline \
+   -i ../data \
+   -o output.webm
>>>>>>> DONE
```
