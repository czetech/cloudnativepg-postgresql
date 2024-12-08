#!/usr/bin/env sh
set -e

# List variants
#
# Environment variables:
#   FILTER_VARIANTS (optional):
#     A JSON list of variant names to filter. If set, the list of variants will
#     be filtered to include only the variants specified in the list.
#
# Output files:
#   variants.json:
#     A list of variants, each containing its name and configuration.

# List directories
directories_json=$(
  find variants -maxdepth 1 -mindepth 1 -type d -printf %f/ | jq -s -R '
    split("/")[:-1]'
)

# If FILTER_VARIANTS is defined, filter the list based on the provided variants
if [ -n "${FILTER_VARIANTS}" ]; then
  directories_json=$(
    printf "%s" "${directories_json}" |
      jq --argjson changed_variants "${FILTER_VARIANTS}" '
        [.[] | select(. as $variant | $changed_variants | index($variant))]'
  )
  filter_variants_log=$(printf "%s" "${FILTER_VARIANTS}" | jq -c)
  printf "Included only variants from %s\n" "${filter_variants_log}"
fi

# Create a list of variants and their associated configurations
variants_file=variants.json
jq -n '[]' >"${variants_file}"
printf "%s" "${directories_json}" | jq '.[]' | while read -r directory_json; do
  directory=$(printf "%s" "${directory_json}" | jq -r)
  config_json=$(yq --output-format json '.' "variants/${directory}/config.yaml")
  variants_json=$(
    jq --argjson directory "${directory_json}" \
      --argjson config "${config_json}" '
        . + [{name: $directory, config: $config}]' "${variants_file}"
  )
  printf "%s\n" "${variants_json}" >"${variants_file}"
done
printf "File '%s' has been created\n" "${variants_file}"
