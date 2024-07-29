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
  find build -type f -name "*.html" -exec sed -i -e "/$1/r $2" {} +
}

function build_css() {
  echo 'build css'
  insert_contents "\/\*style\*\/" "src/style.css"
}

function build_head() {
  echo 'build head'
  insert_contents "<!-- head -->" "src/head.html" 
}

function build() {
  echo 'build...'
  create_build_directory &&
    copy_assets &&
    render_pages &&
    build_head &&
    build_css &&
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

function create_page() {
  echo "Create page $1";
  cp src/page.html "build/$1.html"
}

function render_pages() {
  echo "Rendering pages in DB..."
  for page in $(aws dynamodb scan --table-name articles | jq -r ".Items[].pageName.S"); do create_page "$page"; done;
  echo "...done"
}

case "$1" in
"") ;;
build | clean | dev | create_articles_table | delete_articles_table | render_pages | create_page)
  "$@"
  exit
  ;;
*)
  echo "Unkown function $1"
  exit 2
  ;;
esac
