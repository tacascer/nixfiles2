#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
test_dir=$(mktemp -d)
trap 'status=$?; rm -rf "$test_dir"; exit "$status"' EXIT

real_jq=$(command -v jq)
real_bash=$(command -v bash)

cat >"$test_dir/op" <<EOF
#!$real_bash
set -euo pipefail
if [[ -n \$(cat) ]]; then
  printf 'credential helper did not consume its request\n' >&2
  exit 1
fi
printf '%s\n' "\$*" >"\$OP_ARGS_FILE"
printf '%s\n' 'test-api-key'
EOF
chmod +x "$test_dir/op"

cat >"$test_dir/jq" <<EOF
#!$real_bash
exec "$real_jq" "\$@"
EOF
chmod +x "$test_dir/jq"

export OP_ARGS_FILE="$test_dir/op-args"
response=$(
  printf '%s' '{"uri":"grpcs://remote.buildbuddy.io"}' \
    | PATH="$test_dir:$PATH" bash -euo pipefail \
      "$repo_root/modules/home/bazel-buildbuddy-credential-helper.sh" get
)

if ! jq -e '. == {"headers":{"x-buildbuddy-api-key":["test-api-key"]}}' \
  <<<"$response" >/dev/null; then
  printf 'unexpected helper response: %s\n' "$response" >&2
  exit 1
fi

if [[ $(<"$OP_ARGS_FILE") != 'read op://Personal/BuildBuddy_API/credential' ]]; then
  printf 'unexpected op arguments: %s\n' "$(<"$OP_ARGS_FILE")" >&2
  exit 1
fi
