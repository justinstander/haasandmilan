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

case "$1" in
"") ;;
build | clean | dev | create_articles_table)
  "$@"
  exit
  ;;
*)
  echo "Unkown function $1"
  exit 2
  ;;
esac
