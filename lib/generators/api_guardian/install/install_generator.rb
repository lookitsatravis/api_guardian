# frozen_string_literal: true

require 'rails/generators/base'
require 'rails/generators/active_record'

module ApiGuardian
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root File.expand_path('../templates', __FILE__)
    class_option :skip_initializer, type: :boolean, default: false, desc: 'Allow to skip initializer.'
    class_option :skip_routes, type: :boolean, default: false, desc: 'Allow to skip routes.'
    class_option :skip_migrations, type: :boolean, default: false, desc: 'Allow to skip migrations.'
    class_option :skip_seed, type: :boolean, default: false, desc: 'Allow to skip seed file additions.'

    desc 'Adds an ApiGuardian initializer, migrations, seeds, and mounts routes for your application.'

    def copy_initializer
      if options[:skip_initializer]
        ApiGuardian.logger.info 'Initializer skipped!'
        return
      end

      template 'api_guardian.rb', 'config/initializers/api_guardian.rb'
    end

    def add_routes
      if options[:skip_routes]
        ApiGuardian.logger.info 'Routes skipped!'
        return
      end

      route 'mount ApiGuardian::Engine => \'/auth\''
    end

    def create_migrations
      if options[:skip_migrations]
        ApiGuardian.logger.info 'Migrations skipped!'
        return
      end

      copy_migration 'api_guardian_enable_uuid_extension.rb'
      copy_migration 'create_api_guardian_roles.rb'
      copy_migration 'create_api_guardian_users.rb'
      copy_migration 'create_api_guardian_permissions.rb'
      copy_migration 'create_api_guardian_role_permissions.rb'
      copy_migration 'create_api_guardian_identities.rb'
      copy_migration 'create_doorkeeper_tables.rb'
    end

    def add_seed_data
      if options[:skip_seed]
        ApiGuardian.logger.info 'Seed data skipped!'
        return
      end

      seed_data = IO.read(Pathname(File.expand_path('../templates', __FILE__)).join('db', 'seeds.rb'))
      append_file(
        Rails.root.join('db', 'seeds.rb'),
        "\n\n######################################\n# ApiGuardian Seeds\n" \
        "# Added at #{Time.now}\n######################################\n\n" \
        + seed_data
      )
    end

    def show_readme
      readme 'README' if behavior == :invoke
    end

    # for generating a timestamp when using `create_migration`
    def self.next_migration_number(dir)
      ActiveRecord::Generators::Base.next_migration_number(dir)
    end

    private

    # Inspired from thoughtbot/clearance install process
    # https://github.com/thoughtbot/clearance/blob/master/lib/generators/clearance/install/install_generator.rb

    def copy_migration(migration_name, config = {})
      unless migration_exists?(migration_name)
        migration_template(
          "db/migrate/#{migration_name}",
          "db/migrate/#{migration_name}",
          config
        )
      end
    end

    def migration_exists?(name)
      existing_migrations.include?(name)
    end

    def existing_migrations
      directory = 'db/migrate'
      # If testing, we need to check the proper directory
      directory = 'spec/tmp/' + directory if Rails.env.test?
      @existing_migrations ||= Dir.glob("#{directory}/*.rb").map do |file|
        migration_name_without_timestamp(file)
      end
    end

    def migration_name_without_timestamp(file)
      file.sub(%r{^.*(db/migrate/)(?:\d+_)?}, '')
    end
  end
end
