FROM jenkins /jenkins:lts jdk11
USER root
RUN apt get y update &&
apt get y install build essential wget sudo apt utils
RUN wget qO https://get.docker.com/ | sh
RUN usermod aG docker jenkins
USER jenkins