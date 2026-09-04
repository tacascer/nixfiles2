if [[ ${1:-} != "get" ]]; then
  printf 'usage: bazel-buildbuddy-credential-helper get\n' >&2
  exit 1
fi

# Consume Bazel's request before returning credentials on stdout.
IFS= read -r _request || [[ -n $_request ]]

op read 'op://Personal/BuildBuddy_API/credential' \
  | jq -Rs '{headers: {"x-buildbuddy-api-key": [sub("\\n$"; "")]}}'
