
module MBox
  class Config
    class Repo
      class Container
        include JSONable
        attr_accessor :tool
        attr_accessor :active
      end

      alias_method :mbox_container_json_class_0812, :json_class
      def json_class
        mbox_container_json_class_0812.merge(
          {
            :containers => Container
          })
      end

      attr_accessor :containers

      def activated_containers_for(tool)
        if self.containers.nil?
          # Deactivate All
          return []
        end
        if self.containers.empty?
          # Activate All
          return all_containers_for(tool)
        end
        container = self.containers.find { |c| c.tool.downcase == tool.downcase }
        if container.blank?
          # Deactivate All for Tool
          return []
        end
        if container.active.blank?
          # Activate All for Tool
          return all_containers_for(tool)
        end
        return container.active.map { |container_name|
          Feature::Container.new(container_name, self.name, tool)
        }
      end

      def all_containers_for(tool)
        return self.all_containers.select { |c| c.tool.downcase == tool.downcase }
      end

      def all_containers
        []
      end
    end
  end
end
