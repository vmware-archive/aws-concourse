#!/bin/bash -exu

function main() {
  local cwd="$1"

  local opsman_dns
  opsman_dns="opsman.$ERT_DOMAIN"

  local bosh_config_flags

  local iaas_configuration
  iaas_configuration="$(jq -r '.iaas_configuration' bosh_configuration/config.json)"
  if [[ "${iaas_configuration}" != "null" ]]; then
    bosh_config_flags+=(--iaas-configuration "${iaas_configuration}")
  fi

  local director_configuration
  director_configuration="$(jq -r '.director_configuration' bosh_configuration/config.json)"
  if [[ "${director_configuration}" != "null" ]]; then
    bosh_config_flags+=(--director-configuration "${director_configuration}")
  fi

  local az_configuration
  az_configuration="$(jq -r '.az_configuration' bosh_configuration/config.json)"
  if [[ "${az_configuration}" != "null" ]]; then
    bosh_config_flags+=(--az-configuration "${az_configuration}")
  fi

  local networks_configuration
  networks_configuration="$(jq -r '.networks_configuration' bosh_configuration/config.json)"
  if [[ "${networks_configuration}" != "null" ]]; then
    bosh_config_flags+=(--networks-configuration "${networks_configuration}")
  fi

  local network_assignment
  network_assignment="$(jq -r '.network_assignment' bosh_configuration/config.json)"
  if [[ "${network_assignment}" != "null" ]]; then
    bosh_config_flags+=(--network-assignment "${network_assignment}")
  fi

  om --target "https://${opsman_dns}" \
     --skip-ssl-validation \
     --username "${OPSMAN_USERNAME}" \
     --password "${OPSMAN_PASSWORD}" \
     configure-bosh \
     "${bosh_config_flags[@]}"
}

main "${PWD}"
