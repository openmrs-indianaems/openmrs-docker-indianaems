#!/bin/bash
################################################################################
# Ensure files secured by git-crypt are not readable by group or others
#
# Usage: 
#    $ cd .git/hooks
#    $ ln -s ../../conf/hooks/post-merge.git-crypt.sh post-merge
#

# Loop through files encrypted by git-crypt and remove read access from group or others
if [ -d .git-crypt ]; then

  # Display warning if git-crypt isn't installed
  command -v git-crypt >/dev/null 2>&1 || { echo >&2 "WARNING: This repo uses git-crypt. Please install git-crypt."; exit 1; }

  ENCRYPTED_FILES=$(git-crypt status -e | sed -n -e 's/^[[:space:]]*encrypted:[[:space:]]//p')
  for FILE in $ENCRYPTED_FILES
  do
    chmod go-r $FILE
  done
fi