#!/usr/bin/env bash

_get_browserstack_identifier() {
  local bs_local_identifier
  bs_local_identifier=gitlab_${CI_PIPELINE_ID}_${CI_JOB_NAME}_$(date +%Y-%m-%d_%H-%M-%S)
  echo "${bs_local_identifier}"
}

export_browserstack_identifier() {
  BS_LOCAL_IDENTIFIER=$(_get_browserstack_identifier)
  export BS_LOCAL_IDENTIFIER
}

install_browserstack() {
  set -eu -o pipefail -E
  curl -O --silent https://www.browserstack.com/browserstack-local/BrowserStackLocal-darwin-x64.zip
  unzip BrowserStackLocal-darwin-x64.zip
}

run_browserstack() {
  set -eu -o pipefail -E
  ./BrowserStackLocal --key "${BROWSERSTACK_ACCESS_KEY}" --force-local --local-identifier "${BS_LOCAL_IDENTIFIER}" --daemon start
}

install_browserstack
export_browserstack_identifier
run_browserstack
