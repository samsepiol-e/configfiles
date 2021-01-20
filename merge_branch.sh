#!/bin/sh
set -e
OPT_CONTINUE="false"
OPT_CHECKOUT="false"
OPT_DELREMOTE="true"
while getopts "bt:cl" o; do
    case "$o" in
        b) BRANCHNAME="$OPTARGS"
           OPT_CHECKOUT="true"
            ;;
        t) TAGNAME="$OPTARGS" ;;
        c)  OPT_CONTINUE="true" ;;
        l)  OPT_DELREMOTE="false" ;;
        [?]) print >$2 "Usage: $0 [-b branch] [-t tagname] [-c] [-l]"
            exit 1;
    esac
done
shift $(($OPTIND-1))
if ${OPT_CHECKOUT}; then
    git checkout "$BRANCHNAME"
else
    BRANCHNAME="$(git rev-parse --abbrev-ref HEAD)"
fi
IFS='/' read -r -a array <<< "$BRANCHNAME"
BRANCHTYPE="${array[0]}"
CURRENTVERSION="${array[1]}"
echo $BRANCHTYPE
echo $CURRENTVERSION
echo $BRANCHNAME
if [ $BRANCHTYPE == "release" ]; then
    OPT_DELREMOTE="false"
fi


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
if ${OPT_CONTINUE}; then
    git checkout develop
    git merge --no-ff "$BRANCHNAME"
    git push
else
    for i in "${array[@]}"
    do
        git checkout "$i"
        git merge --no-ff "$BRANCHNAME"
        if [ $i == 'master' ]; then
            git tag -a "v$CURRENTVERSION"
        fi
        if [ ! "$OPT_DELREMOTE" ]; then
            git push
        fi
    done
    if [ ! "$OPT_DELREMOTE" ]; then
        git push origin -d "$BRANCHNAME"
    fi
    git branch -d "$BRANCHNAME"
fi
