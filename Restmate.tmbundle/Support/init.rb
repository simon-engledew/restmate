require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/restmate"
configuration = YAML.load(File.open("#{ENV['TM_BUNDLE_SUPPORT']}/config.yml"))
$restmate = Restmate.new(configuration['model'], configuration['url'], *configuration['whitelist'])
