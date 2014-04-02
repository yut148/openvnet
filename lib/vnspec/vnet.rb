# -*- coding: utf-8 -*-
module Vnspec
  class Vnet
    class << self
      include SSH
      include Logger
      include Config

      def hosts
        config[:nodes].values.flatten.uniq
      end

      def start(node_name = nil)
        if node_name
          config[:nodes][node_name.to_sym].peach do |ip|
            ssh(ip, "initctl start vnet-#{node_name.to_s}", use_sudo: true)
          end
        else
          %w(vnmgr vna webapi).each do |n|
            start(n)
          end
        end
      end

      def stop(node_name = nil)
        if node_name
          config[:nodes][node_name.to_sym].peach do |ip|
            ssh(ip, "initctl stop vnet-#{node_name.to_s}", use_sudo: true)
          end
        else
          %w(webapi vna vnmgr).each do |n|
            stop(n)
          end
        end
      end

      def restart(node_name = nil)
        stop(node_name)
        start(node_name)
      end

      def update(branch = nil)
        host = config[:use_rsync] ? config[:nodes][:vna][0] : config[:nodes][:vna]
        branch ||= config[:vnet_branch]
        case config[:update_vnet_via].to_sym
        when :rpm
          multi_ssh(hosts,
            "yum clean metadata --disablerepo=* --enablerepo=openvnet*",
            "yum update -y      --disablerepo=* --enablerepo=openvnet*",
            use_sudo: true
          )
        when :git
          multi_ssh(hosts,
            "cd #{config[:vnet_path]}; git fetch --prune origin; git fetch --tags origin; git clean -f -d; git rev-parse #{branch} | xargs git reset --hard; git checkout #{branch};"
          )
        when :rsync
          raise NotImplementedError.new("please update yourself!")
        end
        bundle_install
      end

      def bundle_install
        hosts = case config[:update_vnet_via].to_sym
        when :rpm
          raise NotImplementedError.new("please update gems via rpm.")
        when :git
          self.hosts
        when :rsync
          config[:nodes][:vnmgr]
        end

        %w(vnet vnctl).each do |dir|
          multi_ssh(hosts, "cd #{File.join(config[:vnet_path], dir)}; bundle clean; bundle install --path vendor/bundle;")
        end
      end

      def downgrade
        case config[:update_vnet_via].to_sym
        when :rpm
          multi_ssh(hosts,
            "yum clean metadata --disablerepo=* --enablerepo=openvnet*",
            "yum downgrade -y --disablerepo=* --enablerepo=openvnet* openvnet*",
            use_sudo: true
          )
        when :git, :rsync
          raise NotImplementedError.new("please downgrade yourself!")
        end
      end

      def delete_tunnels(brige_name = "br0")
        multi_ssh(
          config[:nodes][:vna],
          "ovs-vsctl list-ports #{brige_name} | egrep '^t-' | xargs -n1 ovs-vsctl del-port #{brige_name}",
          exit_on_error: false,
          use_sudo: true
        )
      end

      def add_normal_flow(brige_name = "br0")
        multi_ssh(
          config[:nodes][:vna],
          "ovs-ofctl add-flow #{brige_name} priority=100,actions=NORMAL",
          use_sudo: true
        )
      end

      def reset_db
        multi_ssh(config[:nodes][:vnmgr], "cd #{config[:vnet_path]}/vnet; bundle exec rake db:reset")
      end

      def dump_flows(vna_index = nil)
        return unless config[:dump_flows]
        config[:nodes][:vna].each_with_index do |ip, i|
          next if vna_index && vna_index.to_i != i + 1
          logger.info "#" * 50
          logger.info "# dump_flows: vna#{i + 1}"
          logger.info "#" * 50
          output = ssh(ip, "cd #{config[:vnet_path]}/vnet; bundle exec bin/vnflows-monitor", debug: false)
          logger.info output[:stdout]
          logger.info
        end
      end

      def install_package(name)
        run_command_on_vna_nodes("yum install -y #{name}", use_sudo: true)
      end

      def install_proxy_server
        install_package("squid")
        run_command_on_vna_nodes("service squid start", use_sudo: true)
        run_command_on_vna_nodes("chkconfig squid on", use_sudo: true)
      end

      def run_command_on_vna_nodes(*args)
        multi_ssh(config[:nodes][:vna], *args)
      end
      alias_method :run_command, :run_command_on_vna_nodes

      def wait_for_webapi(retry_count = 20)
        health_check_url = "http://#{config[:webapi][:host]}:#{config[:webapi][:port]}/api/datapaths"
        retry_count.times do
          `curl -fsSkL #{health_check_url}`
          return true if $? == 0
          sleep 1
        end
        return false
      end
    end
  end
end
