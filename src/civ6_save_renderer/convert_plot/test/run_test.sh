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
