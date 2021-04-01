#!/bin/bash
################################################################################
# File:    buildDocs.sh
# Purpose: Script that builds our documentation using sphinx and updates GitHub
#          Pages.
#
# Original Author: Michael Atlfield <michael@michaelaltfield.net>
# Modified: awkwardMathNerd
# Created: 2020-07-17
# Updated: 2021-04-01
# Version: 0.1
################################################################################
 
###################
# INSTALL DEPENDS #
###################
 
apt-get update
apt-get -y install git rsync python3-sphinx python3-sphinx-rtd-theme
 
#####################
# DECLARE VARIABLES #
#####################
 
pwd
ls -lah
export SOURCE_DATE_EPOCH=$(git log -1 --pretty=%ct)
 
##############
# BUILD DOCS #
##############
 
# build our documentation with sphinx (see docs/conf.py)
#make -C docs clean
#make -C docs html
 
#######################
# Update GitHub Pages #
#######################
 
git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
 
docroot=`mktemp -d`
rsync -av "docs/_build/html/" "${docroot}/"
 
pushd "${docroot}"
 
# don't bother maintaining history; just generate fresh
<<<<<<< HEAD
#git init
#git remote add deploy "https://token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git clone "https://token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git checkout -b gh-pages-pull gh-pages

#shopt -s extglob
#rm -- !(".git"|".git/*")

popd

# Build the DOCS
make -C docs clean
make -C docs html

pushd "${docroot}"
=======
git init
git remote add deploy "https://token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git checkout -b gh-pages

# Branch into gh-pages-pull
git branch gh-pages-pull
>>>>>>> parent of 33cc4da (Update buildDocs.sh)
 
# add .nojekyll to the root so that github won't 404 on content added to dirs
# that start with an underscore (_), such as our "_content" dir..
touch .nojekyll
 
# Add README
cat > README.md <<EOF
# GitHub Pages Cache
 
Nothing to see here. The contents of this branch are essentially a cache that's not intended to be viewed on github.com.

DO NOT commit ANYTHING to this branch, it is automatically done when a commit is pulled into 'master'
EOF
 
# copy the resulting html pages built from sphinx above to our new git repo
git add .
 
# commit all the new files
msg="Updating Docs for commit ${GITHUB_SHA} made on `date -d"@${SOURCE_DATE_EPOCH}" --iso-8601=seconds` from ${GITHUB_REF} by ${GITHUB_ACTOR}"
git commit -am "${msg}"
 
# overwrite the contents of the gh-pages branch on our github.com repo
git push deploy gh-pages-pull --force
# Need to add pull request code here
 
popd # return to main repo sandbox root