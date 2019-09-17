FROM ubuntu:18.04 as base

COPY plot_cmake_dependency.sh /plot_cmake_dependency.sh

RUN apt-get update && apt-get --assume-yes install jq gawk curl diffutils git cmake graphviz g++ libboost-all-dev

ENTRYPOINT ["/plot_cmake_dependency.sh"]
