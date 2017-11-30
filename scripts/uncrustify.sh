#! /bin/sh

echo "running uncrustify check on all source files"

cd "${MESON_SOURCE_ROOT}"

for i in `find src -name "*.vala"`
do
  uncrustify -c uncrustify.cfg --replace --no-backup $i
done
