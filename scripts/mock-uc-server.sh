#!/usr/bin/env bash

set -e

cd "$(dirname "$0")/.."

if [[ -n "$1" && "$1" != '--'* ]]; then
  URL="$1"
  shift
else
  URL="$(grep 'openapi_spec_url' .mock-uc-server-stats.yml | cut -d' ' -f2)"
fi

# Check if the URL is empty
if [ -z "$URL" ]; then
  echo "Error: No OpenAPI spec path/url provided or found in ..mock-uc-server-stats.yml"
  exit 1
fi

echo "==> Starting mock server with URL ${URL}"

# Run prism mock on the given spec
if [ "$1" == "--daemon" ]; then
  npm exec --package=@stoplight/prism-cli@~5.8 -- prism mock "$URL" &> .prism.log &

  # Wait for server to come online
  echo -n "Waiting for server"
  while ! grep -q "✖  fatal\|Prism is listening" ".prism.log" ; do
    echo -n "."
    sleep 0.1
  done

  if grep -q "✖  fatal" ".prism.log"; then
    cat .prism.log
    exit 1
  fi

  echo
else
  npm exec  --package=@stoplight/prism-cli@~5.8 -- prism mock "$URL" -p 4010
fi
