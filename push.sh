#!/usr/bin/env bash

# Push mage according to repo name
set -x
. build.properties
docker push $REPO_NAME:$MARIADB_VERSION $MARIADB_VERSION
