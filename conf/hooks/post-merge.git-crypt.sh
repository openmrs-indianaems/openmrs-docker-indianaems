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
  ENCRYPTED_FILES=$(git-crypt status -e | sed -n -e 's/^[[:space:]]*encrypted:[[:space:]]//p')
  for FILE in $ENCRYPTED_FILES
  do
    chmod go-r $FILE
  done
fi