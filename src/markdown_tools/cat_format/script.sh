#!/bin/bash

echo ""
echo "\`$par_input\`:"
echo ""

echo '```'"$par_format"
if [ $par_cut ]; then 
  head "$par_input"
  echo ... (cut) ...
else
  cat "$par_input"
  echo ""
fi
echo '```'
