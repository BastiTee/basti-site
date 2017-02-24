#!/bin/bash

# cd to script's dir
cd "$( dirname "$( readlink -f "$0" )")"

# create copies of default files
for file in _posts _config.yml _includes/site-ext.html _includes/footer.html _includes/script.js
do
  if [ -L "$file" ]
  then
    echo "-- file $file present as symlink."
  elif [ -e "$file" ]
  then
    echo "-- file $file already present."
  else
    echo "-- will copy $file from default."
    cp -vr ${file}.default ${file}
  fi
done
echo

# startup jekyll
jekyll server --watch --host localhost --port 8000

# cleanup
rm -rf _site
