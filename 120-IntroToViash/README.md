---
author: Data Intuitive
date: Tuesday - January 26, 2021
mainfont: Roboto Condensed
monobackgroundcolor: lightgrey
monofont: Source Code Pro
monofontoptions: Scale=0.7
title: Viash Workshop 1 - Viash Primer
---

# What constitutes a step?

A step in the rendering of the video contains of one aspect that can be
considered on its own. Understanding the logic of a step, however, is
not sufficient as we have seen before. We also need to define the
environment in which the step has to be performed.

In other words, we need to understand *what* needs to run and *how* it
should run. `combine_plots`, for instance, takes as input a number of
plots (`png` images) and combines them into a plot. As introduced
earlier, we can use `ffmpeg` for this and it's then just a matter of
getting the proper arguments for the tool right. That's basically what
we did in the previous section. But it did not stop there, we had to
explicitly install the tool in order to run it.
[viash](https://github.com/data-intuitive/viash) allows to do exactly
this: specify the *what* and the *how*.

Before actually porting the Civilization postgame scripts to viash,
let's first look at some small examples to gradually demonstrate how
[viash](https://github.com/data-intuitive/viash) works. Let's start by
installing the latest release of
[viash](https://github.com/data-intuitive/viash)!

## Installing viash

Installation of [viash](https://github.com/data-intuitive/viash) is
explained in
[here](http://www.data-intuitive.com/viash_docs/getting_started/installation/).

Since we want to keep this tutorial self-contained, we will download and
install the latest (binary) release and install it locally. You'll need
the following for htis:

-   Access to a Linux, UNIX, Mac system or Windows with WSL(2)
-   A terminal application with a Bash shell
-   Java 8 or higher installed

You can install [viash](https://github.com/data-intuitive/viash) for
your current user by downloading it and placing it in the 'bin'
directory in your home folder.

``` {.sh}
mkdir -p ~/bin/
wget https://github.com/data-intuitive/viash/releases/download/v0.3.1/viash -qO ~/bin/viash
chmod +x ~/bin/viash
```

If [viash](https://github.com/data-intuitive/viash) is installed
correctly, you should be able to invoke the help message by executing
the following:

``` {.sh}
> viash -h
viash 0.3.1 (c) 2020 Data Intuitive

viash is a spec and a tool for defining execution contexts and converting execution instructions to concrete instantiations.

This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions. For more information, see our license at the link below.
  https://github.com/data-intuitive/viash/blob/master/LICENSE.md

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

## Example 1: a minimal viash config file

A core concept in [viash](https://github.com/data-intuitive/viash) is
the [viash config](https://www.data-intuitive.com/viash_docs/config),
which is a YAML file containing information on software component, such
as its parameters, its requirements, and some documentation.

Let us start with the smallest possible [viash
config](https://www.data-intuitive.com/viash_docs/config), which is an
almost trivial wrapper around `ls`. `ls` is a Unix command used to list
all files in a directory.

`src/intro_example1.vsh.yaml`:

``` {.yaml}
functionality:
  name: intro_example1
  resources:
    - type: executable
      path: ls
```

[`viash run`](https://www.data-intuitive.com/viash_docs/commands/run) is
a command for running a component as defined by the [viash
config](https://www.data-intuitive.com/viash_docs/config). You can run
it as follows:

``` {.sh}
> viash run src/intro_example1.vsh.yaml
Makefile
README.Rmd
README.html
bin
casts
src
```

Perhaps unsurprisingly, this performs an `ls` in the *current* directory
which in this case is where
[viash](https://github.com/data-intuitive/viash) is running. This
example, while illustrative, does not capture what
[viash](https://github.com/data-intuitive/viash) is and can be used for.
It's just a wrapper around the `ls` command.

Let's go one step further.

## Example 2: adding some arguments

Software components are (usually) not useful unless they have some
arguments which you can specify and change.

`src/intro_example2.vsh.yaml`:

``` {.yaml}
functionality:
  name: intro_example2
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

This is what happens when you run
[viash](https://github.com/data-intuitive/viash) in a few different
scenarios:

``` {.sh}
> viash run src/intro_example2.vsh.yaml
Makefile
README.Rmd
README.html
bin
casts
src
```

There is no difference with the previous version of the component. Now,
let us pass the argument `-l` to `intro_example2`:

``` {.sh}
> viash run src/intro_example2.vsh.yaml -- -l
total 288
-rw-r--r--   1 toni  staff    627 Feb  2 15:20 Makefile
-rw-r--r--   1 toni  staff  10627 Feb  2 15:20 README.Rmd
-rw-r--r--@  1 toni  staff  78827 Feb  2 16:55 README.html
drwxr-xr-x   9 toni  staff    288 Feb  2 15:22 bin
drwxr-xr-x  35 toni  staff   1120 Jan 27 16:00 casts
drwxr-xr-x   9 toni  staff    288 Jan 27 14:17 src
```

Please note that options *before* the `--` are considered for
[viash](https://github.com/data-intuitive/viash) while options after the
`--` are for the tool that is wrapped (in this case `ls`).

## Example 3: setting different argument types

Not all arguments are boolean flags such as specified in the previous
example. In this [viash
config](https://www.data-intuitive.com/viash_docs/config), we added an
extra argument that corresponds to the path which we want to *list*.

`src/intro_example3.vsh.yaml`:

``` {.yaml}
functionality:
  name: intro_example3
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

Running this component will still list the contents of the current
directory (like before).

``` {.sh}
> viash run src/intro_example3.vsh.yaml -- -l
total 288
-rw-r--r--   1 toni  staff    627 Feb  2 15:20 Makefile
-rw-r--r--   1 toni  staff  10627 Feb  2 15:20 README.Rmd
-rw-r--r--@  1 toni  staff  78827 Feb  2 16:55 README.html
drwxr-xr-x   9 toni  staff    288 Feb  2 15:22 bin
drwxr-xr-x  35 toni  staff   1120 Jan 27 16:00 casts
drwxr-xr-x   9 toni  staff    288 Jan 27 14:17 src
```

However, we can now also list the contents of a different directory.

``` {.sh}
> viash run src/intro_example3.vsh.yaml -- src/ -l
total 56
-rw-r--r--  1 toni  staff   89 Jan 27 14:17 intro_example1.vsh.yaml
-rw-r--r--  1 toni  staff  186 Jan 27 14:17 intro_example2.vsh.yaml
-rw-r--r--  1 toni  staff  239 Jan 27 14:17 intro_example3.vsh.yaml
-rw-r--r--  1 toni  staff  543 Jan 27 14:17 intro_example4.vsh.yaml
-rw-r--r--  1 toni  staff  613 Jan 27 14:17 intro_example5.vsh.yaml
-rw-r--r--  1 toni  staff  593 Jan 27 14:17 intro_example6.vsh.yaml
-rw-r--r--  1 toni  staff   58 Jan 27 14:17 script.sh
```

You can always retrieve information about the component by requesting
the included help.

``` {.sh}
> viash run src/intro_example3.vsh.yaml -- -h


Options:
    -l
        type: boolean_true

    -a
        type: boolean_true

    file
        type: file, default: .
```

Note that there are many more argument types than a flag or a file.
These are not very useful for now, but come in handy when wrapping
R/Python/JavaScript scripts. For more information, see the documentation
regarding the
[functionality](https://www.data-intuitive.com/viash_docs/config/functionality)
specifications.

## Example 4: adding documentation

The help from the last `intro_example3` does not show a lot of useful
information. Let's add some documentation regarding the component and
its parameters.

`src/intro_example4.vsh.yaml`:

``` {.yaml}
functionality:
  name: intro_example4
  version: 0.4
  description: |
    List information about the files (the current directory by default) 
    in alphabetical order.
  arguments:
    - name: "-l"
      type: boolean_true
      description: "Use a long listing format."
    - name: "-a"
      type: boolean_true
      description: "Do not ignore entries starting with '.'."
    - name: "path"
      type: file
      description: "Which directory to list the contents of."
      default: .
  resources:
    - type: executable
      path: ls
```

In doing so, the help message becomes a lot more useful in reminding
yourself and other users how to use the components.

``` {.sh}
> viash run src/intro_example4.vsh.yaml -- -h
List information about the files (the current directory by default) 
in alphabetical order.

Options:
    -l
        type: boolean_true
        Use a long listing format.

    -a
        type: boolean_true
        Do not ignore entries starting with '.'.

    file
        type: file, default: .
        Which directory to list the contents of.
```

## Example 4 part 2: building an *executable*

Suppose `intro_example4` from above is exactly what we need as
standalone tool for ourselves or other people to use. Obviously,
providing everyone access to
[viash](https://github.com/data-intuitive/viash) and then letting them
access the `intro_example4.vsh.yaml` file in order to run the above
commands would not simplify things at all!

Time to introduce a second
[viash](https://github.com/data-intuitive/viash) command, namely
[`viash build`](https://www.data-intuitive.com/viash_docs/commands/run).
This command takes a [viash
config](https://www.data-intuitive.com/viash_docs/config) as input, and
generates an executable as output.

``` {.sh}
> viash build src/intro_example4.vsh.yaml -o bin
```

After running the above command, viash will have generated a file at
`bin/intro_example4`. It contains all the functionality that we saw in
the above examples:

``` {.sh}
> bin/intro_example4 -h
List information about the files (the current directory by default) 
in alphabetical order.

Options:
    -l
        type: boolean_true
        Use a long listing format.

    -a
        type: boolean_true
        Do not ignore entries starting with '.'.

    file
        type: file, default: .
        Which directory to list the contents of.
```

``` {.sh}
> bin/intro_example4 src/ -l
total 56
-rw-r--r--  1 toni  staff   89 Jan 27 14:17 intro_example1.vsh.yaml
-rw-r--r--  1 toni  staff  186 Jan 27 14:17 intro_example2.vsh.yaml
-rw-r--r--  1 toni  staff  239 Jan 27 14:17 intro_example3.vsh.yaml
-rw-r--r--  1 toni  staff  543 Jan 27 14:17 intro_example4.vsh.yaml
-rw-r--r--  1 toni  staff  613 Jan 27 14:17 intro_example5.vsh.yaml
-rw-r--r--  1 toni  staff  593 Jan 27 14:17 intro_example6.vsh.yaml
-rw-r--r--  1 toni  staff   58 Jan 27 14:17 script.sh
```

You can now share this `bin/intro_example4` file with others, or add it
to your `~/bin` directory to turn it into a system-wide command.

## Example 5: running the component inside a Docker container

In the above examples, we ran the components on our local system. This
is simple as long as the wrapped tool at hand (`ls` in this case) is
always available on the local system. However, this assumption generally
does not hold true. [viash](https://github.com/data-intuitive/viash) not
only supports running components on the native system, but can also run
components inside a Docker container.

To make use of this functionality, we need to get into the the
'platforms' section of the [viash
config](https://www.data-intuitive.com/viash_docs/config), which can
contain one or more execution platforms. In this case, we defined
platforms: a *native* one (local machine) and a *docker* one.

`src/intro_example5.vsh.yaml`:

``` {.yaml}
functionality:
  name: intro_example5
  version: 0.5
  description: |
    List information about the files (the current directory by default) 
    in alphabetical order.
  arguments:
    - name: "-l"
      type: boolean_true
      description: "Use a long listing format."
    - name: "-a"
      type: boolean_true
      description: "Do not ignore entries starting with '.'."
    - name: "path"
      type: file
      description: "Which directory to list the contents of."
      default: .
  resources:
    - type: executable
      path: ls
platforms:
  - type: native
  - type: docker
    image: ubuntu:latest
```

By default, [viash](https://github.com/data-intuitive/viash) will use
the first platform specified in the [viash
config](https://www.data-intuitive.com/viash_docs/config), which in this
case the native platform. In order to build an executable which uses
Docker in the backend, we need to pass this information as follows:

``` {.sh}
> viash build src/intro_example5.vsh.yaml -o bin -p docker
```

The executable `bin/intro_example5` now automatically runs inside
Docker.

``` {.sh}
> bin/intro_example5 / -l
total 52
lrwxrwxrwx   1 root root    7 Jan 19 01:01 bin -> usr/bin
drwxr-xr-x   2 root root 4096 Apr 15  2020 boot
drwxr-xr-x   5 root root  340 Feb  2 15:55 dev
drwxr-xr-x   1 root root 4096 Feb  2 15:55 etc
drwxr-xr-x   2 root root 4096 Apr 15  2020 home
drwxr-xr-x   3 root root 4096 Feb  2 15:55 host_mnt
lrwxrwxrwx   1 root root    7 Jan 19 01:01 lib -> usr/lib
lrwxrwxrwx   1 root root    9 Jan 19 01:01 lib32 -> usr/lib32
lrwxrwxrwx   1 root root    9 Jan 19 01:01 lib64 -> usr/lib64
lrwxrwxrwx   1 root root   10 Jan 19 01:01 libx32 -> usr/libx32
drwxr-xr-x   2 root root 4096 Jan 19 01:01 media
drwxr-xr-x   2 root root 4096 Jan 19 01:01 mnt
drwxr-xr-x   2 root root 4096 Jan 19 01:01 opt
dr-xr-xr-x 188 root root    0 Feb  2 15:55 proc
drwx------   2 root root 4096 Jan 19 01:04 root
drwxr-xr-x   1 root root 4096 Jan 21 03:38 run
lrwxrwxrwx   1 root root    8 Jan 19 01:01 sbin -> usr/sbin
drwxr-xr-x   2 root root 4096 Jan 19 01:01 srv
dr-xr-xr-x  13 root root    0 Feb  2 14:22 sys
drwxrwxrwt   2 root root 4096 Jan 19 01:04 tmp
drwxr-xr-x   1 root root 4096 Jan 19 01:01 usr
drwxr-xr-x   1 root root 4096 Jan 19 01:04 var
drwxr-xr-x   1 root root 1380 Jan 30 13:25 viash_automount
```

If the `ubuntu` image is not yet available on your system, this command
will automatically fetch it before running the tool. You can verify for
yourself that the result of this listing is not the same as what you
would have if you ran on your local system.

Please note that if you wanted to do this exact thing by using Docker
itself, you would have to use a CLI instruction like

``` {.sh}
> docker run --rm -v /:/mount ubuntu:latest ls /mount/ -l
total 36
lrwxrwxrwx   1 root root   11 Jan 30 13:25 A -> /host_mnt/a
lrwxrwxrwx   1 root root   22 Jan 30 13:25 Applications -> /host_mnt/Applications
lrwxrwxrwx   1 root root   11 Jan 30 13:25 B -> /host_mnt/b
lrwxrwxrwx   1 root root   11 Jan 30 13:25 C -> /host_mnt/c
lrwxrwxrwx   1 root root   11 Jan 30 13:25 D -> /host_mnt/d
lrwxrwxrwx   1 root root   11 Jan 30 13:25 E -> /host_mnt/e
lrwxrwxrwx   1 root root   11 Jan 30 13:25 F -> /host_mnt/f
lrwxrwxrwx   1 root root   11 Jan 30 13:25 G -> /host_mnt/g
lrwxrwxrwx   1 root root   11 Jan 30 13:25 H -> /host_mnt/h
lrwxrwxrwx   1 root root   11 Jan 30 13:25 I -> /host_mnt/i
lrwxrwxrwx   1 root root   11 Jan 30 13:25 J -> /host_mnt/j
lrwxrwxrwx   1 root root   11 Jan 30 13:25 K -> /host_mnt/k
lrwxrwxrwx   1 root root   11 Jan 30 13:25 L -> /host_mnt/l
lrwxrwxrwx   1 root root   17 Jan 30 13:25 Library -> /host_mnt/Library
lrwxrwxrwx   1 root root   11 Jan 30 13:25 M -> /host_mnt/m
lrwxrwxrwx   1 root root   11 Jan 30 13:25 N -> /host_mnt/n
lrwxrwxrwx   1 root root   11 Jan 30 13:25 O -> /host_mnt/o
lrwxrwxrwx   1 root root   11 Jan 30 13:25 P -> /host_mnt/p
lrwxrwxrwx   1 root root   11 Jan 30 13:25 Q -> /host_mnt/q
lrwxrwxrwx   1 root root   11 Jan 30 13:25 R -> /host_mnt/r
lrwxrwxrwx   1 root root   11 Jan 30 13:25 S -> /host_mnt/s
lrwxrwxrwx   1 root root   16 Jan 30 13:25 System -> /host_mnt/System
lrwxrwxrwx   1 root root   11 Jan 30 13:25 T -> /host_mnt/t
lrwxrwxrwx   1 root root   11 Jan 30 13:25 U -> /host_mnt/u
lrwxrwxrwx   1 root root   15 Jan 30 13:25 Users -> /host_mnt/Users
lrwxrwxrwx   1 root root   11 Jan 30 13:25 V -> /host_mnt/v
lrwxrwxrwx   1 root root   17 Jan 30 13:25 Volumes -> /host_mnt/Volumes
lrwxrwxrwx   1 root root   11 Jan 30 13:25 W -> /host_mnt/w
lrwxrwxrwx   1 root root   11 Jan 30 13:25 X -> /host_mnt/x
lrwxrwxrwx   1 root root   11 Jan 30 13:25 Y -> /host_mnt/y
lrwxrwxrwx   1 root root   11 Jan 30 13:25 Z -> /host_mnt/z
lrwxrwxrwx   1 root root   11 Jan 30 13:25 a -> /host_mnt/a
lrwxrwxrwx   1 root root   11 Jan 30 13:25 b -> /host_mnt/b
drwxr-xr-x   2 root root 4096 Jan 19 14:29 bin
drwxr-xr-x   2 root root 4096 Jan 19 14:29 boot
lrwxrwxrwx   1 root root   11 Jan 30 13:25 c -> /host_mnt/c
lrwxrwxrwx   1 root root   15 Jan 30 13:25 cores -> /host_mnt/cores
lrwxrwxrwx   1 root root   11 Jan 30 13:25 d -> /host_mnt/d
drwxr-xr-x  10 root root 3140 Jan 30 13:25 dev
lrwxrwxrwx   1 root root   11 Jan 30 13:25 e -> /host_mnt/e
drwxr-xr-x   1 root root  200 Jan 30 13:25 etc
lrwxrwxrwx   1 root root   11 Jan 30 13:25 f -> /host_mnt/f
lrwxrwxrwx   1 root root   11 Jan 30 13:25 g -> /host_mnt/g
lrwxrwxrwx   1 root root   11 Jan 30 13:25 h -> /host_mnt/h
drwxr-xr-x   2 root root 4096 Jan 19 14:29 home
drwxr-xr-x  23 root root  736 May 17  2020 host_mnt
lrwxrwxrwx   1 root root   11 Jan 30 13:25 i -> /host_mnt/i
lrwxrwxrwx   1 root root   11 Jan 30 13:25 j -> /host_mnt/j
lrwxrwxrwx   1 root root   11 Jan 30 13:25 k -> /host_mnt/k
lrwxrwxrwx   1 root root   11 Jan 30 13:25 l -> /host_mnt/l
drwxr-xr-x   1 root root   60 Jan 30 13:25 lib
drwxr-xr-x   2 root root 4096 Jan 19 14:29 lib64
lrwxrwxrwx   1 root root   11 Jan 30 13:25 m -> /host_mnt/m
drwxr-xr-x   2 root root 4096 Jan 19 14:29 media
drwxr-xr-x   2 root root 4096 Jan 19 14:29 mnt
lrwxrwxrwx   1 root root   11 Jan 30 13:25 n -> /host_mnt/n
lrwxrwxrwx   1 root root   11 Jan 30 13:25 o -> /host_mnt/o
drwxr-xr-x   1 root root   60 Jan 30 13:25 opt
lrwxrwxrwx   1 root root   11 Jan 30 13:25 p -> /host_mnt/p
lrwxrwxrwx   1 root root   17 Jan 30 13:25 private -> /host_mnt/private
dr-xr-xr-x 192 root root    0 Jan 30 13:25 proc
lrwxrwxrwx   1 root root   11 Jan 30 13:25 q -> /host_mnt/q
lrwxrwxrwx   1 root root   11 Jan 30 13:25 r -> /host_mnt/r
drwxr-xr-x   2 root root 4096 Jan 19 14:29 root
drwxr-xr-x   1 root root  360 Jan 30 13:30 run
lrwxrwxrwx   1 root root   11 Jan 30 13:25 s -> /host_mnt/s
drwxr-xr-x   2 root root 4096 Jan 19 14:29 sbin
drwxr-xr-x   2 root root 4096 Jan 19 14:29 srv
dr-xr-xr-x  13 root root    0 Feb  2 14:22 sys
lrwxrwxrwx   1 root root   11 Jan 30 13:25 t -> /host_mnt/t
drwxr-xr-x   1 root root   40 Feb  1 18:56 tmp
lrwxrwxrwx   1 root root   11 Jan 30 13:25 u -> /host_mnt/u
drwxr-xr-x   1 root root  100 Jan 30 13:25 usr
lrwxrwxrwx   1 root root   11 Jan 30 13:25 v -> /host_mnt/v
drwxr-xr-x   1 root root   60 Jan 19 14:29 var
lrwxrwxrwx   1 root root   11 Jan 30 13:25 w -> /host_mnt/w
lrwxrwxrwx   1 root root   11 Jan 30 13:25 x -> /host_mnt/x
lrwxrwxrwx   1 root root   11 Jan 30 13:25 y -> /host_mnt/y
lrwxrwxrwx   1 root root   11 Jan 30 13:25 z -> /host_mnt/z
```

While this is all still manageable, it could quickly become more
complicated, but that is for a later section. In what follows, we will
also come back not only to running inside a container but also
generating a container (based on a base image), tagging and versioning.

## Example 6: Wrapping a script

While running a command wrapped as a
[viash](https://github.com/data-intuitive/viash) component could be
useful in *some* form or another, we will usually want to run something
a bit more custom or elaborate. Say you want to run the `intro_example5`
component from above but this time filtering out certain
files/directories based on their name. We could do just that by means of
a simple CLI instruction that we put in a script:

`src/script.sh`:

``` {.sh}
#!/bin/bash

eval "ls \"$par_path\" | grep '$par_filter'"
```

In combination with the following [viash
config](https://www.data-intuitive.com/viash_docs/config):

`src/intro_example6.vsh.yaml`:

``` {.yaml}
functionality:
  name: intro_example6
  version: 0.6
  description: |
    List information about the files (the current directory by default) 
    in alphabetical order, filtered by a regular expression.
  arguments:
    - name: "path"
      type: file
      description: "Which directory to list the contents of."
      default: .
    - name: "--filter"
      type: string
      description: "A regular expression to filter the listed files."
      default: '.*'
  resources:
    - type: bash_script
      path: script.sh
platforms:
  - type: native
  - type: docker
    image: ubuntu:latest
```

We get results like this:

``` {.sh}
> viash run src/intro_example6.vsh.yaml -p docker -- /etc --filter "^h.*"
hosts
hosts.equiv
```

A lot is happening here at once, so let's unwrap this. We did not
*build* the executable in this example, but just run
[`viash run`](https://www.data-intuitive.com/viash_docs/commands/run) on
on the [viash config](https://www.data-intuitive.com/viash_docs/config).
This config contains a pointer (relative path) to the `script.sh` file
that contains parameters. Those parameters are defined in the [viash
config](https://www.data-intuitive.com/viash_docs/config) and are
automatically resolved and parsed when running the wrapped
[viash](https://github.com/data-intuitive/viash) version of the script.
The `docker` platform is defined in the [viash
config](https://www.data-intuitive.com/viash_docs/config) as well, so we
can just run it inside the respective container. The `--filter` argument
takes a regular expression, it is simply passed to `grep` in
`script.sh`.

Please note that when we decide to *build* a `intro_example6` executable
(for a specific platform), again this executable is self-contained. It
includes the necessary Docker information, command line parsing logic
and the script itself. So there is not need for additional
customization.

If you would want to achieve something similar with just Docker without
[viash](https://github.com/data-intuitive/viash), you are in for some
serious Bash development. But it does not stop here, because in addition
to support for wrapping Bash scripts,
[viash](https://github.com/data-intuitive/viash) also supports wrapping
Python, R, JavaScript, and Scala scripts.