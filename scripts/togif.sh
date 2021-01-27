#!/bin/sh

for file in casts/*.cast; do
  asciicast2gif $file $file.gif
done
