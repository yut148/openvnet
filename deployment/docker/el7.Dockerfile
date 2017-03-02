FROM centos:7

WORKDIR /var/tmp/openvnet

ARG SCL_RUBY

ADD deployment/docker/fastestmirror.conf /etc/yum/pluginconf.d/

RUN ["yum", "install", "-y", "epel-release", "centos-release-scl"]
RUN ["yum", "install", "-y", "createrepo", "rpmdevtools", "rpm-build", "yum-utils", "rsync", "sudo"]
RUN ["yum", "install", "-y", "zeromq3-devel", "yum-utils", "make", "gcc", "gcc-c++", "git", "mariadb-devel", "sqlite-devel", "mariadb", "mariadb-server"]
RUN yum install -y ${SCL_RUBY}-build && mysql_install_db && chown mysql:mysql -R /var/lib/mysql

ADD deployment/docker/yum.repo/dev.repo /etc/yum.repos.d/
# Only enables "openvnet-third-party" repo.
RUN yum-config-manager --disable openvnet

ARG BRANCH
ARG RELEASE_SUFFIX
ARG BUILD_URL
ARG ISO8601_TIMESTAMP
ARG LONG_SHA

LABEL "jp.axsh.vendor"="Axsh Co. LTD"  \
      "jp.axsh.project"="OpenVNet" \
      "jp.axsh.task"="rspec/rpm build" \
      "jp.axsh.branch"="$BRANCH" \
      "jp.axsh.release_suffix"="$RELEASE_SUFFIX" \
      "jp.axsh.buildtime"="$ISO8601_TIMESTAMP" \
      "jp.axsh.build_url"="$BUILD_URL" \
      "jp.axsh.git_commit"="$LONG_SHA"

VOLUME /cache
VOLUME /repos

COPY [".", "/var/tmp/openvnet"]
ENTRYPOINT ["deployment/packagebuild/build_packages_vnet.sh"]

