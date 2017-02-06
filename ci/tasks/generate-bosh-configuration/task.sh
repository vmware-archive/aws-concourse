#!/bin/bash -exu

function main() {
  local cwd="$1"

  local env_name
  env_name="$(cat "${cwd}/terraform_output/name")"

  export GOPATH="${cwd}/go"
  pushd "${cwd}/go/src/github.com/c0-ops/aws-concourse/ci/tasks/generate-bosh-configuration/" > /dev/null
    go run main.go \
      --provider-configuration "$(cat "${cwd}/terraform_output/metadata")" \
      --env-name "${env_name}" > "${cwd}/bosh_configuration/config.json"
  popd > /dev/null
}

main "${PWD}"
