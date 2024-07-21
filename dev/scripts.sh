#!/bin/bash

function create_build_folder() {
  echo 'create build folder'
  mkdir -p build
}

function copy_assets() {
  echo 'copy assets'
  cp -r src/public/* build
}

function build_css() {
  echo 'build css'
  sed -i -e '/\/\*style\*\//r src/style.css' build/*.html
}

function build() {
  echo 'build...'
  create_build_folder &&
    copy_assets &&
    build_css &&
    echo '...done'
}

case "$1" in
"") ;;
build)
  "$@"
  exit
  ;;
*)
  echo "Unkown function $1"
  exit 2
  ;;
esac
