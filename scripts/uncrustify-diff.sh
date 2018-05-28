#! /bin/sh

echo "running uncrustify check on all source files"

cd "${MESON_SOURCE_ROOT}"

for i in `find src -name "*.vala"`
do
  uncrustify -c uncrustify.cfg -q -f $i | git --no-pager diff --no-index -- $i - 
done
