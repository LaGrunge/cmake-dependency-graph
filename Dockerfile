# Container image that runs your code
FROM ubuntu:18.04 as base

COPY plot_cmake_dependency.sh /plot_cmake_dependency.sh


RUN sudo apt install jq curl diffutils cmake graphviz


# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/plot_cmake_dependency.sh"]
