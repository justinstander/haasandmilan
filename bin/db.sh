#!/bin/bash

function create_table() {
  echo "create table $1"

  aws dynamodb create-table \
    --table-name "$1" \
    --key-schema file://bin/db/key-schema.json \
    --attribute-definitions file://bin/db/attribute-definitions.json \
    --provisioned-throughput file://bin/db/privisioned-throughput.json
}

function read_table() {
  aws dynamodb scan --table-name "$1"
}

function create_item {
  echo "creating item in table $1"
  echo "$2:$3"

  aws dynamodb put-item --table-name "$1" --item "{\"$2\":{\"S\":\"$3\"}}"
}

function delete_table() {
  echo "THIS WILL DELETE THE TABLE $1"
  read -p "Cancel now, or press any key to continue"
  aws dynamodb delete-table --table-name "$1"
}

case "$1" in
"") ;;
create_table | read_table | create_item | delete_table)
  "$@"
  exit
  ;;
*)
  echo "Unkown function $1"
  exit 2
  ;;
esac
