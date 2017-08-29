#!/bin/bash

cd "$( dirname "$( readlink -f "$0" )")"
CURRDIR="$( readlink -f $( pwd ))"
echo "Initializing content from $CURRDIR"

echo "Creating copies of default files..."
for file in _posts _config.yml _includes/site-ext.html _includes/footer.html _includes/script.js _includes/tracking.html
do
  if [ -L "$file" ]
  then
    echo "File $file present as symlink."
  elif [ -e "$file" ]
  then
    echo "File $file already present."
  else
    echo "Will copy $file from default."
    cp -vr ${file}.default ${file}
  fi
done

echo "Creating blog resource folder..."
mkdir -p res/blogres
