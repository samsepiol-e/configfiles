#!/bin/bash
version=$(cat currentversion)
#version="$2"
major=0
minor=0
build=0
echo $2
# break down the version number into it's components
regex="([0-9]+).([0-9]+).([0-9]+)"
if [[ $version =~ $regex ]]; then
  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  build="${BASH_REMATCH[3]}"
fi

# check paramater to see which number to increment
if [[ "$1" == "feature" ]]; then
  minor=$(echo $minor + 1 | bc)
  build=0
elif [[ "$1" == "hotfix" ]]; then
  build=$(echo $build + 1 | bc)
elif [[ "$1" == "release" ]]; then
  minor=$(echo $minor+1 | bc)
  build=0
  minor=0
elif [[ "$1" == "major" ]]; then
  major=$(echo $major+1 | bc)
  build=0
  minor=0
else
  echo "usage: ./version.sh [release/major/feature/hotfix]"
  exit -1
fi

# echo the new version number
if [[ "$1" == "hotfix" ]]; then
  branch_origin="master"
else 
  branch_origin="develop"
fi
echo "old version : $version"
echo "new version : ${major}.${minor}.${build}"
echo "${major}.${minor}.${build}">currentversion
#adding current version
git add currentversion
git checkout -b $1/${major}.${minor}.${build} $branch_origin
