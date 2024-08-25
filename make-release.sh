#!/bin/sh

ts=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
git tag -m "${ts}" -a "${ts}"
git push --tags
