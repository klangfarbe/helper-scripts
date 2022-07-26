#!/bin/bash
set -euo pipefail

git fetch

BRANCH_NAME=`git rev-parse --abbrev-ref HEAD`
BRANCH_START=`git log origin/master..HEAD  --oneline | tail -1 | awk '{print $1}'`
BRANCH_HEAD_SHA_OLD=`git rev-parse HEAD`
SUBTREE_BRANCHES=(`git branch -r --contains ${BRANCH_START} | grep -vE "HEAD|$BRANCH_NAME"`)

################################################################################
# Rebase HEAD branch
################################################################################
echo "######## Rebasing $BRANCH_NAME to origin/master"
git rebase origin/master || exit 1

# ################################################################################
# # Rebase subtree
# ################################################################################
for subtree in ${SUBTREE_BRANCHES[@]}; do
    echo
    echo "######## Rebasing $subtree to $BRANCH_NAME"
    git checkout --track $subtree || exit 1
    git rebase --onto $BRANCH_NAME $BRANCH_HEAD_SHA_OLD || exit 1
done

################################################################################
# Push all rebased branches
################################################################################
ALL_BRANCHES=(`git branch -l --format '%(refname)' | sed -e 's/refs\/heads\///'`)
for branch in ${ALL_BRANCHES[@]}; do
    echo
    echo "######## Pushing $branch"
    git checkout -q $branch || exit 1
    git push --force-with-lease origin $branch || exit 1
done
