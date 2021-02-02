---
author: Data Intuitive
date: 'Tuesday - January 26, 2021'
mainfont: Roboto Condensed
monobackgroundcolor: lightgrey
monofont: Source Code Pro
monofontoptions: Scale=0.7
title: 'Viash Workshop 1 - Running the pipeline'
---

Introduction
============

In this section, we demonstrate how to run the full pipeline for the
Civilization postgame generation.

Building the namespace
======================

Let's build the namespace from the `src` directory in the root of this
project/repository again, so we keep this directory self-contained:

``` {.sh}
> viash ns build \
+   -n civ6_save_renderer \
+   -s ../src \
+   -p docker
Exporting ../src/civ6_save_renderer/combine_plots/ (civ6_save_renderer) =docker=> target/docker/civ6_save_renderer/combine_plots
Exporting ../src/civ6_save_renderer/convert_plot/ (civ6_save_renderer) =docker=> target/docker/civ6_save_renderer/convert_plot
Exporting ../src/civ6_save_renderer/parse_header/ (civ6_save_renderer) =docker=> target/docker/civ6_save_renderer/parse_header
Exporting ../src/civ6_save_renderer/parse_map/ (civ6_save_renderer) =docker=> target/docker/civ6_save_renderer/parse_map
Exporting ../src/civ6_save_renderer/plot_map/ (civ6_save_renderer) =docker=> target/docker/civ6_save_renderer/plot_map
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

A pipeline script
=================

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
```

A few remarks are in place here:

> > TODO

Build the `pipeline` component:

``` {.sh}
> viash ns build -p native
Exporting src/civ6_save_renderer/pipeline/ (civ6_save_renderer) =native=> target/native/civ6_save_renderer/pipeline
```

Running the pipeline
====================

Make sure you have run the required `--setup`'s. Then:

