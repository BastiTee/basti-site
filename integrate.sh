#!/bin/bash

# cd to script's dir
cd "$( dirname "$( readlink -f "$0" )")"

git fetch upstream
git merge upstream/master
