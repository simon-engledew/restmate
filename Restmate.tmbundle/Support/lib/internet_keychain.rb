module InternetKeychain
  class << self
    
    def []=(user, protocol, host, path, password)
      %x{security add-internet-password -a "#{user}" -s "#{host}" -r "#{protocol}" -p "#{path}" -w "#{password}"}
    end
    
    def [](user, protocol, host, path)
      result =  %x{security find-internet-password -g -a "#{user}" -s "#{host}" -p "#{path}" -r #{protocol} 2>&1 >/dev/null}
      result =~ /^password: "(.*)"$/ ? $1 : nil
    end

  end
end
