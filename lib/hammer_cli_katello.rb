require 'hammer_cli'
require 'hammer_cli_foreman'
require 'hammer_cli/exit_codes'
require 'hammer_cli_foreman/commands'
require 'hammer_cli_foreman/output/fields'
require 'hammer_cli_foreman_tasks'

module HammerCLIKatello

  def self.exception_handler_class
    HammerCLIKatello::ExceptionHandler
  end

  require 'hammer_cli_katello/output/fields'
  require 'hammer_cli_katello/output/formatters'
  require 'hammer_cli_katello/lifecycle_environment_name_resolvable'
  require 'hammer_cli_katello/repository_scoped_to_product'
  require "hammer_cli_katello/commands"
  require "hammer_cli_katello/associating_commands"
  require "hammer_cli_katello/version"
  require "hammer_cli_katello/exception_handler"
  require 'hammer_cli_katello/i18n'
  require "hammer_cli_katello/version"
  require 'hammer_cli_katello/id_resolver'

  # commands
  require "hammer_cli_katello/activation_key"
  require "hammer_cli_katello/gpg_key"
  require "hammer_cli_katello/lifecycle_environment"
  require "hammer_cli_katello/organization"
  require "hammer_cli_katello/ping"
  require "hammer_cli_katello/product"
  require "hammer_cli_katello/puppet_module"
  require "hammer_cli_katello/repository"
  require "hammer_cli_katello/repository_set"
  require "hammer_cli_katello/subscription"
  require "hammer_cli_katello/sync_plan"
  require "hammer_cli_katello/host_collection"
  require "hammer_cli_katello/content_host"
  require "hammer_cli_katello/content_view"
  require "hammer_cli_katello/capsule"

end
