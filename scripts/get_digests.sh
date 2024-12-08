#!/usr/bin/env sh
set -e

# Retrieve digests of CloudNativePG PostgreSQL images
#
# Environment variables:
#   FILTER_TAGS (optional):
#     A string containing the regex pattern to filter tags. If not set, all tags
#     will be included.
#
#   COMPARE_REPOSITORY (optional):
#     The name of the repository used for comparison. If set, the script will
#     check if images in this repository are based on images from the source
#     repository.
#
#   COMPARE_TAG_SUFFIX (optional):
#     An optional suffix to append to corresponding tags in the comparison
#     repository.
#
# Output files:
#   tags.json:
#     An object of tags, where each tag includes inspection data and a flag
#     indicating whether the corresponding image in the comparison repository is
#     based on the image with that tag.
#
#   digests.json:
#     A list of digests, each with its associated tags.

repository=docker://ghcr.io/cloudnative-pg/postgresql
default_filter_tags="^1[2-7][\w]*(?:\.\d+)?(?:-(?:bullseye|bookworm))?$"

# Retrieve all tags from the repository that match the provided filter
tags_file=tags.json
filter_tags=${FILTER_TAGS:-${default_filter_tags}}
tags_json=$(
  skopeo list-tags "${repository}" |
    jq --arg filter_tags "${filter_tags}" '
      .Tags | map(select(test($filter_tags))) | map({(.): null}) | add'
)
printf "%s\n" "${tags_json}" >"${tags_file}"
tags_length=$(jq 'length' "${tags_file}")
printf "Retrieved %d tags from the repository with filter '%s'\n" \
  "${tags_length}" "${filter_tags}"

# Iterate through each tag and process it
jq -r 'keys[]' "${tags_file}" | while read -r tag; do
  printf "Processing tag: '%s'\n" "${tag}"

  # Perform an inspection of the tag
  inspect_json=$(skopeo inspect -n "${repository}:${tag}")
  printf -- "- Inspection data successfully loaded\n"

  # If a comparison repository is defined, check whether the image in the
  # comparison repository with the same tag (optionally including a suffix) is
  # based on the image from the current processing tag
  c_uptodate_json=false
  if [ -n "${COMPARE_REPOSITORY}" ]; then
    printf -- "- Comparing with image from comparison repository\n"
    c_tag="${tag}${COMPARE_TAG_SUFFIX:+-${COMPARE_TAG_SUFFIX}}"
    c_image="docker://${COMPARE_REPOSITORY}:${c_tag}"
    c_inspect_json=$(skopeo inspect -n "${c_image}" 2>/dev/null || printf "")
    if [ -n "${c_inspect_json}" ]; then
      # `c_uptodate_json` will be true if the comparison image is based on the
      # image from the current processing tag (i.e., if the digest of the last
      # layer of the processing tag's image is found in the comparison image)
      c_uptodate_json=$(
        printf "%s" "${c_inspect_json}" |
          jq --argjson inspect "${inspect_json}" '
            .Layers | any(. == $inspect.Layers[-1])'
      )
      printf -- "--- Image up-to-date status: %s\n" "${c_uptodate_json}"
    else
      printf -- "--- Image not found\n"
    fi
  fi

  # Add inspection data and comparison status to the tag object
  tags_json=$(
    jq --arg tag "${tag}" --argjson c_uptodate "${c_uptodate_json}" \
      --argjson inspect "${inspect_json}" '
        .[$tag] = {inspect: $inspect, c_uptodate: $c_uptodate}' "${tags_file}"
  )
  printf "%s\n" "${tags_json}" >"${tags_file}"
done
printf "File '%s' has been created" "${tags_file}"

# Transform the tags into a list of digests and their associated tags, excluding
# digests where all associated tags are marked as up-to-date
digests_file=digests.json
digests_json=$(
  jq '
    to_entries | group_by(.value.inspect.Digest) | map({
      digest: .[0].value.inspect.Digest,
      tags: map(.key),
      c_uptodate: all(.value.c_uptodate)
    }) | map(select(.c_uptodate == false) | del(.c_uptodate))
    | sort_by(.tags[0])' "${tags_file}"
)
printf "%s\n" "${digests_json}" >"${digests_file}"
digests_length=$(jq 'length' "${digests_file}")
printf "Tags transformed to %d unique digests" "${digests_length}"
printf "%s\n" "File '%s' has been created" "${digests_file}"
