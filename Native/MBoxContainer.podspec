
require 'yaml'
yaml = YAML.load_file('../manifest.yml')
name = yaml["NAME"]
name2 = name.sub('MBox', 'mbox').underscore
version = ENV["VERSION"] || yaml["VERSION"]

Pod::Spec.new do |spec|
  spec.name         = "#{name}"
  spec.version      = "#{version}"
  spec.summary      = "MBox Plugin MBoxContainer."
  spec.description  = <<-DESC
    A MBox Plugin MBoxContainer.
                   DESC

  spec.homepage     = "https://github.com/MBoxSpace/#{name2}.git"
  spec.license      = "MIT"
  spec.author       = { `git config user.name`.strip => `git config user.email`.strip }

  spec.source       = { :git => "git@github.com:MBoxSpace/#{name2}.git", :tag => "#{spec.version}" }
  spec.platform     = :osx, '10.15'

  spec.source_files = "#{name}/MBoxContainer/*.{h,m,mm,swift,c,cpp}", "#{name}/MBoxContainer/**/*.{h,m,mm,swift,c,cpp}"

  yaml['DEPENDENCIES'].each do |name|
    spec.dependency name
  end
end
