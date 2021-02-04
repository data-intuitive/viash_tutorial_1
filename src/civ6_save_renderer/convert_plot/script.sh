#!/bin/bash

## VIASH START
par_input=input.pdf
par_output=output.png
## VIASH END

convert "$par_input" -flatten "$par_output"
