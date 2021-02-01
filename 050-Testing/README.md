---
author: Data Intuitive
date: Tuesday - January 26, 2021
mainfont: Roboto Condensed
monobackgroundcolor: lightgrey
monofont: Source Code Pro
monofontoptions: Scale=0.7
title: Viash Workshop 1 - Testing
---

# Introduction

> blabla

We will introduce testing using the same components we used earlier to
introduce the [viash](https://github.com/data-intuitive/viash) approach:

-   `convert_plot`
-   `combine_plots`

# `convert_plot`

`convert_plot` converts a PDF (map) into a `.png` version.

## The viash configuration

We covered the functionality of this component already in the previous
sections. In this section, we show how to add (unit) tests to the
component. Let see what the directory structure of the (updated)
component looks like. We put the components in the `civ6_save_renderer`
namespace now that we know how this works:

``` {.sh}
> tree src/civ6_save_renderer/convert_plot
src/civ6_save_renderer/convert_plot
├── config.vsh.yaml
├── output
│   ├── convert_plot
│   └── viash.yaml
├── script.sh
└── test
    └── run_test.sh

2 directories, 5 files
```

Just like in the [viash](https://github.com/data-intuitive/viash) primer
(of the previous section) there is a
[viash](https://github.com/data-intuitive/viash) config
(`config.vsh.yaml`) and a script (`script.sh`). Let us take a closer
look at both of these:

`src/civ6_save_renderer/convert_plot/config.vsh.yaml`:

``` {.yaml}
functionality:
  name: convert_plot
  namespace: civ6_save_renderer
  description: Convert a plot from pdf to png.
  arguments:
    - name: "--input"
      alternatives: [ "-i" ]
      type: file
      required: true
      default: "input.pdf"
      must_exist: true
      description: "A PDF input file."
    - name: "--output"
      alternatives: [ "-o" ]
      type: file
      required: true
      default: "output.png"
      direction: output
      description: "Output path."
  resources:
    - type: bash_script
      path: script.sh
  tests:
    - type: bash_script
      path: test/run_test.sh
    - path: https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf
platforms:
  - type: docker
    image: dpokidov/imagemagick
    setup:
      - type: apt
        packages: [ "tesseract-ocr" ]
  - type: native
```

`src/civ6_save_renderer/convert_plot/test/run_test.sh`:

``` {.sh}
#!/usr/bin/env bash

set -ex

# Run our component
convert_plot \
  -i dummy.pdf \
  -o dummy.png

[[ ! -f dummy.png ]] && echo "No output generated!" && exit 1

# Run OCR on the png file
tesseract dummy.png dummy-ocr

[[ ! `grep Dummy dummy-ocr.txt` ]] && echo "Not the correct content" && exit 1

echo ">>> Test finished successfully"
```

The only differences with before are:

1.  The addition of the `tests`
2.  An extra `apt` package to be installed for running the tests (see
    later).

### Tests

Specifying the tests is not different from specifying the `resources` in
the [viash](https://github.com/data-intuitive/viash) configuration. In
this case, we have two resources: one is the script that contains the
test code and one is a dummy PDF file that is fetched from the web
during testing. We could also add a PDF file to the repository and point
to that instead.

The test script itself defines two tests:

1.  A test to see if an output file is effectively created by our
    component
2.  A test that extracts the text from the resulting `png` file in order
    to verify the content is still the same as the original.

In order to run the second step, we install a package
[`tesseract`](https://opensource.google/projects/tesseract) that
performs the OCR.

### Platforms

The only difference with the `platforms` definition earlier is the
installation of an additional package in the container.

## Running the tests

In order to run the tests using the default platform (`docker` in our
current example), we can simply run:

``` {.sh}
> viash test src/civ6_save_renderer/convert_plot/config.vsh.yaml
Running tests in temporary directory: '/tmp/viash_test_convert_plot8032031727942331152'
====================================================================
+/tmp/viash_test_convert_plot8032031727942331152/build_executable/convert_plot ---setup
> docker build -t civ6_save_renderer/convert_plot:latest --no-cache /tmp/viashsetupdocker-convert_plot-zI9tDu
Sending build context to Docker daemon  17.41kB

Step 1/2 : FROM dpokidov/imagemagick
 ---> 0ce61e775be8
Step 2/2 : RUN apt-get update &&   apt-get install -y tesseract-ocr &&   rm -rf /var/lib/apt/lists/*
 ---> Running in 4f16ee452621
Get:1 http://security.debian.org/debian-security buster/updates InRelease [65.4 kB]
Get:2 http://deb.debian.org/debian buster InRelease [121 kB]
Get:3 http://deb.debian.org/debian buster-updates InRelease [51.9 kB]
Get:4 http://security.debian.org/debian-security buster/updates/main amd64 Packages [270 kB]
Get:5 http://deb.debian.org/debian buster/main amd64 Packages [7907 kB]
Get:6 http://deb.debian.org/debian buster-updates/main amd64 Packages [7848 B]
Fetched 8424 kB in 3s (3301 kB/s)
Reading package lists...
Reading package lists...
Building dependency tree...
Reading state information...
The following additional packages will be installed:
  fontconfig libbsd0 libcairo2 libdatrie1 libfribidi0 libgif7 libglib2.0-0
  libglib2.0-data libgraphite2-3 libharfbuzz0b liblept5 libpango-1.0-0
  libpangocairo-1.0-0 libpangoft2-1.0-0 libpixman-1-0 libtesseract4
  libthai-data libthai0 libx11-6 libx11-data libxau6 libxcb-render0
  libxcb-shm0 libxcb1 libxdmcp6 libxext6 libxrender1 shared-mime-info
  tesseract-ocr-eng tesseract-ocr-osd xdg-user-dirs
The following NEW packages will be installed:
  fontconfig libbsd0 libcairo2 libdatrie1 libfribidi0 libgif7 libglib2.0-0
  libglib2.0-data libgraphite2-3 libharfbuzz0b liblept5 libpango-1.0-0
  libpangocairo-1.0-0 libpangoft2-1.0-0 libpixman-1-0 libtesseract4
  libthai-data libthai0 libx11-6 libx11-data libxau6 libxcb-render0
  libxcb-shm0 libxcb1 libxdmcp6 libxext6 libxrender1 shared-mime-info
  tesseract-ocr tesseract-ocr-eng tesseract-ocr-osd xdg-user-dirs
0 upgraded, 32 newly installed, 0 to remove and 2 not upgraded.
Need to get 15.4 MB of archives.
After this operation, 51.1 MB of additional disk space will be used.
Get:1 http://deb.debian.org/debian buster/main amd64 fontconfig amd64 2.13.1-2 [405 kB]
Get:2 http://deb.debian.org/debian buster/main amd64 libbsd0 amd64 0.9.1-2 [99.5 kB]
Get:3 http://deb.debian.org/debian buster/main amd64 libpixman-1-0 amd64 0.36.0-1 [537 kB]
Get:4 http://deb.debian.org/debian buster/main amd64 libxau6 amd64 1:1.0.8-1+b2 [19.9 kB]
Get:5 http://deb.debian.org/debian buster/main amd64 libxdmcp6 amd64 1:1.1.2-3 [26.3 kB]
Get:6 http://deb.debian.org/debian buster/main amd64 libxcb1 amd64 1.13.1-2 [137 kB]
Get:7 http://deb.debian.org/debian buster/main amd64 libx11-data all 2:1.6.7-1+deb10u1 [294 kB]
Get:8 http://deb.debian.org/debian buster/main amd64 libx11-6 amd64 2:1.6.7-1+deb10u1 [757 kB]
Get:9 http://deb.debian.org/debian buster/main amd64 libxcb-render0 amd64 1.13.1-2 [109 kB]
Get:10 http://deb.debian.org/debian buster/main amd64 libxcb-shm0 amd64 1.13.1-2 [99.2 kB]
Get:11 http://deb.debian.org/debian buster/main amd64 libxext6 amd64 2:1.3.3-1+b2 [52.5 kB]
Get:12 http://deb.debian.org/debian buster/main amd64 libxrender1 amd64 1:0.9.10-1 [33.0 kB]
Get:13 http://deb.debian.org/debian buster/main amd64 libcairo2 amd64 1.16.0-4 [689 kB]
Get:14 http://deb.debian.org/debian buster/main amd64 libdatrie1 amd64 0.2.12-2 [39.3 kB]
Get:15 http://deb.debian.org/debian buster/main amd64 libfribidi0 amd64 1.0.5-3.1+deb10u1 [63.7 kB]
Get:16 http://deb.debian.org/debian buster/main amd64 libgif7 amd64 5.1.4-3 [43.3 kB]
Get:17 http://deb.debian.org/debian buster/main amd64 libglib2.0-0 amd64 2.58.3-2+deb10u2 [1258 kB]
Get:18 http://deb.debian.org/debian buster/main amd64 libglib2.0-data all 2.58.3-2+deb10u2 [1110 kB]
Get:19 http://deb.debian.org/debian buster/main amd64 libgraphite2-3 amd64 1.3.13-7 [80.7 kB]
Get:20 http://deb.debian.org/debian buster/main amd64 libharfbuzz0b amd64 2.3.1-1 [1187 kB]
Get:21 http://deb.debian.org/debian buster/main amd64 liblept5 amd64 1.76.0-1 [940 kB]
Get:22 http://deb.debian.org/debian buster/main amd64 libthai-data all 0.1.28-2 [170 kB]
Get:23 http://deb.debian.org/debian buster/main amd64 libthai0 amd64 0.1.28-2 [54.1 kB]
Get:24 http://deb.debian.org/debian buster/main amd64 libpango-1.0-0 amd64 1.42.4-8~deb10u1 [186 kB]
Get:25 http://deb.debian.org/debian buster/main amd64 libpangoft2-1.0-0 amd64 1.42.4-8~deb10u1 [68.3 kB]
Get:26 http://deb.debian.org/debian buster/main amd64 libpangocairo-1.0-0 amd64 1.42.4-8~deb10u1 [55.7 kB]
Get:27 http://deb.debian.org/debian buster/main amd64 libtesseract4 amd64 4.0.0-2 [1234 kB]
Get:28 http://deb.debian.org/debian buster/main amd64 shared-mime-info amd64 1.10-1 [766 kB]
Get:29 http://deb.debian.org/debian buster/main amd64 tesseract-ocr-eng all 1:4.00~git30-7274cfa-1 [1592 kB]
Get:30 http://deb.debian.org/debian buster/main amd64 tesseract-ocr-osd all 1:4.00~git30-7274cfa-1 [2991 kB]
Get:31 http://deb.debian.org/debian buster/main amd64 tesseract-ocr amd64 4.0.0-2 [262 kB]
Get:32 http://deb.debian.org/debian buster/main amd64 xdg-user-dirs amd64 0.17-2 [53.8 kB]
[91mdebconf: delaying package configuration, since apt-utils is not installed
[0mFetched 15.4 MB in 1s (12.3 MB/s)
Selecting previously unselected package fontconfig.
(Reading database ... 
(Reading database ... 5%
(Reading database ... 10%
(Reading database ... 15%
(Reading database ... 20%
(Reading database ... 25%
(Reading database ... 30%
(Reading database ... 35%
(Reading database ... 40%
(Reading database ... 45%
(Reading database ... 50%
(Reading database ... 55%
(Reading database ... 60%
(Reading database ... 65%
(Reading database ... 70%
(Reading database ... 75%
(Reading database ... 80%
(Reading database ... 85%
(Reading database ... 90%
(Reading database ... 95%
(Reading database ... 100%
(Reading database ... 13020 files and directories currently installed.)
Preparing to unpack .../00-fontconfig_2.13.1-2_amd64.deb ...
Unpacking fontconfig (2.13.1-2) ...
Selecting previously unselected package libbsd0:amd64.
Preparing to unpack .../01-libbsd0_0.9.1-2_amd64.deb ...
Unpacking libbsd0:amd64 (0.9.1-2) ...
Selecting previously unselected package libpixman-1-0:amd64.
Preparing to unpack .../02-libpixman-1-0_0.36.0-1_amd64.deb ...
Unpacking libpixman-1-0:amd64 (0.36.0-1) ...
Selecting previously unselected package libxau6:amd64.
Preparing to unpack .../03-libxau6_1%3a1.0.8-1+b2_amd64.deb ...
Unpacking libxau6:amd64 (1:1.0.8-1+b2) ...
Selecting previously unselected package libxdmcp6:amd64.
Preparing to unpack .../04-libxdmcp6_1%3a1.1.2-3_amd64.deb ...
Unpacking libxdmcp6:amd64 (1:1.1.2-3) ...
Selecting previously unselected package libxcb1:amd64.
Preparing to unpack .../05-libxcb1_1.13.1-2_amd64.deb ...
Unpacking libxcb1:amd64 (1.13.1-2) ...
Selecting previously unselected package libx11-data.
Preparing to unpack .../06-libx11-data_2%3a1.6.7-1+deb10u1_all.deb ...
Unpacking libx11-data (2:1.6.7-1+deb10u1) ...
Selecting previously unselected package libx11-6:amd64.
Preparing to unpack .../07-libx11-6_2%3a1.6.7-1+deb10u1_amd64.deb ...
Unpacking libx11-6:amd64 (2:1.6.7-1+deb10u1) ...
Selecting previously unselected package libxcb-render0:amd64.
Preparing to unpack .../08-libxcb-render0_1.13.1-2_amd64.deb ...
Unpacking libxcb-render0:amd64 (1.13.1-2) ...
Selecting previously unselected package libxcb-shm0:amd64.
Preparing to unpack .../09-libxcb-shm0_1.13.1-2_amd64.deb ...
Unpacking libxcb-shm0:amd64 (1.13.1-2) ...
Selecting previously unselected package libxext6:amd64.
Preparing to unpack .../10-libxext6_2%3a1.3.3-1+b2_amd64.deb ...
Unpacking libxext6:amd64 (2:1.3.3-1+b2) ...
Selecting previously unselected package libxrender1:amd64.
Preparing to unpack .../11-libxrender1_1%3a0.9.10-1_amd64.deb ...
Unpacking libxrender1:amd64 (1:0.9.10-1) ...
Selecting previously unselected package libcairo2:amd64.
Preparing to unpack .../12-libcairo2_1.16.0-4_amd64.deb ...
Unpacking libcairo2:amd64 (1.16.0-4) ...
Selecting previously unselected package libdatrie1:amd64.
Preparing to unpack .../13-libdatrie1_0.2.12-2_amd64.deb ...
Unpacking libdatrie1:amd64 (0.2.12-2) ...
Selecting previously unselected package libfribidi0:amd64.
Preparing to unpack .../14-libfribidi0_1.0.5-3.1+deb10u1_amd64.deb ...
Unpacking libfribidi0:amd64 (1.0.5-3.1+deb10u1) ...
Selecting previously unselected package libgif7:amd64.
Preparing to unpack .../15-libgif7_5.1.4-3_amd64.deb ...
Unpacking libgif7:amd64 (5.1.4-3) ...
Selecting previously unselected package libglib2.0-0:amd64.
Preparing to unpack .../16-libglib2.0-0_2.58.3-2+deb10u2_amd64.deb ...
Unpacking libglib2.0-0:amd64 (2.58.3-2+deb10u2) ...
Selecting previously unselected package libglib2.0-data.
Preparing to unpack .../17-libglib2.0-data_2.58.3-2+deb10u2_all.deb ...
Unpacking libglib2.0-data (2.58.3-2+deb10u2) ...
Selecting previously unselected package libgraphite2-3:amd64.
Preparing to unpack .../18-libgraphite2-3_1.3.13-7_amd64.deb ...
Unpacking libgraphite2-3:amd64 (1.3.13-7) ...
Selecting previously unselected package libharfbuzz0b:amd64.
Preparing to unpack .../19-libharfbuzz0b_2.3.1-1_amd64.deb ...
Unpacking libharfbuzz0b:amd64 (2.3.1-1) ...
Selecting previously unselected package liblept5.
Preparing to unpack .../20-liblept5_1.76.0-1_amd64.deb ...
Unpacking liblept5 (1.76.0-1) ...
Selecting previously unselected package libthai-data.
Preparing to unpack .../21-libthai-data_0.1.28-2_all.deb ...
Unpacking libthai-data (0.1.28-2) ...
Selecting previously unselected package libthai0:amd64.
Preparing to unpack .../22-libthai0_0.1.28-2_amd64.deb ...
Unpacking libthai0:amd64 (0.1.28-2) ...
Selecting previously unselected package libpango-1.0-0:amd64.
Preparing to unpack .../23-libpango-1.0-0_1.42.4-8~deb10u1_amd64.deb ...
Unpacking libpango-1.0-0:amd64 (1.42.4-8~deb10u1) ...
Selecting previously unselected package libpangoft2-1.0-0:amd64.
Preparing to unpack .../24-libpangoft2-1.0-0_1.42.4-8~deb10u1_amd64.deb ...
Unpacking libpangoft2-1.0-0:amd64 (1.42.4-8~deb10u1) ...
Selecting previously unselected package libpangocairo-1.0-0:amd64.
Preparing to unpack .../25-libpangocairo-1.0-0_1.42.4-8~deb10u1_amd64.deb ...
Unpacking libpangocairo-1.0-0:amd64 (1.42.4-8~deb10u1) ...
Selecting previously unselected package libtesseract4:amd64.
Preparing to unpack .../26-libtesseract4_4.0.0-2_amd64.deb ...
Unpacking libtesseract4:amd64 (4.0.0-2) ...
Selecting previously unselected package shared-mime-info.
Preparing to unpack .../27-shared-mime-info_1.10-1_amd64.deb ...
Unpacking shared-mime-info (1.10-1) ...
Selecting previously unselected package tesseract-ocr-eng.
Preparing to unpack .../28-tesseract-ocr-eng_1%3a4.00~git30-7274cfa-1_all.deb ...
Unpacking tesseract-ocr-eng (1:4.00~git30-7274cfa-1) ...
Selecting previously unselected package tesseract-ocr-osd.
Preparing to unpack .../29-tesseract-ocr-osd_1%3a4.00~git30-7274cfa-1_all.deb ...
Unpacking tesseract-ocr-osd (1:4.00~git30-7274cfa-1) ...
Selecting previously unselected package tesseract-ocr.
Preparing to unpack .../30-tesseract-ocr_4.0.0-2_amd64.deb ...
Unpacking tesseract-ocr (4.0.0-2) ...
Selecting previously unselected package xdg-user-dirs.
Preparing to unpack .../31-xdg-user-dirs_0.17-2_amd64.deb ...
Unpacking xdg-user-dirs (0.17-2) ...
Setting up libgraphite2-3:amd64 (1.3.13-7) ...
Setting up libpixman-1-0:amd64 (0.36.0-1) ...
Setting up fontconfig (2.13.1-2) ...
Regenerating fonts cache... done.
Setting up libxau6:amd64 (1:1.0.8-1+b2) ...
Setting up libdatrie1:amd64 (0.2.12-2) ...
Setting up xdg-user-dirs (0.17-2) ...
Setting up libglib2.0-0:amd64 (2.58.3-2+deb10u2) ...
No schema files found: doing nothing.
Setting up tesseract-ocr-eng (1:4.00~git30-7274cfa-1) ...
Setting up libglib2.0-data (2.58.3-2+deb10u2) ...
Setting up libx11-data (2:1.6.7-1+deb10u1) ...
Setting up libfribidi0:amd64 (1.0.5-3.1+deb10u1) ...
Setting up shared-mime-info (1.10-1) ...
Setting up libgif7:amd64 (5.1.4-3) ...
Setting up libharfbuzz0b:amd64 (2.3.1-1) ...
Setting up libthai-data (0.1.28-2) ...
Setting up tesseract-ocr-osd (1:4.00~git30-7274cfa-1) ...
Setting up libbsd0:amd64 (0.9.1-2) ...
Setting up libxdmcp6:amd64 (1:1.1.2-3) ...
Setting up libxcb1:amd64 (1.13.1-2) ...
Setting up libxcb-render0:amd64 (1.13.1-2) ...
Setting up libxcb-shm0:amd64 (1.13.1-2) ...
Setting up liblept5 (1.76.0-1) ...
Setting up libthai0:amd64 (0.1.28-2) ...
Setting up libtesseract4:amd64 (4.0.0-2) ...
Setting up libx11-6:amd64 (2:1.6.7-1+deb10u1) ...
Setting up libxrender1:amd64 (1:0.9.10-1) ...
Setting up libpango-1.0-0:amd64 (1.42.4-8~deb10u1) ...
Setting up libxext6:amd64 (2:1.3.3-1+b2) ...
Setting up libcairo2:amd64 (1.16.0-4) ...
Setting up libpangoft2-1.0-0:amd64 (1.42.4-8~deb10u1) ...
Setting up libpangocairo-1.0-0:amd64 (1.42.4-8~deb10u1) ...
Setting up tesseract-ocr (4.0.0-2) ...
Processing triggers for libc-bin (2.28-10) ...
Removing intermediate container 4f16ee452621
 ---> 984977dde9b0
Successfully built 984977dde9b0
Successfully tagged civ6_save_renderer/convert_plot:latest
====================================================================
+/tmp/viash_test_convert_plot8032031727942331152/test_run_test.sh/run_test.sh
+ convert_plot -i dummy.pdf -o dummy.png
convert: profile 'icc': 'RGB ': RGB color space not permitted on grayscale PNG `dummy.png' @ warning/png.c/MagickPNGWarningHandler/1748.
+ [[ ! -f dummy.png ]]
+ tesseract dummy.png dummy-ocr
Tesseract Open Source OCR Engine v4.0.0 with Leptonica
Warning: Invalid resolution 0 dpi. Using 70 instead.
Estimating resolution as 157
++ grep Dummy dummy-ocr.txt
>>> Test finished successfully
+ [[ ! -n Dummy PDF file ]]
+ echo '>>> Test finished successfully'
====================================================================
[32mSUCCESS! All 1 out of 1 test scripts succeeded![0m
Cleaning up temporary directory
```

Let us break down what happens here:

1.  [viash](https://github.com/data-intuitive/viash) creates a temporary
    directory (configurable via `$VIASH_TEMP`)
2.  The setup of the appropriate platform is executed
3.  The executable for the component is built in the temporary directory
4.  The test script is run

If tests are successful, the temporary directory is removed (unless
`--keep` is provided as an option to `viash test`).

This is a quick way to run a test on a component.

# `combine_plots`

We do something similar for the component that combines different `png`
(map) files into one `webm` video. Let us see how we can do something
similar as before so that a test can run on its own.

We refer to an
[article](http://hplgit.github.io/animate/doc/pub/video.html) that
discussed the generation of an animation from `png` image sources and
does this using ... ImageMagic. We use a selection of the images stored
on
[Github](https://github.com/hplgit/animate/tree/master/doc/src/animate/src-animate/testfiles/frames).

`src/civ6_save_renderer/combine_plots/config.vsh.yaml`:

``` {.yaml}
functionality:
  name: combine_plots
  namespace: civ6_save_renderer
  description: Combine multiple images into a movie using ffmpeg.
  arguments:
    - name: "--input"
      alternatives: [-i]
      type: file
      required: true
      default: "/path/to/my/dir"
      must_exist: true
      multiple: true
      description: A list of images.
    - name: "--output"
      alternatives: [-o]
      type: file
      required: true
      default: "output.webm"
      direction: output
      description: A path to output the movie to.
    - name: "--framerate"
      alternatives: [-f]
      type: integer
      default: 4
      description: Number of frames per second.
  resources:
    - type: bash_script
      path: script.sh
  tests:
    - type: bash_script
      path: test/run_test.sh
    - path: https://github.com/hplgit/animate/raw/master/doc/src/animate/src-animate/testfiles/frames/frame_0000.png
    - path: https://github.com/hplgit/animate/raw/master/doc/src/animate/src-animate/testfiles/frames/frame_0001.png
    - path: https://github.com/hplgit/animate/raw/master/doc/src/animate/src-animate/testfiles/frames/frame_0002.png
    - path: https://github.com/hplgit/animate/raw/master/doc/src/animate/src-animate/testfiles/frames/frame_0003.png
    - path: https://github.com/hplgit/animate/raw/master/doc/src/animate/src-animate/testfiles/frames/frame_0004.png
    - path: https://github.com/hplgit/animate/raw/master/doc/src/animate/src-animate/testfiles/frames/frame_0005.png
    - path: https://github.com/hplgit/animate/raw/master/doc/src/animate/src-animate/testfiles/frames/frame_0006.png
    - path: https://github.com/hplgit/animate/raw/master/doc/src/animate/src-animate/testfiles/frames/frame_0007.png
    - path: https://github.com/hplgit/animate/raw/master/doc/src/animate/src-animate/testfiles/frames/frame_0008.png
platforms:
  - type: docker
    image: jrottenberg/ffmpeg
  - type: native
```

`src/civ6_save_renderer/combine_plots/test/run_test.sh`:

``` {.sh}
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
```

We added the `tests` and point to the frames explicitly. The test script
basically generates a command line instructions (list of `png` files)
based on the images that have been downloaded as resources.

``` {.sh}
> viash test src/civ6_save_renderer/combine_plots/config.vsh.yaml
Running tests in temporary directory: '/tmp/viash_test_combine_plots7348196360299078692'
====================================================================
+/tmp/viash_test_combine_plots7348196360299078692/build_executable/combine_plots ---setup
> docker pull jrottenberg/ffmpeg
Using default tag: latest
latest: Pulling from jrottenberg/ffmpeg
Digest: sha256:21eb739725c43bd7187982e5fa4b5371b495d1d1f6f61ae1719ca794817f8641
Status: Image is up to date for jrottenberg/ffmpeg:latest
docker.io/jrottenberg/ffmpeg:latest
====================================================================
+/tmp/viash_test_combine_plots7348196360299078692/test_run_test.sh/run_test.sh
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
Input #0, image2, from 'frame_0000.png':
  Duration: 00:00:01.00, start: 0.000000, bitrate: N/A
    Stream #0:0: Video: png, rgba(pc), 812x612 [SAR 3937:3937 DAR 203:153], 1 tbr, 1 tbn, 1 tbc
Input #1, png_pipe, from 'frame_0001.png':
  Duration: N/A, bitrate: N/A
    Stream #1:0: Video: png, rgba(pc), 812x612 [SAR 3937:3937 DAR 203:153], 25 tbr, 25 tbn, 25 tbc
Input #2, png_pipe, from 'frame_0002.png':
  Duration: N/A, bitrate: N/A
    Stream #2:0: Video: png, rgba(pc), 812x612 [SAR 3937:3937 DAR 203:153], 25 tbr, 25 tbn, 25 tbc
Input #3, png_pipe, from 'frame_0003.png':
  Duration: N/A, bitrate: N/A
    Stream #3:0: Video: png, rgba(pc), 812x612 [SAR 3937:3937 DAR 203:153], 25 tbr, 25 tbn, 25 tbc
Input #4, png_pipe, from 'frame_0004.png':
  Duration: N/A, bitrate: N/A
    Stream #4:0: Video: png, rgba(pc), 812x612 [SAR 3937:3937 DAR 203:153], 25 tbr, 25 tbn, 25 tbc
Input #5, png_pipe, from 'frame_0005.png':
  Duration: N/A, bitrate: N/A
    Stream #5:0: Video: png, rgba(pc), 812x612 [SAR 3937:3937 DAR 203:153], 25 tbr, 25 tbn, 25 tbc
Input #6, png_pipe, from 'frame_0006.png':
  Duration: N/A, bitrate: N/A
    Stream #6:0: Video: png, rgba(pc), 812x612 [SAR 3937:3937 DAR 203:153], 25 tbr, 25 tbn, 25 tbc
Input #7, png_pipe, from 'frame_0007.png':
  Duration: N/A, bitrate: N/A
    Stream #7:0: Video: png, rgba(pc), 812x612 [SAR 3937:3937 DAR 203:153], 25 tbr, 25 tbn, 25 tbc
Input #8, png_pipe, from 'frame_0008.png':
  Duration: N/A, bitrate: N/A
    Stream #8:0: Video: png, rgba(pc), 812x612 [SAR 3937:3937 DAR 203:153], 25 tbr, 25 tbn, 25 tbc
Stream mapping:
  Stream #0:0 -> #0:0 (png (native) -> vp9 (libvpx-vp9))
Press [q] to stop, [?] for help
[libvpx-vp9 @ 0xdecdc0] v1.8.0
Output #0, webm, to 'output.webm':
  Metadata:
    encoder         : Lavf58.20.100
    Stream #0:0: Video: vp9 (libvpx-vp9), yuva420p, 812x612 [SAR 1:1 DAR 203:153], q=-1--1, 200 kb/s, 1 fps, 1k tbn, 1 tbc
    Metadata:
      encoder         : Lavc58.35.100 libvpx-vp9
    Side data:
      cpb: bitrate max/min/avg: 0/0/0 buffer size: 0 vbv_delay: -1
frame=    1 fps=0.0 q=0.0 Lsize=       8kB time=00:00:00.00 bitrate=65720.0kbits/s speed=0.00434x    
video:7kB audio:0kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: 10.714286%
>>> Test finished successfully
====================================================================
[32mSUCCESS! All 1 out of 1 test scripts succeeded![0m
Cleaning up temporary directory
```

In order to avoid [viash](https://github.com/data-intuitive/viash)
deleting the directory when a test succeeds, the `-k` option can be
used.

# Testing a namespace

In the previous examples we tested individual components, but we can
test a suite of components as well. Since we stored the 2 components
above in the (namespace) `civ6_save_renderer` again, we can do the
following:

``` {.sh}
> viash ns test -p docker --parallel --tsv report.tsv
           namespace        functionality             platform            test_name exit_code duration               result[0m
  civ6_save_renderer        combine_plots               docker                start                                        [0m
  civ6_save_renderer         convert_plot               docker                start                                        [0m
[32m  civ6_save_renderer        combine_plots               docker     build_executable         0        1              SUCCESS[0m
[32m  civ6_save_renderer        combine_plots               docker          run_test.sh         0        4              SUCCESS[0m
[32m  civ6_save_renderer         convert_plot               docker     build_executable         0     3488              SUCCESS[0m
[32m  civ6_save_renderer         convert_plot               docker          run_test.sh         0        8              SUCCESS[0m
```

The contents of (the optional) `report.tsv` contains a report of the
test run:

``` {.sh}
> ../scripts/cat_format report.tsv
```


    `report.tsv`:

    ```tsv
    namespace   functionality   platform    test_name   exit_code   duration    result
    civ6_save_renderer  combine_plots   docker  build_executable    0   1   SUCCESS
    civ6_save_renderer  combine_plots   docker  run_test.sh 0   4   SUCCESS
    civ6_save_renderer  convert_plot    docker  build_executable    0   3488    SUCCESS
    civ6_save_renderer  convert_plot    docker  run_test.sh 0   8   SUCCESS

    ```
