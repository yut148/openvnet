#!/bin/bash

(
    $starting_group "Install sclo ruby"
    run_cmd "rpm -q --quiet rh-ruby23"
    $skip_group_if_unessecarry
    install_package "centos-release-scl"
    install_package "yum-utils"
    (
        $starting_step "Enable RHSCL"
        run_cmd "which yum-config-manager > /dev/null"
        $skip_step_if_already_done
        run_cmd "yum-config-manager --enable rhel-server-rhscl-6-rpms"
    ) ; prev_cmd_failed
    install_package "rh-ruby23"
) ; prev_cmd_failed
