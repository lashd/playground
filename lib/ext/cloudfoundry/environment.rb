module CloudFoundry
  class Environment
    class << self
      def root_domain
        CloudFoundry::Environment.first_url[/\w+\.(.*)/,1]
      end
    end
  end
end
