#!/bin/bash

function print() {
    [ ! -z $( command -v tput ) ] && {
        echo "$( tput setaf 1 )$@$( tput sgr0 )"
    } || {
        echo $@
    }
}

print "Preparing execution environment..."
[ -z $( command -v docker ) ] && {
  echo "Script requires docker."
  exit 1
}
cd "$( dirname "$( readlink -f "$0" )")"
DOCKER_IMG="alpine/jekyll-minimal:latest"
CURRDIR="$( readlink -f $( pwd ))"
print "Running content from $CURRDIR"

print "Creating copies of default files..."
for file in _posts _config.yml _includes/site-ext.html _includes/footer.html _includes/script.js
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

print "Building docker image..."
docker build -t $DOCKER_IMG - < Dockerfile

print "Running page using docker..."
docker run --rm -v ${CURRDIR}:/workdir -p 8000:8000 alpine/jekyll-minimal \
server -s /workdir -d /workdir/_site --port 8000 --host 0.0.0.0
