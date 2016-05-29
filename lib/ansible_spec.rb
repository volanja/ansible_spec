require "ansible_spec/version"
require "ansible_spec/load_ansible"
require "fileutils"

# Reference
# https://github.com/serverspec/serverspec/blob/master/lib/serverspec/setup.rb
# Reference License (MIT)
# https://github.com/serverspec/serverspec/blob/master/LICENSE.txt

module AnsibleSpec

  def self.main()
    safe_create_spec_helper
    safe_create_rakefile
    safe_create_ansiblespec
    safe_create_rspec
  end


  def self.safe_create_spec_helper
    content = File.open(File.dirname(__FILE__) + "/../lib/src/spec/spec_helper.rb").read
    safe_mkdir("spec")
    safe_touch("spec/spec_helper.rb")
    File.open("spec/spec_helper.rb", 'w') do |f|
      f.puts content
    end

  end

  def self.safe_create_rakefile
    content = File.open(File.dirname(__FILE__) + "/../lib/src/Rakefile").read
    safe_touch("Rakefile")
    File.open("Rakefile", 'w') do |f|
      f.puts content
    end
  end

  def self.safe_create_ansiblespec
    content = File.open(File.dirname(__FILE__) + "/../lib/src/.ansiblespec").read
    safe_touch(".ansiblespec")
    File.open(".ansiblespec", 'w') do |f|
      f.puts content
    end
  end

  def self.safe_create_rspec
    content = File.open(File.dirname(__FILE__) + "/../lib/src/.rspec").read
    safe_touch(".rspec")
    File.open(".rspec", 'w') do |f|
      f.puts content
    end
  end

  def self.safe_mkdir(dir)
    unless FileTest.exist?("#{dir}")
      FileUtils.mkdir_p("#{dir}")
      TermColor.green
      puts "\t\tcreate\t#{dir}"
      TermColor.reset
    else
      TermColor.red
      puts "\t\texists\t#{dir}"
      TermColor.reset
    end
  end

  def self.safe_touch(file)
    unless File.exists? "#{file}"
      File.open("#{file}", 'w') do |f|
          #f.puts content
      end
      TermColor.green
      puts "\t\tcreate\t#{file}"
      TermColor.reset
    else 
      TermColor.red
      puts "\t\texists\t#{file}"
      TermColor.reset
    end
  end

  class TermColor
    class << self
      # 色を解除
      def reset   ; c 0 ; end 

      # 各色
      def red     ; c 31; end 
      def green   ; c 32; end 

      # カラーシーケンスの出力
      def c(num)
        print "\e[#{num.to_s}m"
      end 
    end 
  end

end
