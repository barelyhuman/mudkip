#!/usr/bin/env bash

set -euxo pipefail


## Generate docs for the functions and codes snippets written in the library 
## these are usefull for understand why a certain function was implemented 
## and are already accompanied by their documentation but a reference site 
## helps with quickly referencing stuff.

nim doc --outdir:code-docs --project src/mudkip.nim