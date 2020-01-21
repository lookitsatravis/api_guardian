# frozen_string_literal: true

require 'generators/api_guardian/install/install_generator'

describe 'ApiGuardian::InstallGenerator', type: :generator do
  tests ApiGuardian::InstallGenerator
  destination ::File.expand_path('../../tmp', __FILE__)

  before :each do
    prepare_destination
    allow(Rails).to receive(:root).and_return(Pathname(destination_root))
    FileUtils.mkdir(::File.expand_path('config', Pathname(destination_root)))
    FileUtils.mkdir(::File.expand_path('db', Pathname(destination_root)))
    FileUtils.mkdir(::File.expand_path('migrate', Pathname(destination_root + '/db')))
    FileUtils.copy_file(
      ::File.expand_path('../templates/routes.rb', __FILE__),
      ::File.expand_path('config/routes.rb', Pathname.new(destination_root))
    )
    FileUtils.copy_file(
      ::File.expand_path('../templates/seeds.rb', __FILE__),
      ::File.expand_path('db/seeds.rb', Pathname.new(destination_root))
    )
    run_generator
  end

  it 'creates an initializer file' do
    assert_file 'config/initializers/api_guardian.rb'
  end

  it 'adds route' do
    assert_file 'config/routes.rb', /mount ApiGuardian::Engine =>/
  end

  it 'copies migration files' do
    migration_files = %w(
      api_guardian_enable_uuid_extension create_api_guardian_roles create_api_guardian_permissions
      create_api_guardian_users create_api_guardian_role_permissions create_doorkeeper_tables
    )

    expect(destination_root).to have_structure {
      directory 'db' do
        directory 'migrate' do
          migration_files.each do |filename|
            migration filename
          end
        end
      end
    }
  end

  it 'adds seed data' do
    assert_file 'db/seeds.rb', /ApiGuardian Seeds/
  end
end
