#!/bin/bash
set -e

url=https://dev.${DOMAIN_NAME}/v1/reg
# url=https://test.${DOMAIN_NAME}/v1/reg
# url=localhost:8080/v1/reg

# not post
for i in {1..100}
do
  random=$(cat /dev/urandom | base64 | tr -dc '0-9a-zA-Z' | head -c15 | sed 's/$/\n/')
  cat data.json | jq ".wmukid = \"${random}\"" > payload.json
  curl -X GET -H "Content-type: application/json" $url -d "@payload.json"
done

# missing content type
for i in {1..100}
do
  random=$(cat /dev/urandom | base64 | tr -dc '0-9a-zA-Z' | head -c15 | sed 's/$/\n/')
  cat data.json | jq ".wmukid = \"${random}\"" > payload.json
  curl -X POST $url -d "@payload.json"
done

# incorrect media type
for i in {1..100}
do
  random=$(cat /dev/urandom | base64 | tr -dc '0-9a-zA-Z' | head -c15 | sed 's/$/\n/')
  cat data.json | jq ".wmukid = \"${random}\"" > payload.json
  curl -X POST -H "Content-type: application/text" $url -d "@payload.json"
done

# user agent is google bot
for i in {1..100}
do
  random=$(cat /dev/urandom | base64 | tr -dc '0-9a-zA-Z' | head -c15 | sed 's/$/\n/')
  cat data.json | jq ".wmukid = \"${random}\"" > payload.json
  curl -X POST -H "Content-type: application/json" -H "User-Agent:test;Googlebot;yes" $url -d "@payload.json"
done

# user agent is ad bot
for i in {1..100}
do
  random=$(cat /dev/urandom | base64 | tr -dc '0-9a-zA-Z' | head -c15 | sed 's/$/\n/')
  cat data.json | jq ".wmukid = \"${random}\"" > payload.json
  curl -X POST -H "Content-type: application/json"  -H "User-Agent:test;AdsBot-Googlebot;yes" $url -d "@payload.json"
done

# content size too small
for i in {1..100}
do
  curl -X POST -H "Content-type: application/json" $url -d "@nopayload.json"
done

# content size too large
for i in {1..100}
do
  curl -X POST -H "Content-type: application/json" $url -d "@bigpayload.json"
done

# unable to parse payload
for i in {1..100}
do
  curl -X POST -H "Content-type: application/json" $url -d "@badpayload.json"
done

# missing wmukid
for i in {1..100}
do
  curl -X POST -H "Content-type: application/json" $url -d "@missingwmukidpayload.json"
done

