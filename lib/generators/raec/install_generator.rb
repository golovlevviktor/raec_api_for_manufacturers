require 'rails/generators'


module Raec
  module Generators
    class InstallGenerator < Rails::Generators::Base


      source_root File.expand_path("../../templates", __FILE__)

      def copy_initializer_file
        copy_file "raec.rb", "config/initializers/raec.rb"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end

    end
  end
end


