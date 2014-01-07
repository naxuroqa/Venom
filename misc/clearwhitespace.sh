#!/bin/sh
for i in $*; do
  sed 's/\s\+$//g' -i $i
done
