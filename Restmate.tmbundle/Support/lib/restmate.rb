require 'rubygems'
require 'activeresource'
require 'activesupport'

require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/bundle.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/internet_keychain.rb"

require "#{ENV['TM_SUPPORT_PATH']}/lib/escape.rb"
require "#{ENV['TM_SUPPORT_PATH']}/lib/progress.rb"

class Restmate
  
  def initialize(model, site)
    Object.const_set(model, Class.new(ActiveResource::Base))
    
    @class = model.constantize
    @class.site = site
    
    at_exit{ finalize }
  end
  
  def index
    
  end
  
  def show
    contacting_server "Fetch #{@class}" do
      if model = select(@class.find(:all))
        Bundle.exit(:create_document, model.attributes.to_yaml)
      end 
      Bundle.exit(:discard)
    end
  end
  
  def finalize
    
  end
  
  def create
    contacting_server "Creating #{@class}" do
      model = @class.new(YAML.load(STDIN))
      model.id = nil
      model.save
    end
    Bundle.exit(:show_tooltip, "#{@class} created")
  end
  
  def update
    contacting_server "Updating #{@class}" do
      model = @class.new(YAML.load(STDIN))
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
