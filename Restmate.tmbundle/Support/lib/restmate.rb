require 'rubygems'
require 'activeresource'
require 'activesupport'

require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/bundle.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/internet_keychain.rb"

require "#{ENV['TM_SUPPORT_PATH']}/lib/escape.rb"
require "#{ENV['TM_SUPPORT_PATH']}/lib/progress.rb"

class Restmate

  def initialize(model, site, *whitelist)
    Object.const_set(model, Class.new(ActiveResource::Base))
    
    @class = model.constantize
    @class.site = site
    @whitelist = whitelist.map(&:to_s)

    at_exit{ finalize }
  end
  
  def index
  end
  
  def show
    contacting_server "Fetch #{@class}" do
      if model = select(@class.find(:all))
        Bundle.exit(:create_document, write(model.attributes))
      end 
      Bundle.exit(:discard)
    end
  end
  
  def finalize
    
  end
  
  def build                                        
    contacting_server "Building #{@class}" do
      attributes = @class.get(:new)
      attributes.delete :id.to_s
      Bundle.exit(:create_document, write(attributes))
    end
    Bundle.exit(:discard)
  end
  
  def create
    contacting_server "Creating #{@class}" do
      model = read
      Bundle.exit(:show_tooltip, "#{@class} already created") if model.id
      model.save
    end
    Bundle.exit(:show_tooltip, "#{@class} created")
  end
  
  def update
    contacting_server "Updating #{@class}" do
      model = read
      model.save
    end
    Bundle.exit(:show_tooltip, "#{@class} updated")
  end
  
  def destroy
    contacing_server "Destroying #{@class}" do
      if model = select(@class.find(:all))
        model.destroy
      end
    end
    Bundle.exit(:show_tooltip, "#{@class} destroyed")
  end

protected

  def whitelist(attributes)
    attributes.delete_if{|k,v|not @whitelist.include?(k)}
  end
  
  def write(attributes)
    whitelist(attributes).to_yaml
  end
  
  def read
    @class.new(whitelist(YAML.load(STDIN)))
  end

  def select(models)
    index = Bundle.dropdown(
      :title => %('Fetch #{@class}'),
      :text => %('Select a #{@class}'),
      :button1 => 'Load',
      :button2 => 'Cancel',
      :items => models.map{|m|e_sh m.title}.join(' ')
    )
    return index ? models[Integer(index)] : nil
  end
  
  def contacting_server(title)
    TextMate.call_with_progress(:title => title, :message => "Contacting Server"){return yield}
  end

end
