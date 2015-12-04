module ApiGuardian
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc 'Creates an ApiGuardian initializer and copy locale files to your application.'

    def copy_initializer
      template 'api_guardian.rb', 'config/initializers/api_guardian.rb'
    end

    def add_routes
      route 'mount ApiGuardian::Engine => \'/auth\''
    end

    def show_readme
      readme 'README' if behavior == :invoke
    end
  end
end
