---
author: Toni Verbeiren, Data Intuitive
date: Tuesday - January 26, 2021
mainfont: Roboto Condensed
monobackgroundcolor: lightgrey
monofont: Source Code Pro
monofontoptions: Scale=0.7
title: Viash Workshop 1 - With Viash
---

# What constitutes a step?

A step in the rendering of the video contains of one aspect that can be
considered on its own. Understanding the logic of a step, however, is
not sufficient as we have seen before. We also need to define the
environment in which the step has to be performed.

In other words, we need to understand *what* needs to run and *how* it
should run.

`combine_plots`, for instance, takes as input a number of plots (`png`
images) and combines them into a plot. As introduced earlier, we can use
[`ffmpeg`]() for this and it's then just a matter of getting the proper
arguments for the tool right. That's basically what we did in the
previous section. But it did not stop there, we had to explicitly
install the tool in order to run it.

Let us see if we can shortcut some of this work using viash.

# Introducing Viash

Viash allows to do exactly this: specify the *what* and the *how*.

## Installing viash

Installation of \[viash\] is explained in
[here](http://www.data-intuitive.com/viash_docs/getting_started/installation/).

Since we want to keep this tutorial self-contained, we will download and
install the latest (binary) release and install it locally. You'll need
the following for htis:

-   Access to a Linux, UNIX, Mac system or Windows with WSL(2)
-   A terminal application
-   Java 8 or higher installed

Then, you can:

``` {.sh}
> mkdir -p bin/
+ # wget https://github.com/data-intuitive/viash/releases/download/v0.3.0/viash -O bin/viash
+ # chmod +x bin/viash
```

Let's see if this works:

``` {.sh}
> bin/viash -h
viash 0.3.0 (c) 2020 Data Intuitive, All Rights Reserved

viash is a spec and a tool for defining execution contexts and converting execution instructions to concrete instantiations.

Usage:
  viash run config.vsh.yaml -- [arguments for script]
  viash build config.vsh.yaml
  viash test config.vsh.yaml
  viash ns build
  viash ns test

Check the help of a subcommand for more information, or the API available at:
  https://www.data-intuitive.com/viash_docs

Arguments:
  -h, --help      Show help message
  -v, --version   Show version of this program

Subcommands:
  run
  build
  test
  ns
```

## Silly example

But before we do that, we want to gradually build up some understanding
of viash which will allow us to introduce some more advanced aspects
along the way.

Let us start with a very rudimentary example. Consider the following
file:

``` {.sh}
> cat src/silly_example/config.vsh.yaml
functionality:
  name: combine_plots1
  arguments:
    - name: "--input"
      type: file
    - name: "--output"
      type: file
  resources:
    - type: executable
      path: ls
```

We start by creating a directory
