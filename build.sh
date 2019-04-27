#!/bin/sh

. ~/.docker_build
TARGET_IMAGE="${DOCKER_USERNAME}/${PWD##*/}"

# generate the image tag
#export TARGET_IMAGE_TAG=$(if [ "$TRAVIS_BRANCH" = "master" ]; then if [ "$TAG_SUFFIX" = "" ]; then echo "latest"; else echo "$TAG_SUFFIX"; fi; else if [ "$TAG_SUFFIX" = "" ]; then echo "$TRAVIS_BRANCH"; else echo "$TRAVIS_BRANCH-$TAG_SUFFIX"; fi; fi)
if [ "`git branch | grep \* | cut -d ' ' -f2`" = "master" ]
then
  export TARGET_IMAGE_TAG="latest-${TAG_SUFFIX}"
else
  export TARGET_IMAGE_TAG="`git branch | grep \* | cut -d ' ' -f2`-${TAG_SUFFIX}"
fi

# pull the existing image from the registry, if it exists, to use as a build cache
docker pull $SOURCE_IMAGE:$SOURCE_IMAGE_TAG && export IMAGE_CACHE="--cache-from $SOURCE_IMAGE:$SOURCE_IMAGE_TAG" || export IMAGE_CACHE=""

# build the image, login and push
docker build -f "$DOCKERFILE" $IMAGE_CACHE --build-arg MH_ARCH=$SOURCE_IMAGE --build-arg MH_TAG=$SOURCE_IMAGE_TAG -t "$TARGET_IMAGE:$TARGET_IMAGE_TAG" .
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
docker push $TARGET_IMAGE:$TARGET_IMAGE_TAG

# push alternate tags
if [ -z "$ALT_SUFFIX" ]; then
  echo "No alternate tags set for this build.";
else
  echo "Tagging with alternate tag '$ALT_SUFFIX'";
  #export ALT_IMAGE_TAG=$(if [ "$TRAVIS_BRANCH" = "master" ]; then if [ "$ALT_SUFFIX" = "" ]; then echo "error"; else echo "$ALT_SUFFIX"; fi; else if [ "$ALT_SUFFIX" = "" ]; then echo "$TRAVIS_BRANCH"; else echo "$TRAVIS_BRANCH-$ALT_SUFFIX"; fi; fi);
  if [ "`git branch | grep \* | cut -d ' ' -f2`" = "master" ]
  then
    export ALT_IMAGE_TAG="latest-${ALT_SUFFIX}"
  else
    export ALT_IMAGE_TAG="`git branch | grep \* | cut -d ' ' -f2`-${ALT_SUFFIX}"
  fi
  docker tag $TARGET_IMAGE:$TARGET_IMAGE_TAG $TARGET_IMAGE:$ALT_IMAGE_TAG;
  docker push $TARGET_IMAGE:$ALT_IMAGE_TAG;
fi

if [ -n $PUSHOVER_USER ] and [ -n $PUSHOVER_TOKEN ]
then
  /usr/bin/curl -s --form-string "token=$PUSHOVER_TOKEN" --form-string "user=$PUSHOVER_USER"  --form-string "title=Docker Build" --form-string "message=Docker build  for $TARGET_IMAGE_TAG is now complete" https://api.pushover.net/1/messages.json
fi
