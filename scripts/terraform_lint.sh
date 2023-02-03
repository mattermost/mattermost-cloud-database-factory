#!/usr/bin/env bash

# Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
# See LICENSE.txt for license information.

set -o errexit
set -o nounset
set -o pipefail

maindir=$PWD/
for d in terraform/aws/* ; do
    pushd $d
    terraform fmt -check
    tflint --config $maindir/.tflint.hcl
    popd
done

for d in terraform/aws/modules/* ; do
    pushd $d
    terraform fmt -check
    tflint --config $maindir/.tflint.hcl
    popd
done