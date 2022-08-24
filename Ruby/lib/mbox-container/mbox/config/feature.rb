module MBox
  class Config
    class Feature

      class Container
        attr_accessor :tool
        attr_accessor :repo_name
        attr_accessor :name
        def initialize(name, repo_name, tool)
          self.name = name
          self.repo_name = repo_name
          self.tool = tool
        end
      end

      def all_containers
        @all_containers ||= begin
          self.repos.flat_map { |repo| repo.all_containers }
        end
      end

      def current_containers_for(tool)
        self.repos.flat_map { |repo|
          repo.activated_containers_for(tool)
        }
      end

      def current_container_repos_for(tool)
        repo_names = if env = ENV["MBOX_#{tool.upcase}_CURRENT_CONTAINER_REPOS"]
          env.split(",")
        else
          self.current_containers_for(tool).map(&:repo_name)
        end
        self.repos.select do |repo|
          next unless repo.name
          repo_names.include?(repo.name)
        end
      end

    end
  end
end

