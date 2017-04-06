#!/bin/bash

# cd to script's dir
cd "$( dirname "$( readlink -f "$0" )")"

git remote add upstream git@github.com:BastiTee/localhost.git 2> /dev/null
git fetch upstream
git merge upstream/master
