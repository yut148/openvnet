(
    $starting_step "Set up OpenVNet third party repo for openvswitch"
    [[ -f ${TMP_ROOT}/etc/yum.repos.d/openvnet-third-party.repo ]]
    $skip_step_if_already_done; set -xe
    run_cmd "cat > /etc/yum.repos.d/openvnet-third-party.repo <<EOS
[openvnet-third-party]
name=OpenVNet - 3d party
failovermethod=priority
baseurl=https://ci.openvnet.org/repos/packages/rhel/7/third_party/current/
enabled=1
gpgcheck=0
EOS"
) ; prev_cmd_failed

(
    $starting_step "Install Open vSwitch"
    run_cmd "rpm -qa | grep -wq openvswitch"
    $skip_step_if_already_done ; set -xe
    run_cmd "yum install -y openvswitch-2.4.1"
) ; prev_cmd_failed
