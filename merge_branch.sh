#!/bin/sh
set -e
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
            ;;
        major)
            echo "master develop"
            ;;
    esac
}
branches=`get_merge_branches`
IFS=' ' read -r -a array <<< "$branches"
#if -c flag is used, only merge to develop without deleting current branch
if [ "$1" = '-c' ]; then
    git checkout develop
    git merge --no-ff "$BRANCHNAME"
    git push
else
    for i in "${array[@]}"
    do
        git checkout "$i"
        git merge --no-ff "$BRANCHNAME"
        if [ $i = 'master' ]; then
            git tag -a "$CURRENTVERSION"
        fi
        git push
    done
    git push origin -d "$BRANCHNAME"
    git branch -d "$BRANCHNAME"
fi
