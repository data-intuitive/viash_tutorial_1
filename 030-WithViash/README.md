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

Installation of [viash](https://github.com/data-intuitive/viash) is
explained in
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

If we run [viash](https://github.com/data-intuitive/viash) without any
options, we get:

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
which in this case is where
[viash](https://github.com/data-intuitive/viash) is running. This
example, while illustrative, does not capture what
[viash](https://github.com/data-intuitive/viash) is and can be used for.
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
providing everyone access to
[viash](https://github.com/data-intuitive/viash) first and then letting
them access the `silly_example4.vsh.yaml` file in order to run the above
commands would not simplify things at all! However, consider the
following:

``` {.sh}
> viash build src/silly_example4.vsh.yaml -o bin
```

This *builds* an *executable* (script) `bin/silly_example2` that
contains all the functionality that we saw in the above examples. Just
to give a few examples:

``` {.sh}
> bin/silly_example4 -h
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

## Platforms

In the above examples, we ran the tools on our local system. This is
simple as long as the wrapped tool at hand (`ls` in this case) is always
available on the local system. Viash supports running wrapped tools
inside a container as well, supporting at present Docker as a container
system. Let us illustrate how simple this can be by building a new
binary:

``` {.sh}
> viash build src/silly_example5.vsh.yaml -o bin
```

However, if we list the differences between the previous version of
silly example and this one, we note the following:

``` {.sh}
> diff bin/silly_example4 bin/silly_example5
4c4
< #    silly_example4    #
---
> #    silly_example5    #
```

There is only a difference in the name of the binary, so what does that
mean?

It means that we defined 2 platforms: a *native* one (local machine) and
a *docker* one. By default, if no platform is specified on the CLI,
[viash](https://github.com/data-intuitive/viash) will take the first one
in the list of `platforms`. And since `native` is the first, this is the
one that gets selected.

If we specify the platform explicitly:

``` {.sh}
> viash build src/silly_example5.vsh.yaml -o bin -p docker
```

We get a binary `bin/silly_example5` that automatically runs inside
Docker:

``` {.sh}
> bin/silly_example5 / -l
total 60
drwxr-xr-x    2 root     root          4096 Jan 14 11:49 bin
drwxr-xr-x    5 root     root           340 Jan 27 08:40 dev
drwxr-xr-x    1 root     root          4096 Jan 27 08:40 etc
drwxr-xr-x    2 root     root          4096 Jan 14 11:49 home
drwxr-xr-x    3 root     root          4096 Jan 27 08:40 host_mnt
drwxr-xr-x    7 root     root          4096 Jan 14 11:49 lib
drwxr-xr-x    5 root     root          4096 Jan 14 11:49 media
drwxr-xr-x    2 root     root          4096 Jan 14 11:49 mnt
drwxr-xr-x    2 root     root          4096 Jan 14 11:49 opt
dr-xr-xr-x  187 root     root             0 Jan 27 08:40 proc
drwx------    2 root     root          4096 Jan 14 11:49 root
drwxr-xr-x    2 root     root          4096 Jan 14 11:49 run
drwxr-xr-x    2 root     root          4096 Jan 14 11:49 sbin
drwxr-xr-x    2 root     root          4096 Jan 14 11:49 srv
dr-xr-xr-x   13 root     root             0 Jan 26 14:00 sys
drwxrwxrwt    2 root     root          4096 Jan 14 11:49 tmp
drwxr-xr-x    7 root     root          4096 Jan 14 11:49 usr
drwxr-xr-x   12 root     root          4096 Jan 14 11:49 var
drwxr-xr-x    1 root     root          1380 Jan 19 14:29 viash_automount
```

If the `alpine` image is not yet available on your system, this command
will automatically fetch it before running the tool. You can verify for
yourself that the result of this listing is not the same as what you
would have if you ran on your local system.

Please note that if you wanted to do this exact thing by using Docker
itself, you would have to use a CLI instruction like

``` {.sh}
> docker run -i alpine:latest ls / -l
total 56
drwxr-xr-x    2 root     root          4096 Jan 14 11:49 bin
drwxr-xr-x    5 root     root           340 Jan 27 08:41 dev
drwxr-xr-x    1 root     root          4096 Jan 27 08:41 etc
drwxr-xr-x    2 root     root          4096 Jan 14 11:49 home
drwxr-xr-x    7 root     root          4096 Jan 14 11:49 lib
drwxr-xr-x    5 root     root          4096 Jan 14 11:49 media
drwxr-xr-x    2 root     root          4096 Jan 14 11:49 mnt
drwxr-xr-x    2 root     root          4096 Jan 14 11:49 opt
dr-xr-xr-x  191 root     root             0 Jan 27 08:41 proc
drwx------    2 root     root          4096 Jan 14 11:49 root
drwxr-xr-x    2 root     root          4096 Jan 14 11:49 run
drwxr-xr-x    2 root     root          4096 Jan 14 11:49 sbin
drwxr-xr-x    2 root     root          4096 Jan 14 11:49 srv
dr-xr-xr-x   13 root     root             0 Jan 26 14:00 sys
drwxrwxrwt    2 root     root          4096 Jan 14 11:49 tmp
drwxr-xr-x    7 root     root          4096 Jan 14 11:49 usr
drwxr-xr-x   12 root     root          4096 Jan 14 11:49 var
```

While this is all still manageable, it could quickly become more
complicated, but that is for a later section. In what follows, we will
also come back not only to running inside a container but also
generating a container (based on a base image), tagging and versioning.

We finish up the part about platforms here with noting that multiple
platforms of the same `type` can coexist with each other. Below is an
example of this:

``` {.sh}
> viash build src/silly_example6.vsh.yaml -o bin -p docker2
```

By specifying `-p docker2`,
[viash](https://github.com/data-intuitive/viash) *knows* it has to
select the corresponding entry from the `platforms` list.

``` {.sh}
> bin/silly_example6 / -l
total 52
lrwxrwxrwx   1 root root    7 Jul 29 01:29 bin -> usr/bin
drwxr-xr-x   2 root root 4096 Apr 15  2020 boot
drwxr-xr-x   5 root root  340 Jan 27 08:41 dev
drwxr-xr-x   1 root root 4096 Jan 27 08:41 etc
drwxr-xr-x   2 root root 4096 Apr 15  2020 home
drwxr-xr-x   3 root root 4096 Jan 27 08:41 host_mnt
lrwxrwxrwx   1 root root    7 Jul 29 01:29 lib -> usr/lib
lrwxrwxrwx   1 root root    9 Jul 29 01:29 lib32 -> usr/lib32
lrwxrwxrwx   1 root root    9 Jul 29 01:29 lib64 -> usr/lib64
lrwxrwxrwx   1 root root   10 Jul 29 01:29 libx32 -> usr/libx32
drwxr-xr-x   2 root root 4096 Jul 29 01:29 media
drwxr-xr-x   2 root root 4096 Jul 29 01:29 mnt
drwxr-xr-x   2 root root 4096 Jul 29 01:29 opt
dr-xr-xr-x 190 root root    0 Jan 27 08:41 proc
drwx------   2 root root 4096 Jul 29 01:33 root
drwxr-xr-x   1 root root 4096 Aug 19 21:14 run
lrwxrwxrwx   1 root root    8 Jul 29 01:29 sbin -> usr/sbin
drwxr-xr-x   2 root root 4096 Jul 29 01:29 srv
dr-xr-xr-x  13 root root    0 Jan 26 14:00 sys
drwxrwxrwt   2 root root 4096 Jul 29 01:33 tmp
drwxr-xr-x   1 root root 4096 Jul 29 01:29 usr
drwxr-xr-x   1 root root 4096 Jul 29 01:33 var
drwxr-xr-x   1 root root 1380 Jan 19 14:29 viash_automount
```

## Wrapping a script

While running a command wrapped as a viash component could be useful in
*some* form or another, we will usually want to run something a bit more
custom or elaborate. Say you want to run the `silly_example6` component
from above but this time filtering out certain files/directories based
on their name. We could do just that by means of a simple CLI
instruction that we put in a script:

``` {.sh}
> cat src/script.sh
#!/bin/bash

eval "ls "$par_path" | grep '$par_filter'"
```

In combination with the following viash config:

``` {.sh}
> cat src/silly_example7.vsh.yaml
functionality:
  name: silly_example7
  description: |
    This is a silly example that wraps the underlying ls command
    and add some mildly useful functionality to it to list
    the contents of a directory.
  arguments:
    - name: "path"
      type: file
      description: "The path to list"
      default: .
    - name: "--filter"
      type: string
      description: "A filter to apply"
      default: '.*'
  resources:
    - type: bash_script
      path: script.sh
platforms:
  - type: native
  - type: docker
    id: docker1
    image: alpine:latest
  - type: docker
    id: docker2
    image: ubuntu:latest
```

We get results like this:

``` {.sh}
> viash run src/silly_example7.vsh.yaml -p docker2 -- /etc --filter "^h.*"
hosts
hosts.equiv
```

A lot is happening here at once, so let's unwrap this. We did not
*build* the executable in this example, but just run `viash run` on on
the viash spec. This spec contains a pointer (relative path) to the
`script.sh` file that contains parameters. Those parameters are defined
in the viash spec and are automatically resolved and parsed when running
the wrapped viash version of the script. The `docker2` platform is
defined in the viash spec as well, so we can just run it inside the
respective container. The `--filter` argument takes a regular
expression, it's is simply passed to `grep` in `script.sh`.

Please note that when we decide to *build* a `silly_example7` binary
(for a specific platform), again this binary is self-contained. It
includes the necessary Docker information, command line parsing logic
and the script itself. So there is not need for additional
customization.

If you would want to achieve something similar with just Docker without
Viash, you are in for some serious bash development. But it does not
stop here, because as well as having a bash script we can have Python,
R, Javascript, Scala in the current version. Other environments are
possible as well.
