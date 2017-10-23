FROM ubuntu:16.04
LABEL author="Sergey Stolyarov"

ENV GITLAB_CI_MULTI_RUNNER_VERSION=9.5.0 \
    GITLAB_CI_MULTI_RUNNER_USER=gitlab_ci_multi_runner \
    GITLAB_CI_MULTI_RUNNER_HOME_DIR="/home/gitlab_ci_multi_runner"
ENV GITLAB_CI_MULTI_RUNNER_DATA_DIR="${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/data"

ENV KUBECTL_VERSION=1.7.1

RUN apt-get update \
 && apt-get upgrade -y \ 
 && apt-get install wget sudo -y 
 
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E1DD270288B4E6030699E45FA1715D88E1DF1F24 \
 && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      git-core openssh-client curl libapparmor1 \
 && wget -O /usr/local/bin/gitlab-ci-multi-runner \
      https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/v${GITLAB_CI_MULTI_RUNNER_VERSION}/binaries/gitlab-ci-multi-runner-linux-amd64 \
 && chmod 0755 /usr/local/bin/gitlab-ci-multi-runner \
 && adduser --disabled-login --gecos 'GitLab CI Runner' ${GITLAB_CI_MULTI_RUNNER_USER} \
 && sudo -HEu ${GITLAB_CI_MULTI_RUNNER_USER} ln -sf ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh ${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/.ssh 


RUN apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \ 
    jq \
    software-properties-common

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

RUN apt-get update

RUN apt-get install -y docker-ce

COPY rollout-complete.sh /usr/local/bin/rollout-complete
COPY pipeline-track.sh /usr/local/bin/pipeline-track

RUN chmod +x /usr/local/bin/rollout-complete \
    && chmod +x /usr/local/bin/pipeline-track

RUN apt-get clean

RUN usermod -G docker -a $GITLAB_CI_MULTI_RUNNER_USER

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod 755 /usr/local/bin/entrypoint
COPY override-entrypoint.sh /usr/local/bin/override-entrypoint
RUN chmod 755 /usr/local/bin/override-entrypoint

RUN export PATH=/usr/local/bin:$PATH

VOLUME ["${GITLAB_CI_MULTI_RUNNER_DATA_DIR}"]
WORKDIR "${GITLAB_CI_MULTI_RUNNER_HOME_DIR}"
ENTRYPOINT ["entrypoint"]
