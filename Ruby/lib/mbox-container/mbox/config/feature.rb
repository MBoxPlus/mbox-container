module MBox
  class Config
    class Feature

      def container_repos
        container_names = JSON.parse(ENV['MBOX_COCOAPODS_CONTAINER_REPOS']) || []
        repos.select do |repo|
          next unless repo.name
          container_names.include?(repo.name)
        end
      end

      def container_repo_with_name(name, raise_error: true)
        repo = container_repos.find {|rp| rp.name == name}
        if raise_error && (repo.nil? || !repo.path.exist?)
          raise ::Pod::Informative, "Could not find container repo `#{name}`"
        end
        repo
      end

      def current_container_repos(raise_error: true)
        current_container_names.map do |name|
          container_repo_with_name(name, raise_error:raise_error)
        end.compact
      end

      # 当前选择的容器仓库
      def current_container_names
        @current_container_names ||= begin
          json = ENV['MBOX_COCOAPODS_CURRENT_CONTAINERS']
          return [] if json.nil?
          JSON.parse(json) || []
        rescue Exception => e
          []
        end
      end

      def current_container_hash
        # TODO
      end

    end
  end
end

