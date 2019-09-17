FROM ubuntu:18.04 as base

COPY plot_cmake_dependency.sh /plot_cmake_dependency.sh

RUN apt-get update && apt-get --assume-yes install jq curl diffutils cmake graphviz g++

ENTRYPOINT ["/plot_cmake_dependency.sh"]
