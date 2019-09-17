#!/bin/sh -eux

set -e
set -o pipefail

GITHUB_REPOSITORY="LaGrunge/omim_shallow"
GITHUB_TOKEN="85b1f47ee99e28406849145de2d9443960ac6fa8"

if [[ -z "$GITHUB_TOKEN" ]]; then
	echo "Set the GITHUB_TOKEN env variable."
	exit 1
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
	echo "Set the GITHUB_REPOSITORY env variable."
	exit 1
fi

URI=https://api.github.com
API_VERSION=v3

API_HEADER="Accept: application/vnd.github.${API_VERSION}+json; application/vnd.github.antiope-preview+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

post_graph() {
	HASH=`git describe --match="" --always --abbrev=40 --dirty`
	URL="${URI}/repos/${GITHUB_REPOSITORY}/issues/1/comments"
	echo $URL
	curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" -d '{"body":"$HASH"}' -H "Content-Type: application/json" -X POST $URL
}

main() {
	# Validate the GitHub token.
	curl -o /dev/null -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" "${URI}/repos/${GITHUB_REPOSITORY}" || { echo "Error: Invalid repo, token or network issue!";  exit 1; }

	# Get the pull request number.
#	NUMBER=$(jq --raw-output .number "$GITHUB_EVENT_PATH")

#	echo "running $GITHUB_ACTION for PR #${NUMBER}"
        post_graph


}

main


#mkdir .graphfile
#cd graphfile
#cmake --graphviz=graph.dot ..
#dot -Tpng graph.dot > graph.png
