#!/bin/bash -x

echo "##################### EXECUTE: openvidu_ci_container_job_setup #####################"

[ -z "$OPENVIDU_GIT_REPOSITORY" ] && OPENVIDU_GIT_REPOSITORY=$GIT_URL
[ -z "$BUILD_COMMAND" ] && exit 1
[ -z "$CONTAINER_IMAGE" ] && exit 1

WORKSPACE=/opt
MAVEN_OPTIONS="--batch-mode --settings /opt/openvidu-settings.xml -DskipTests=false"
CONTAINER_MAVEN_SETTINGS=/opt/openvidu-settings.xml
CONTAINER_ADM_SCRIPTS=/opt/adm-scripts
CONTAINER_PRIVATE_RSA_KEY=/opt/git_id_rsa
CONTAINER_NPM_CONFIG=/root/.npmrc
CONTAINER_GPG_PRIVATE_BLOCK=/root/.gpgpriv
CONTAINER_GIT_CONFIG=/root/.gitconfig
CONTAINER_AWS_CONFIG=/root/.aws/config
CONTAINER_HTTP_CERT=/opt/http.crt
CONTAINER_HTTP_KEY=/opt/http.key

docker run \
  --name $BUILD_TAG-JOB_SETUP-$(date +"%s") \
  --rm \
  -e "MAVEN_OPTIONS=$MAVEN_OPTIONS" \
  -e OPENVIDU_GIT_REPOSITORY=$OPENVIDU_GIT_REPOSITORY \
  -v $OPENVIDU_ADM_SCRIPTS_HOME:$CONTAINER_ADM_SCRIPTS \
  $([ -f "$GITHUB_PRIVATE_RSA_KEY" ] && echo "-v $GITHUB_PRIVATE_RSA_KEY:$CONTAINER_PRIVATE_RSA_KEY" ) \
  $([ "${OPENVIDU_GITHUB_TOKEN}x" != "x" ] && echo "-e GITHUB_KEY=$OPENVIDU_GITHUB_TOKEN" ) \
  $([ -f "$MAVEN_SETTINGS" ] && echo "-v $MAVEN_SETTINGS:$CONTAINER_MAVEN_SETTINGS") \
  $([ -f "$NPM_CONFIG" ] && echo "-v $NPM_CONFIG:$CONTAINER_NPM_CONFIG") \
  $([ -f "$GPG_PRIVATE_BLOCK" ] && echo "-v $GPG_PRIVATE_BLOCK:$CONTAINER_GPG_PRIVATE_BLOCK") \
  $([ -f "$GIT_CONFIG" ] && echo "-v $GIT_CONFIG:$CONTAINER_GIT_CONFIG") \
  $([ -f "$AWS_CONFIG" ] && echo "-v $AWS_CONFIG:$CONTAINER_AWS_CONFIG") \
  $([ -f "$HTTP_CERT" ] && echo "-v $HTTP_CERT:$CONTAINER_HTTP_CERT") \
  $([ -f "$HTTP_KEY" ] && echo "-v $HTTP_KEY:$CONTAINER_HTTP_KEY") \
  -e "AWS_ACCESS_KEY_ID=$OPENVIDU_AWS_ACCESS_KEY" \
  -e "AWS_SECRET_ACCESS_KEY=$OPENVIDU_AWS_SECRET_KEY" \
  -e "GITHUB_PRIVATE_RSA_KEY=$CONTAINER_PRIVATE_RSA_KEY" \
  -e "OPENVIDU_PROJECT=$OV_PROJECT" \
  -e "GITHUB_TOKEN=$OPENVIDU_GITHUB_TOKEN" \
  -e "ADM_SCRIPTS=$CONTAINER_ADM_SCRIPTS" \
  -e "OPENVIDU_VERSION=$OV_VERSION" \
  -e "OPENVIDU_PRO_VERSION=$OVP_VERSION" \
  -e "OPENVIDU_CALL_VERSION=$OVC_VERSION" \
  -e "OPENVIDU_REACT_VERSION=$OVR_VERSION" \
  -e "MAVEN_SETTINGS=$CONTAINER_MAVEN_SETTINGS" \
  -e "GPG_PRIVATE_BLOCK=$CONTAINER_GPG_PRIVATE_BLOCK" \
  -e "GNUPG_KEY_ID=$OPENVIDU_GPG_KEY" \
  -e "GPG_PASSKEY=$OPENVIDU_GPG_PASSKEY" \
  -e "MAVEN_STAGE_ID=$MAVEN_STAGE_ID" \
  -e "BUILDS_HOST=$OPENVIDU_BUILDS_HOST" \
  -e "HTTP_CERT=$CONTAINER_HTTP_CERT" \
  -e "HTTP_KEY=$CONTAINER_HTTP_KEY" \
  -e "MODE=$CF_MODE" \
  -e "TYPE=$CF_TYPE" \
  -v "${PWD}:$WORKSPACE" \
  -w $WORKSPACE \
  $CONTAINER_IMAGE \
  /opt/adm-scripts/openvidu_ci_container_entrypoint.sh $BUILD_COMMAND
status=$?

# Change worspace ownership to avoid permission errors caused by docker usage of root
[ -n "$WORKSPACE" ] && sudo chown -R $(whoami) $WORKSPACE

exit $status
  
