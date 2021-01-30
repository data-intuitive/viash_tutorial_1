---
author: Data Intuitive
date: Tuesday - January 26, 2021
mainfont: Roboto Condensed
monobackgroundcolor: lightgrey
monofont: Source Code Pro
monofontoptions: Scale=0.7
title: Viash Workshop 1 - Viahs Components
---

# Introduction

In this section, we cover all the components of the Civilization
postgame generation pipeline one by one, just like in the \[introductory
section\]. Before doing so, we first introduce the concept of a
*namespace*.

# Namespaces in [viash](https://github.com/data-intuitive/viash)

Once you start to make components with
[viash](https://github.com/data-intuitive/viash) and combining them in
larger scripts, workflows or pipelines you will quickly notice that some
kind of grouping comes in handy:

1.  Grouping helps in the bookkeeping related to functionality that is
    covered using components
2.  Grouping helps in separating different concerns: different people
    may be interested in different types of components with a grouping
    mechanism each can focus on his their own domain.
3.  Grouping helps in allowing to develop different sets of components
    in parallel and then later bringing those together in a larger
    project

We call a group of components a *namespace*.

[Viash](https://github.com/data-intuitive/viash) has a few ways to
associate a namespace to a components:

1.  ~~By means of a `namespace` attribute in the
    [viash](https://github.com/data-intuitive/viash) config~~
2.  ~~By means of command line parameter when building an executable~~
3.  By means of structuring the components properly and using the
    `viash ns` subcommand

Let us give an example of the first 2, option 3 will be used later in
this section.

## An example

We introduce a very simple component, one that only reports the release
of an Alpine docker container, albeit the component could be used to
`cat` the contents of other dockerized files as well:

`src/container_cat/config.vsh.yaml`:

``` {.yaml}
functionality:
  name: container_cat
  arguments:
    - name: "file"
      type: string
      default: /etc/alpine-release
  resources:
    - type: executable
      path: cat
platforms:
  - type: docker
    id: docker1
    image: alpine:latest
  - type: docker
    id: docker2
    image: alpine:2.6
```

We introduce two Docker platforms that can be distinguished by id
(`docker1` and `docker2`). Let us illustrate their use:

`docker1` platform:

``` {.sh}
> viash run src/container_cat/config.vsh.yaml -p docker1
3.13.0
```

`docker2` platform:

``` {.sh}
> viash run src/container_cat/config.vsh.yaml -p docker2
2.6.6
```

The component can be used to `cat` the contents of other files as well:

``` {.sh}
> viash run src/container_cat/config.vsh.yaml -p docker1 -- /etc/hosts
127.0.0.1   localhost
::1 localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
172.17.0.2  301c0e03ba3f
```

**Remark**: Please note that we did not specify the argument as
`type: file` because that would automount the *host*'s filesystem in the
container (or at least attempt to). In this case, we effectively want to
look inside the container.

## A namespace: `container_tools`

Our `container_cat` example fits nicely in a collection of components to
deal with containers and so we want to attach the namespace
`container_tools` to it.

First, we will build the executable for `docker1`:

``` {.sh}
> viash build src/container_cat/config.vsh.yaml -p docker1 -o bin/
```

## The example in a namespace

We take the example from above, but now store it in a directory
hierarchy like this:

``` {.sh}
> tree src/container_tools
src/container_tools
└── container_cat
    └── config.vsh.yaml

1 directory, 1 file
```

The directory `container_tools` corresponds to the name of the
namespace. Apart from this, there is no difference in how
`container_cat` is defined.

We can now use the `viash ns` subcommand like this:

``` {.sh}
> viash ns build -n container_tools
Exporting src/container_tools/container_cat/ (container_tools) =docker1=> target/docker1/container_tools/container_cat
Exporting src/container_tools/container_cat/ (container_tools) =docker2=> target/docker2/container_tools/container_cat
```

We specify the name of the namespace using the `-n` parameter. In this
case, there is only one component in this namespace, but it contains two
platforms. The `viash ns` command *builds* a *target* for every platform
it detects unless an optional `-p` is specified in the command above.

As a matter of fact, even the `-n` option can be omitted in which case
*all* namespaces under `src` will be parsed.

This is a very effective way of keeping a collection of components under
`src` grouped in namespaces. Different namespaces could be split across
different directories or even source repositories and then combined on
the level of `viash` by specifying the *target* directory (`target/` by
default).

# `civ6_save_renderer` namespace

Looking at the contents of `src/civ6_save_renderer`, we notice that
`civ6_save_renderer` is a namespace that contains a number of
components:

``` {.sh}
> tree src/civ6_save_renderer
src/civ6_save_renderer
├── combine_plots
│   ├── config.vsh.yaml
│   └── script.sh
├── convert_plot
│   ├── config.vsh.yaml
│   └── script.sh
├── parse_header
│   ├── config.vsh.yaml
│   └── script.sh
├── parse_map
│   ├── config.vsh.yaml
│   ├── helper.js
│   └── script.js
└── plot_map
    ├── config.vsh.yaml
    ├── helper.R
    └── script.R

5 directories, 12 files
```

We can easily convert the full contents this namespace into executables
using:

``` {.sh}
> viash ns build -n civ6_save_renderer
Exporting src/civ6_save_renderer/combine_plots/ (civ6_save_renderer) =docker=> target/docker/civ6_save_renderer/combine_plots
Exporting src/civ6_save_renderer/combine_plots/ (civ6_save_renderer) =native=> target/native/civ6_save_renderer/combine_plots
Exporting src/civ6_save_renderer/convert_plot/ (civ6_save_renderer) =docker=> target/docker/civ6_save_renderer/convert_plot
Exporting src/civ6_save_renderer/convert_plot/ (civ6_save_renderer) =native=> target/native/civ6_save_renderer/convert_plot
Exporting src/civ6_save_renderer/plot_map/ (civ6_save_renderer) =docker=> target/docker/civ6_save_renderer/plot_map
Exporting src/civ6_save_renderer/plot_map/ (civ6_save_renderer) =native=> target/native/civ6_save_renderer/plot_map
Exporting src/civ6_save_renderer/parse_map/ (civ6_save_renderer) =docker=> target/docker/civ6_save_renderer/parse_map
Exporting src/civ6_save_renderer/parse_map/ (civ6_save_renderer) =native=> target/native/civ6_save_renderer/parse_map
Exporting src/civ6_save_renderer/parse_header/ (civ6_save_renderer) =docker=> target/docker/civ6_save_renderer/parse_header
Exporting src/civ6_save_renderer/parse_header/ (civ6_save_renderer) =native=> target/native/civ6_save_renderer/parse_header
```

We cover the components one by one in what follows and discuss any
specificities that we encounter underway.

## `parse_header`

Let us start with `parse_header`, it parses the headers of the save
files.

`src/civ6_save_renderer/parse_header/config.vsh.yaml`:

``` {.yaml}
functionality:
  name: parse_header
  namespace: civ6_save_renderer
  description: "Extract game settings from a Civ6 save file as a yaml."
  arguments:
    - name: "--input"
      alternatives: [-i]
      type: file
      required: true
      default: "save.Civ6Save"
      must_exist: true
      description: "A Civ6 save file."
    - name: "--output"
      alternatives: [-o]
      type: file
      required: true
      default: "output.yaml"
      direction: output
      description: "Path to store the output YAML at."
  resources:
    - type: bash_script
      path: script.sh
platforms:
  - type: docker
    image: node
    docker:
      run:
        - cd /home/node && npm install civ6-save-parser
  - type: native
```

`src/civ6_save_renderer/parse_header/script.sh`:

``` {.sh}
#!/bin/bash

node /home/node/node_modules/civ6-save-parser/index.js "$par_input" --simple > "$par_output"
```
