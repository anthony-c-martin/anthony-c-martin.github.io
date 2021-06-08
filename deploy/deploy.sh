#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

az deployment sub create --location "East US 2" --name "blog-deploy" --template-file $SCRIPT_DIR/main.bicep