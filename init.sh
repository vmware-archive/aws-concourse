if [ ! -f ci/pcfaws_terraform_params.yml ]; then
  echo "Creating ci/pcfaws_terraform_params.yml"
  cp ci/sample/pcfaws_terraform_params.yml ci/pcfaws_terraform_params.yml
fi
