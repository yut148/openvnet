FROM centos:6

MAINTAINER "Axsh Co. LTD"

VOLUME /data

RUN ["yum", "install", "-y", "epel-release"]
RUN ["yum", "install", "-y", "rsync", "bridge-utils", "qemu-kvm", "qemu-system-x86", "parted", "sudo", "openssh-clients", "ncat", "git", "which", "file"]
RUN mkdir /var/tmp/openvnet

# This key is required by rvm
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s stable
ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN rvm install 2.3.0

WORKDIR /var/tmp/openvnet

ARG BRANCH
ARG BUILD_OS
ARG RELEASE_SUFFIX
ARG REBUILD
ARG BUILD_URL
ARG ISO8601_TIMESTAMP
ARG LONG_SHA

# Set the ARGs to ENV because otherwise they're not visible to the run_tests.sh script
ENV BRANCH=${BRANCH:-develop} RELEASE_SUFFIX=${RELEASE_SUFFIX:-current} REBUILD=${REBUILD:-false}

LABEL "jp.axsh.vendor"="Axsh Co. LTD"  \
      "jp.axsh.project"="OpenVNet" \
      "jp.axsh.task"="integration test" \
      "jp.axsh.branch"="$BRANCH" \
      "jp.axsh.release_suffix"="$RELEASE_SUFFIX" \
      "jp.axsh.buildtime"="$ISO8601_TIMESTAMP" \
      "jp.axsh.build_url"="$BUILD_URL" \
      "jp.axsh.git_commit"="$LONG_SHA"

COPY [".", "/var/tmp/openvnet"]

ENTRYPOINT ["./ci/ci.el6/integration_test/run_tests.sh"]
