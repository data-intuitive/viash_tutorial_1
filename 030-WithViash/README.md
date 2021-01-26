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
+ wget https://github.com/data-intuitive/viash/releases/download/v0.3.1/viash -qO bin/viash
+ chmod +x bin/viash
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

## Silly examples

Before we actually start to make the first viash component for the
civilization postgame video, we want to gradually build up some
understanding of viash which will allow us to introduce some more
advanced aspects along the way.

### Silly example 1

Let us start with a very rudimentary example. Consider the following
file:

``` {.sh}
> cat src/silly_example1.vsh.yaml
functionality:
  name: silly_example1
  resources:
    - type: executable
      path: ls
```

If we run \[viash\] without any options, we get:

``` {.sh}
> viash run src/silly_example1.vsh.yaml
Makefile
README.Rmd
README.html
README.md
README_cache
bin
src
```

Perhaps unsurprisingly, this performs an `ls` in the *current* directory
which in this case is where \[viash\] is running. This example, while
illustrative, does not capture what \[viash\] is and can be used for.
It's just a wrapper around the `ls` command.

Let's go one step further:

### Silly example 2

Not only is this another silly example, it even has a silly name. Most
commands or tools can be configured using arguments, options, flags. Let
us take a look at how this can be done:

``` {.sh}
> cat src/silly_example2.vsh.yaml
functionality:
  name: silly_example2
  arguments:
    - name: "-l"
      type: boolean_true
    - name: "-a"
      type: boolean_true
  resources:
    - type: executable
      path: ls
```

We added two arguments to the `arguments` list. The arguments are flags
and if we specify for `-l` it means *long listing* is one which
corresponds to `boolean_true`.

This is what happens when you run viash in a few different scenarios:

``` {.sh}
> viash run src/silly_example2.vsh.yaml
Makefile
README.Rmd
README.html
README.md
README_cache
bin
src
```

There is no difference with the previous version of `silly_example`.
Now, let us pass the argument `-l` to `silly_example2`:

``` {.sh}
> viash run src/silly_example2.vsh.yaml -- -l
total 72
-rw-r--r--  1 toni  staff    310 Jan 26 12:14 Makefile
-rw-r--r--  1 toni  staff   6004 Jan 26 14:21 README.Rmd
-rw-r--r--@ 1 toni  staff  17001 Jan 26 13:15 README.html
-rw-r--r--  1 toni  staff   3777 Jan 26 13:14 README.md
drwxr-xr-x  3 toni  staff     96 Jan 26 11:49 README_cache
drwxr-xr-x  3 toni  staff     96 Jan 26 12:07 bin
drwxr-xr-x  6 toni  staff    192 Jan 26 14:18 src
```

Please note that options *before* the `--` are considered for `viash`
while options after the `--` are for the tool that is wrapped (in this
case `ls`). We can now also run:

``` {.sh}
> viash run src/silly_example2.vsh.yaml -- -a
.
..
Makefile
README.Rmd
README.html
README.md
README_cache
bin
src
```

Or even:

``` {.sh}
> viash run src/silly_example2.vsh.yaml -- -a -l
total 72
drwxr-xr-x   9 toni  staff    288 Jan 26 13:14 .
drwxr-xr-x  20 toni  staff    640 Jan 26 13:47 ..
-rw-r--r--   1 toni  staff    310 Jan 26 12:14 Makefile
-rw-r--r--   1 toni  staff   6004 Jan 26 14:21 README.Rmd
-rw-r--r--@  1 toni  staff  17001 Jan 26 13:15 README.html
-rw-r--r--   1 toni  staff   3777 Jan 26 13:14 README.md
drwxr-xr-x   3 toni  staff     96 Jan 26 11:49 README_cache
drwxr-xr-x   3 toni  staff     96 Jan 26 12:07 bin
drwxr-xr-x   6 toni  staff    192 Jan 26 14:18 src
```

For completeness, we also add these arguments to the first silly
example:

