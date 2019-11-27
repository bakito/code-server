#!/bin/sh

if [ "$#" -ne 1 ] || ( ! [ -d "$1" ] && ! [ -f "$1" ]  ) ;  then
  echo "Usage: $0 PATH" >&2
  exit 1
fi

# Fix permissions on the given directory to allow group read/write of 
# regular files and execute of directories.
find $1 -follow -exec chgrp 0 {} \;
find $1 -follow -exec chmod g+rw {} \;
find $1 -follow -type d -exec chmod g+x {} +