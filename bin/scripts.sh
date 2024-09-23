#!/bin/bash

function create_build_directory() {
  echo 'Create Build Directory'
  mkdir -p build
}

function copy_assets() {
  echo 'Copy Assets'
  cp -r src/public/* build
}

function insert_contents() {
  sed -i -e "/$1/r $2" "$3"
}

function insert_value() {
  sed -i "s/$1/$2/g" "$3"
}

function build_css() {
  echo "Build CSS"
  insert_contents "\/\*style\*\/" "src/style.css" "$1"
}

function build_head() {
  echo "Build Head"
  insert_contents "<!-- head -->" "src/head.html" "$1"
  insert_value "<!-- title -->" "Haas \& Milan $2" "$1"
  insert_value "::meta_description::" "$3" "$1"
}

function build() {
  echo 'starting build...'
  create_build_directory &&
    copy_assets &&
    render_pages "$1"
    echo '...done'
}

function clean() {
  echo 'removing build directory'
  rm -rf build
}

function deploy() {
  echo "todo: Deploy"
}

function dev() {
  echo 'starting dev server'
  build &&
    (cd build/ && ws --https)
}

function build_file() {
  echo "Build File: $1"
  build_head "$1" "$2" "This is the $2 page" &&
  build_css "$1"
}

function render() {
  echo "Render Page: $1"
  fileName="build/$1.html"
  cp src/page.html "$fileName"
  build_file "$fileName" "$1"
}


function render_pages() {
  echo "Rendering Pages From Table: $1"
  for page in $(bin/db.sh read_table "$1" | jq -r ".Items[].pageName.S"); do render "$page"; done

  build_file build/404.html 'Not Found'
  build_file build/503.html 'Error'
}

case "$1" in
"") ;;
build | clean | dev | create_articles_table | delete_articles_table | render_pages | create_item | render)
  "$@"
  exit
  ;;
*)
  echo "Unkown function $1"
  exit 2
  ;;
esac