``` {.sh}
> viash run src/silly_example1.vsh.yaml -- -a -l
Makefile
README.Rmd
README.html
README.md
README_cache
bin
src
```

As you might have expected, since `silly_example1` does not know about
any arguments this does not change its behaviour.

### Silly example 3

In this (silly) example, we add an extra argument that corresponds to
the path which we want to *list*. The default is the current directory
(just like before) but optionally we can provide a different path.

``` {.sh}
> cat src/silly_example3.vsh.yaml
functionality:
  name: silly_example2
  arguments:
    - name: "-l"
      type: boolean_true
    - name: "-a"
      type: boolean_true
    - name: "path"
      type: file
      default: .
  resources:
    - type: executable
      path: ls
```

Examples:

``` {.sh}
> viash run src/silly_example3.vsh.yaml -- ./ -a -l
total 72
drwxr-xr-x   9 toni  staff    288 Jan 26 13:14 .
drwxr-xr-x  20 toni  staff    640 Jan 26 13:47 ..
-rw-r--r--   1 toni  staff    310 Jan 26 12:14 Makefile
-rw-r--r--   1 toni  staff   6004 Jan 26 14:21 README.Rmd
-rw-r--r--@  1 toni  staff  17001 Jan 26 13:15 README.html
-rw-r--r--   1 toni  staff   3777 Jan 26 13:14 README.md
drwxr-xr-x   3 toni  staff     96 Jan 26 11:49 README_cache
drwxr-xr-x   3 toni  staff     96 Jan 26 12:07 bin
drwxr-xr-x   6 toni  staff    192 Jan 26 14:18 src
```

``` {.sh}
> viash run src/silly_example3.vsh.yaml -- src/ -a
.
..
silly_example1.vsh.yaml
silly_example2.vsh.yaml
silly_example3.vsh.yaml
silly_example4.vsh.yaml
```

You can always retrieve information about the wrapped
script/tool/executable by requesting the included help:

``` {.sh}
> viash run src/silly_example3.vsh.yaml -- -h


Options:
    -l
        type: boolean_true

    -a
        type: boolean_true

    file
        type: file, default: .
```

### Providing documentation

The help from the last `silly_example3` does not show a lot of useful
information (yet). This can be improved:

``` {.sh}
> viash run src/silly_example4.vsh.yaml -- -h
This is a silly example that wraps the underlying ls command
and add some mildly useful functionality to it to list
the contents of a directory.

Options:
    -l
        type: boolean_true
        Long format

    -a
        type: boolean_true
        Show all

    file
        type: file, default: .
        The path to list
```

## Building *binaries*

Suppose `silly_example4` from above is exactly what we need as
standalone tool for ourselves or other people to use. Obviously,
providing everyone access to \[viash\] first and then letting them
access the `silly_example4.vsh.yaml` file in order to run the above
commands. This can be greatly simplified as follows:

``` {.sh}
> viash build src/silly_example4.vsh.yaml -o bin
```

This will *build* an *executable* (script) that contains all the
functionality that we saw in the above examples. Just to give a few
examples:

``` {.sh}
> bin/silly_example2 -h
This is a silly example that wraps the underlying ls command
and add some mildly useful functionality to it to list
the contents of a directory.

Options:
    -l
        type: boolean_true
        Long format

    -a
        type: boolean_true
        Show all

    file
        type: file, default: .
        The path to list
```

``` {.sh}
> bin/silly_example2 src/ -l
total 32
-rw-r--r--  1 toni  staff  105 Jan 26 13:14 silly_example1.vsh.yaml
-rw-r--r--  1 toni  staff  186 Jan 26 13:13 silly_example2.vsh.yaml
-rw-r--r--  1 toni  staff  239 Jan 26 14:13 silly_example3.vsh.yaml
-rw-r--r--  1 toni  staff  514 Jan 26 14:20 silly_example4.vsh.yaml
```

We start by creating a directory
