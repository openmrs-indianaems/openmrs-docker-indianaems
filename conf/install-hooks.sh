#!/bin/bash
################################################################################
# Installs our git hooks by adding symlinks to them within .git/hooks/ folder

# Allow user to run script from root of project or within conf folder
GIT_HOOKS_DIR=".git/hooks"
if [ ${PWD##*/} = conf ]; then
  GIT_HOOKS_DIR="../.git/hooks"
fi

echo -n "Install git hooks..."
ln -s -f ../../conf/hooks/post-merge.git-crypt.sh $GIT_HOOKS_DIR/post-merge
ln -s -f ../../conf/hooks/pre-commit.git-crypt.sh $GIT_HOOKS_DIR/pre-commit

# Apply post-merge permission changes to protect git-crypt files
$GIT_HOOKS_DIR/post-merge

echo "done."