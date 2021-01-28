---
author: Data Intuitive
date: Tuesday - January 26, 2021
mainfont: Roboto Condensed
monobackgroundcolor: lightgrey
monofont: Source Code Pro
monofontoptions: Scale=0.7
title: Viash Workshop 1 - With Viash
---

# Introduction

With the information from the previous section, we will tackle two from
the components in detail in this section:

-   `convert_plot`
-   `combine_plots`

Both are explained in \[section 1\] above.

# `convert_plot`

`convert_plot` should convert a PDF map into a `.png` version.
\[ImageMagic\] is a suite of command line tools for UNIX-like systems
that can achieve this simply by running

    convert input.pdf -flatten output.png

Additional arguments can be provided, but are not required since
ImageMagic is pretty good at getting the defaults right. \[ImageMagic\]
will probably not be on everyone's machine as a locally installed tool,
however. We would to enable the conversion from pdf to png in a seamless
way. Let's use [viash](https://github.com/data-intuitive/viash) for
this...

## The viash configuration

First of all, we will store all files related to one *component* in a
separate directory and give it the name of the component:

``` {.sh}
ls src/convert_plot
```

    config.vsh.yaml
    script.sh

Just like in the [viash](https://github.com/data-intuitive/viash) primer
(of the previous section) there is a viash config (`config.vsh.yaml`)
and a script (`script.sh`). Let us take a closer look at both of these:

    cat src/convert_plot/config.vsh.yaml

``` {.yaml}
functionality:
  name: convert_plot
  description: Convert a plot from pdf to png.
  arguments:
    - name: "--input"
      alternatives: [-i]
      type: file
      required: true
      default: "input.pdf"
      must_exist: true
      description: "A PDF input file."
    - name: "--output"
      alternatives: [-o]
      type: file
      required: true
      default: "output.png"
      direction: output
      description: "Output path."
  resources:
    - type: bash_script
      path: script.sh
platforms:
  - type: docker
    image: dpokidov/imagemagick
  - type: native
```

    cat src/convert_plot/script.sh

``` {.sh}
#!/bin/bash

convert "$par_input" -flatten "$par_output"
```

Let us dissect these two files step by step.

### Arguments

The script is not so much different from the CLI example we gave above.
The only difference is that 2 variables are used: `$par_input` and
`$par_output`. We use double quotes around the variables, this is a good
policy in general.

The argument `--input` defined in the config is automatically associated
with `$par_input` and likewise for `--output`. This makes it easy to
write scripts and immediately get a command-line parser for free when
using [viash](https://github.com/data-intuitive/viash).

If the script is more complicated than just this one instruction (and it
can be, believe me) it is possible to set default values for those
parameters in the script itself. This way, the script can be developed
on its own without requiring
[viash](https://github.com/data-intuitive/viash) directly.

If we focus on `--input` for a second, we notice the following
attributes:

-   `-i` is a (short) alternative for the longer `--input`
-   The value for this argument is of type `file` which means it's
    either a file or a directory.
-   With `required: true` we make this argument a mandatory one
-   The default value for the argument is `input.pdf`
-   For argument of type file like this one, we can ask
    [viash](https://github.com/data-intuitive/viash) to check if the
    file/directory exists prior to running.
-   The `description` attribute contains a human-readable description of
    this argument/parameter.

Similar attributes can be found for `--output` with one difference:

-   `direction: output` denotes that this argument denotes an output
    file/option.

In fact, `--input` also has a (hidden) `direction: input` associated to
it by default.

### Resources

We've covered how to specify resources earlier in the previous section.
Suffice to say here that we point to a bash script that contains the
actual command-line instruction.

### Platforms

Two platforms are defined in the present case: a Docker one and a native
one. We point the Docker platform to an [existing Docker
image](https://hub.docker.com/r/dpokidov/imagemagick/) available on
Docker Hub.

## Building the executable

Building an executable can be done just like before. We assume
ImageMagic is not installed on the local system and thus build the
Docker version:

``` {.sh}
viash build src/convert_plot/config.vsh.yaml -o bin/ -p docker
bin/convert_plot ---setup
bin/convert_plot -h
```

    > docker pull dpokidov/imagemagick
    Using default tag: latest
    latest: Pulling from dpokidov/imagemagick
    Digest: sha256:6749db04ffa5eac1cbe77566af02463f040028fef525b767dc98e06023e6cdf8
    Status: Image is up to date for dpokidov/imagemagick:latest
    docker.io/dpokidov/imagemagick:latest
    Convert a plot from pdf to png.

    Options:
        -i file, --input=file
            type: file, required parameter, default: input.pdf
            A PDF input file.

        -o file, --output=file
            type: file, required parameter, default: output.png
            Output path.
