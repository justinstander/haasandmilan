#!/bin/bash

mkdir -p build && \
cp -r src/public/* build && \
sed -i -e '/\/\*style\*\//r src/style.css' build/*.html
