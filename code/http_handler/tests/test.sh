#!/bin/bash
set -e

url=https://dev.${DOMAIN_NAME}/v1/reg
# url=https://test.${DOMAIN_NAME}/v1/reg
# url=localhost:8080/v1/reg

for i in {1..300}
do
  random=$(cat /dev/urandom | base64 | tr -dc '0-9a-zA-Z' | head -c15 | sed 's/$/\n/')
  cat data.json | jq ".wmukid = \"${random}\"" > payload.json
  curl -X POST -H "Content-type: application/json" $url -d "@payload.json"

  # random=$(cat /dev/urandom | base64 | tr -dc '0-9a-zA-Z' | head -c15 | sed 's/$/\n/')
  # cat datanodomain.json | jq ".wmukid = \"${random}\"" > payload.json
  # curl -X POST -H "Content-type: application/json" $url -d "@payload.json"

  # random=$(cat /dev/urandom | base64 | tr -dc '0-9a-zA-Z' | head -c15 | sed 's/$/\n/')
  # cat databr.json | jq ".wmukid = \"${random}\"" > payload.json
  # curl -X POST -H "Content-type: application/json" $url -d "@payload.json"

  # random=$(cat /dev/urandom | base64 | tr -dc '0-9a-zA-Z' | head -c15 | sed 's/$/\n/')
  # cat datapc.json | jq ".wmukid = \"${random}\"" > payload.json
  # curl -X POST -H "Content-type: application/json" $url -d "@payload.json"
done
