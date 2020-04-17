#!/bin/sh

if [ $# -lt 1 ]
then
  echo "this needs a tag please"
  exit 1
else
  TAG=$1
fi

git checkout master
git pull;
git checkout "${TAG}"
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 \
       -t mhzawadi/invoiceplane:${TAG} --push .
