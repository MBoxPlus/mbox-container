if ENV["MBox"] && Gem::Version.new(ENV["MBox"]) >= Gem::Version.new("2.0")
  require "mbox-container"
end
