#!/bin/bash

echo ""
echo "\`$par_input\`:"
echo ""

echo '```'"$par_format"
cat "$par_input"
echo ""
echo '```'
