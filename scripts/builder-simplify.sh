#! /bin/sh

echo "running gtk-builder-tool simplify on all ui files"

cd "${MESON_SOURCE_ROOT}"

for i in `find src -name "*.ui"`
do
  echo $i
  gtk-builder-tool simplify --replace $i
done


if [[ $? != 0 ]]; then
  echo >&2 "builder-simplify command failed."
  retval=1
fi
