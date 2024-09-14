#!/bin/bash

function create_build_directory() {
  echo 'create build directory'
  mkdir -p build
}

function copy_assets() {
  echo 'copy assets'
  cp -r src/public/* build
}

function insert_contents() {
  echo "writing to $3"
  sed -i -e "/$1/r $2" "$3"
}

function insert_value() {
  sed -i "s/$1/$2/g" "$3"
}

function build_css() {
  echo "build css $1"
  insert_contents "\/\*style\*\/" "src/style.css" "$1"
}

function build_head() {
  echo "build head $1 $2 $3"
  insert_contents "<!-- head -->" "src/head.html" "$1"
  insert_value "<!-- title -->" "Haas \& Milan $2" "$1"
  insert_value "::meta_description::" "$3" "$1"
}

function build() {
  echo 'build...'
  create_build_directory &&
    copy_assets &&
    render_pages "$1"
    echo '...done'
}

function clean() {
  echo 'removing build directory'
  rm -rf build
}

function dev() {
  echo 'starting dev server'
  build &&
    (cd build/ && ws --https)
}

function create_articles_table() {
  echo 'creating articles table...'
  aws dynamodb create-table --table-name articles --key-schema AttributeName=pageName,KeyType=HASH --attribute-definitions AttributeName=pageName,AttributeType=S --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
}

function delete_articles_table() {
  echo "THIS WILL DELETE THE ARTICLES TABLE"
  read -p "Cancel now, or press any key to continue"
  aws dynamodb delete-table --table-name articles
}

function create_item {
  echo "creating item in table $1..."
  echo "$2:$3"
  aws dynamodb put-item --table-name "$1" --item "{\"$2\":{\"S\":\"$3\"}}"
  echo "...done"
}

function build_file() {
  build_head "$1" "$2" "This is the $2 page" &&
  build_css "$1"
}

function render() {
  echo "Create page $1"
  fileName="build/$1.html"
  cp src/page.html "$fileName"
  build_file "$fileName" "$1"
}

function render_pages() {
  echo "Rendering pages in DB table: $1"
  for page in $(aws dynamodb scan --table-name "$1" | jq -r ".Items[].pageName.S"); do render "$page"; done
  
  cp src/public/*.html build/
  build_file build/404.html 'Not Found'
  build_file build/503.html 'Error'
  
  echo "...done"
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