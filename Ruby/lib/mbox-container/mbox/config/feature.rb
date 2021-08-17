module MBox
  class Config
    class Feature
      class Container
        include JSONable
        attr_accessor :tool
        attr_accessor :repo_name
        attr_accessor :name
      end

      attr_accessor :current_containers
      alias_method :mbox_json_class_0812, :json_class
      def json_class
        mbox_json_class_0812.merge(
          {
            :current_containers => Container
          })
      end

      def current_containers_for(tool)
        self.current_containers.select { |container| container.tool.downcase == tool.downcase }
      end

      def current_container_repos_for(tool)
        container_names = if env = ENV["MBOX_#{tool.upcase}_CONTAINER_REPOS"]
          JSON.parse(env)
        else
          self.current_containers_for(tool).map(&:repo_name)
        end
        self.repos.select do |repo|
          next unless repo.name
          container_names.include?(repo.name)
        end
      end

    end
  end
end

