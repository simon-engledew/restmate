module Bundle
  class << self

    public

    ExitCodes = {
      :discard => 200,
      :replace_text => 201,
      :replace_document => 202,
      :insert_text => 203,
      :insert_snippet => 204,
      :show_html => 205,
      :show_tooltip => 206,
      :create_document => 207
    }

    def exit(message, out = nil)
      print out if out and message != :discard
      Kernel.exit ExitCodes[message] || ExitCodes[:discard]
    end
    
    def dropdown(options)
      cocoa_dialog(:dropdown, options)
    end

    def secure_input_box(options)
      cocoa_dialog('secure-standard-inputbox', options)
    end
    
private
    
    def cocoa_dialog(type, options)
      %x{"#{ENV['TM_SUPPORT_PATH']}/bin/CocoaDialog.app/Contents/MacOS/CocoaDialog" 2>/dev/console #{type} --float #{options.to_a.map{|a, b|"--#{a} #{b}"}.join(' ')}}.match(/^(\d+)\n(.*)$/)
      return $1 == '1' ? $2 : nil
    end
    
  end
end