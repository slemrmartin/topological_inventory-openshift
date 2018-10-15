module Openshift
  class Parser
    module Pod
      def parse_pods(pods)
        pods.each { |pod| parse_pod(pod) }
      end

      def parse_pod(pod)
        container_group =  TopologicalInventory::IngressApi::Client::ContainerGroup.new(
          parse_base_item(pod).merge(
            :ipaddress      => pod.status&.podIP,
            :container_node => lazy_find_node(pod.spec&.nodeName),
          )
        )

        collections[:container_groups] ||= TopologicalInventory::IngressApi::Client::InventoryCollection.new(:name => :container_groups)
        collections[:container_groups].data << container_group

        container_group
      end

      def parse_pod_notice(notice)
        container_group = parse_pod(notice.object)
        archive_entity(container_group, notice.object) if notice.type == "DELETED"
      end
    end
  end
end