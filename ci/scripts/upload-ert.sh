#!/bin/bash
set -e

sudo cp tool-om/om-linux /usr/local/bin
sudo chmod 755 /usr/local/bin/om-linux

echo "=============================================================================================="
echo " Uploading ERT tile to @ https://opsman.$ERT_DOMAIN ..."
echo "=============================================================================================="

##Upload ert Tile

om-linux -t https://opsman.$ERT_DOMAIN -k \
       -u "$OPSMAN_USER" \
       -p "$OPSMAN_PASSWORD" \
      upload-product \
      --product pivnet-elastic-runtime/cf*.pivotal

##Get Uploaded Tile --product-version

opsman_host="opsman.$ERT_DOMAIN"
uaac target https://${opsman_host}/uaa --skip-ssl-validation > /dev/null 2>&1
uaac token owner get opsman ${OPSMAN_USER} -s "" -p ${OPSMAN_PASSWORD} > /dev/null 2>&1
export opsman_bearer_token=$(uaac context | grep access_token | awk -F ":" '{print$2}' | tr -d ' ')

cf_product_version=$(curl -s -k -X GET -H "Content-Type: application/json" -H "Authorization: Bearer ${opsman_bearer_token}" "https://${opsman_host}/api/v0/available_products" | jq ' .[] | select ( .name == "cf") | .product_version ' | tr -d '"')

##Move 'available product to 'staged'

om-linux -t https://opsman.$ERT_DOMAIN -k \
       -u "$OPSMAN_USER" \
       -p "$OPSMAN_PASSWORD" \
      stage-product \
      --product-name cf --product-version ${cf_product_version}