``` {.sh}
> target/native/civ6_save_renderer/pipeline/pipeline \
+   -i ../data \
+   -o output.webm
>>>>>>> parse header '../data/AutoSave_0158.Civ6Save'
>>>>>>> parse map '../data/AutoSave_0158.Civ6Save'
(node:9) [DEP0005] DeprecationWarning: Buffer() is deprecated due to security and usability issues. Please use the Buffer.alloc(), Buffer.allocUnsafe(), or Buffer.from() methods instead.
(Use `node --trace-deprecation ...` to show where the warning was created)
>>>>>>> plot map '../data/AutoSave_0158.Civ6Save'
── Attaching packages ─────────────────────────────────────── tidyverse 1.3.0 ──
✔ ggplot2 3.3.3     ✔ purrr   0.3.4
✔ tibble  3.0.6     ✔ dplyr   1.0.3
✔ tidyr   1.1.2     ✔ stringr 1.4.0
✔ readr   1.4.0     ✔ forcats 0.5.0
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
>>>>>>> convert plot '../data/AutoSave_0158.Civ6Save'
>>>>>>> parse header '../data/AutoSave_0159.Civ6Save'
>>>>>>> parse map '../data/AutoSave_0159.Civ6Save'
(node:9) [DEP0005] DeprecationWarning: Buffer() is deprecated due to security and usability issues. Please use the Buffer.alloc(), Buffer.allocUnsafe(), or Buffer.from() methods instead.
(Use `node --trace-deprecation ...` to show where the warning was created)
>>>>>>> plot map '../data/AutoSave_0159.Civ6Save'
── Attaching packages ─────────────────────────────────────── tidyverse 1.3.0 ──
✔ ggplot2 3.3.3     ✔ purrr   0.3.4
✔ tibble  3.0.6     ✔ dplyr   1.0.3
✔ tidyr   1.1.2     ✔ stringr 1.4.0
✔ readr   1.4.0     ✔ forcats 0.5.0
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
>>>>>>> convert plot '../data/AutoSave_0159.Civ6Save'
>>>>>>> parse header '../data/AutoSave_0160.Civ6Save'
>>>>>>> parse map '../data/AutoSave_0160.Civ6Save'
(node:9) [DEP0005] DeprecationWarning: Buffer() is deprecated due to security and usability issues. Please use the Buffer.alloc(), Buffer.allocUnsafe(), or Buffer.from() methods instead.
(Use `node --trace-deprecation ...` to show where the warning was created)
>>>>>>> plot map '../data/AutoSave_0160.Civ6Save'
── Attaching packages ─────────────────────────────────────── tidyverse 1.3.0 ──
✔ ggplot2 3.3.3     ✔ purrr   0.3.4
✔ tibble  3.0.6     ✔ dplyr   1.0.3
✔ tidyr   1.1.2     ✔ stringr 1.4.0
✔ readr   1.4.0     ✔ forcats 0.5.0
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
>>>>>>> convert plot '../data/AutoSave_0160.Civ6Save'
>>>>>>> parse header '../data/AutoSave_0161.Civ6Save'
>>>>>>> parse map '../data/AutoSave_0161.Civ6Save'
(node:9) [DEP0005] DeprecationWarning: Buffer() is deprecated due to security and usability issues. Please use the Buffer.alloc(), Buffer.allocUnsafe(), or Buffer.from() methods instead.
(Use `node --trace-deprecation ...` to show where the warning was created)
>>>>>>> plot map '../data/AutoSave_0161.Civ6Save'
── Attaching packages ─────────────────────────────────────── tidyverse 1.3.0 ──
✔ ggplot2 3.3.3     ✔ purrr   0.3.4
✔ tibble  3.0.6     ✔ dplyr   1.0.3
✔ tidyr   1.1.2     ✔ stringr 1.4.0
✔ readr   1.4.0     ✔ forcats 0.5.0
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
>>>>>>> convert plot '../data/AutoSave_0161.Civ6Save'
>>>>>>> parse header '../data/AutoSave_0162.Civ6Save'
>>>>>>> parse map '../data/AutoSave_0162.Civ6Save'
(node:9) [DEP0005] DeprecationWarning: Buffer() is deprecated due to security and usability issues. Please use the Buffer.alloc(), Buffer.allocUnsafe(), or Buffer.from() methods instead.
(Use `node --trace-deprecation ...` to show where the warning was created)
>>>>>>> plot map '../data/AutoSave_0162.Civ6Save'
── Attaching packages ─────────────────────────────────────── tidyverse 1.3.0 ──
✔ ggplot2 3.3.3     ✔ purrr   0.3.4
✔ tibble  3.0.6     ✔ dplyr   1.0.3
✔ tidyr   1.1.2     ✔ stringr 1.4.0
✔ readr   1.4.0     ✔ forcats 0.5.0
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
>>>>>>> convert plot '../data/AutoSave_0162.Civ6Save'
>>>>>>> combine plots
ffmpeg version 4.1 Copyright (c) 2000-2018 the FFmpeg developers
  built with gcc 5.4.0 (Ubuntu 5.4.0-6ubuntu1~16.04.11) 20160609
  configuration: --disable-debug --disable-doc --disable-ffplay --enable-shared --enable-avresample --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-gpl --enable-libass --enable-libfreetype --enable-libvidstab --enable-libmp3lame --enable-libopenjpeg --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx265 --enable-libxvid --enable-libx264 --enable-nonfree --enable-openssl --enable-libfdk_aac --enable-libkvazaar --enable-libaom --extra-libs=-lpthread --enable-postproc --enable-small --enable-version3 --extra-cflags=-I/opt/ffmpeg/include --extra-ldflags=-L/opt/ffmpeg/lib --extra-libs=-ldl --prefix=/opt/ffmpeg
  libavutil      56. 22.100 / 56. 22.100
  libavcodec     58. 35.100 / 58. 35.100
  libavformat    58. 20.100 / 58. 20.100
  libavdevice    58.  5.100 / 58.  5.100
  libavfilter     7. 40.101 /  7. 40.101
  libavresample   4.  0.  0 /  4.  0.  0
  libswscale      5.  3.100 /  5.  3.100
  libswresample   3.  3.100 /  3.  3.100
  libpostproc    55.  3.100 / 55.  3.100
Input #0, png_pipe, from 'concat:/viash_automount<...>/workspace/di/viash_workshop_1/070-Pipeline/temp/AutoSave_0158.png|/viash_automount<...>/workspace/di/viash_workshop_1/070-Pipeline/temp/AutoSave_0159.png|/viash_automount<...>/workspace/di/viash_workshop_1/070-Pipeline/temp/AutoSave_0160.png|/viash_automount<...>/workspace/di/viash_workshop_1/070-Pipeline/temp/AutoSave_0161.png|/viash_automount<...>/workspace/di/viash_workshop_1/070-Pipeline/temp/AutoSave_0162.png':
  Duration: N/A, bitrate: N/A
    Stream #0:0: Video: png, rgba64be(pc), 1728x936 [SAR 72:72 DAR 24:13], 1 fps, 1 tbr, 1 tbn, 1 tbc
Stream mapping:
  Stream #0:0 -> #0:0 (png (native) -> vp9 (libvpx-vp9))
Press [q] to stop, [?] for help
[libvpx-vp9 @ 0x1d6e900] v1.8.0
Output #0, webm, to '/viash_automount<...>/workspace/di/viash_workshop_1/070-Pipeline/output.webm':
  Metadata:
    encoder         : Lavf58.20.100
    Stream #0:0: Video: vp9 (libvpx-vp9), yuva420p, 1728x936 [SAR 1:1 DAR 24:13], q=-1--1, 200 kb/s, 1 fps, 1k tbn, 1 tbc
    Metadata:
      encoder         : Lavc58.35.100 libvpx-vp9
    Side data:
      cpb: bitrate max/min/avg: 0/0/0 buffer size: 0 vbv_delay: -1
frame=    5 fps=3.1 q=0.0 Lsize=     144kB time=00:00:04.00 bitrate= 295.5kbits/s speed=2.48x    
video:143kB audio:0kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: 0.840692%
>>>>>>> DONE
```
