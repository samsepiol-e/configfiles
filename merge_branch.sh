#!/bin/sh
set -eu
BRANCHNAME="$(git rev-parse --abbrev-ref HEAD)"
IFS='/' read -r -a array <<< "$BRANCHNAME"
BRANCHTYPE="${array[0]}"
CURRENTVERSION="${array[1]}"
echo $BRANCHTYPE
echo $CURRENTVERSION
echo $BRANCHNAME


get_merge_branches() {
    case $BRANCHTYPE in
        feature)
            echo "develop"
            ;;
        hotfix)
            echo "master develop"
            ;;
        release)
            echo "master develop"
    esac
}
branches=`get_merge_branches`
IFS=' ' read -r -a array <<< "$branches"
for i in "${array[@]}"
do
    git checkout "$i"
    echo $BRANCHNAME
    git merge --no-ff "$BRANCHNAME"
    if [ $i = 'master' ]; then
        git tag -a "$CURRENTVERSION"
    fi
done
