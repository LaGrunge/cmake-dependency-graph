#!/bin/bash -eux

set -e
#set -o pipefail


sort_graph() {
  PREAMBULE='
  digraph "GG" {
  node [
    fontsize = "12"
  ];'
  echo $PREAMBULE > $2
  cat $1 | grep '"node' | sort -s >> $2
  echo "}" >> $2

}

make_dots() {
  cmake --graphviz=pr_unsorted.dot .
  git checkout master
  cmake --graphviz=master_unsorted.dot .
  sort_graph "pr_unsorted.dot" "pr.dot"
  sort_graph "master_unsorted.dot" "master.dot"
  cp master.dot graph.dot
}


make_png() {
  dot -Tpng graph.dot > graph.png
}


diff_and_generate_graph2colored() {
  diff -u graph.dot pr.dot | gawk '
  {
    if ($0 ~ /+   .*/) {
      if ($0 ~/.* -> .*/) {
        split($0,line,"/");
        print line[1] "[color=green] //" line[3];
      } else {
        split($0, line, ";")
        print line[1] "[color=green];"
      }
    } else if ($0 ~ /-   .*/) {
      if ($0 ~/.* -> .*/) {
        split($0,line,"/");
        print $0
        print "+" substr(line[1],2) "[color=red] //" line[3];
      } else {
        split($0, line, ";")
        print $0
        print "+" substr(line[1],2) "[color=red];"
      }
    } else {
      print $0;
    }
  }' | patch graph.dot
}


diff_and_generate_graph() {
  diff -u graph.dot pr.dot | awk '
  {
    if ($0 ~ /+   .*/) {
      if ($0 ~/.* -> .*/) {
        split($0,line,"/");
        print line[1] "[color=red] //" line[3];
      } else {
        split($0, line, ";")
        print line[1] "[color=red];"
      }
    } else {
      print $0;
    }
  }' | patch graph.dot
}


post_graph() {
  URL="${URI}/repos/${GITHUB_REPOSITORY}/issues/${NUMBER}/comments"
  echo $URL
  IMAGE=`curl --location --request POST "https://api.imgbb.com/1/upload?key=$IMGBB_API_KEY" -F "image=@graph.png" | jq -r .data.url`
  curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" -d "{\"body\":\"![]($IMAGE)\"}" -H "Content-Type: application/json" -X POST $URL
}


check_and_set_vars() {
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
}



post() {
  check_and_set_vars

  # Validate the GitHub token.
  curl -o /dev/null -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" "${URI}/repos/${GITHUB_REPOSITORY}" || { echo "Error: Invalid repo, token or network issue!";  exit 1; }

  # Get the pull request number.
#  NUMBER=$(cat "$GITHUB_EVENT_PATH" | jq --raw-output .pull_request.number)
  NUMBER=`curl ${URI}/repos/${GITHUB_REPOSITORY}/pulls | jq " .[] | select (.head.sha == \"$GITHUB_SHA\") | .number"`
  echo "running $GITHUB_ACTION for PR #${NUMBER}"

  post_graph
}


make_dots
diff_and_generate_graph
make_png
post

