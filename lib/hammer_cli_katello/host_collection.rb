module HammerCLIKatello

  class HostCollection < HammerCLIKatello::Command
    resource :host_collections

    module UuidRequestable
      def self.included(base)
        base.option("--host-collection-ids",
          "HOST_COLLECTION_IDS",
          _("Array of content host ids to replace the content hosts in host collection"),
          :format => HammerCLI::Options::Normalizers::List.new)
      end

      def request_params
        params = super
        params['system_uuids'] = option_system_ids unless option_system_ids.nil?
        params.delete('system_ids') if params.keys.include? 'system_ids'
        params
      end
    end

    module LimitFieldDataExtension
      def extend_data(data)
        data['_limit'] = data['unlimited_content_hosts'] ? 'None' : data['max_content_hosts']
        data
      end
    end

    class ListCommand < HammerCLIKatello::ListCommand
      include LimitFieldDataExtension
      resource :host_collections, :index

      output do
        field :id, _("ID")
        field :name, _("Name")
        field :_limit, _("Limit")
        field :description, _("Description")
      end

      build_options
    end

    class CreateCommand < HammerCLIKatello::CreateCommand
      include UuidRequestable
      resource :host_collections, :create
      def request_params
        super.tap do |params|
          if params['max_content_hosts'] && params['unlimited_content_hosts'].nil?
            params['unlimited_content_hosts'] = false
          end
        end
      end

      success_message _("Host collection created")
      failure_message _("Could not create the host collection")
      build_options :without => [:system_uuids]
    end

    class InfoCommand < HammerCLIKatello::InfoCommand
      include LimitFieldDataExtension
      resource :host_collections, :show

      output ListCommand.output_definition do
        field :total_content_hosts, _("Total Content Hosts")
      end

      build_options
    end

    class ContentHostsCommand < HammerCLIKatello::ListCommand
      resource :host_collections, :systems
      command_name "content-hosts"

      output do
        field :uuid, _("ID")
        field :name, _("Name")
        from :environment do
          field :name, _("Lifecycle Environment")
        end
        from :content_view do
          field :name, _("Content View")
        end
        from :errata_counts do
          field :total, _("Installable Errata")
        end
        field :entitlementStatus, _("Entitlement Status")
      end

      build_options
    end

    class CopyCommand < HammerCLIKatello::CreateCommand
      resource :host_collections, :copy

      action :copy
      command_name "copy"

      success_message _("Host collection created")
      failure_message _("Could not create the host collection")

      validate_options do
        all(:option_name).required unless option(:option_id).exist?
      end

      build_options
    end

    class UpdateCommand < HammerCLIKatello::UpdateCommand
      include UuidRequestable
      success_message _("Host collection updated")
      failure_message _("Could not update the the host collection")

      build_options :without => [:system_uuids]
    end

    class DeleteCommand < HammerCLIKatello::DeleteCommand
      resource :host_collections, :destroy

      success_message _("Host collection deleted")
      failure_message _("Could not delete the host collection")

      build_options
    end

    class AddContentHostCommand < HammerCLIKatello::SingleResourceCommand
      command_name 'add-content-host'
      action :add_systems

      success_message _("The content host(s) has been added")
      failure_message _("Could not add content host(s)")

      build_options
    end

    class RemoveContentHostCommand < HammerCLIKatello::SingleResourceCommand
      command_name 'remove-content-host'
      action :remove_systems

      success_message _("The content host(s) has been removed")
      failure_message _("Could not remove content host(s)")

      build_options
    end

    autoload_subcommands

    class ContentBaseCommand < DeleteCommand
      resource :systems_bulk_actions

      def request_params
        params = super
        params['content'] = content
        params['content_type'] = content_type
        params['included'] = { :search => "host_collection_ids:#{params['id']}" }
        params.delete('id')
        params
      end

      def resolver
        api = HammerCLI::Connection.get("foreman").api
        custom_resolver = Class.new(HammerCLIKatello::IdResolver) do
          def systems_bulk_action_id(options)
            host_collection_id(options)
          end
        end
        custom_resolver.new(api, HammerCLIKatello::Searchables.new)
      end
    end

    class InstallContentBaseCommand < ContentBaseCommand
      action :install_content
      command_name "install"

      build_options do |o|
        o.without(:content_type, :content, :ids, :search)
      end
    end

    class UpdateContentBaseCommand < ContentBaseCommand
      action :update_content
      command_name "update"

      build_options do |o|
        o.without(:content_type, :content, :ids, :search)
      end
    end

    class RemoveContentBaseCommand < ContentBaseCommand
      action :remove_content
      command_name "remove"

      build_options do |o|
        o.without(:content_type, :content, :ids, :search)
      end
    end

    class SubscriptionBaseCommand < DeleteCommand
      resource :systems_bulk_actions

      build_options do |o|
        o.without(:ids, :search)
      end

      def request_params
        params = super
        params['included'] = { :search => "host_collection_ids:#{params['id']}" }
        params.delete('id')
        params
      end

      def resolver
        api = HammerCLI::Connection.get("foreman").api
        custom_resolver = Class.new(HammerCLIKatello::IdResolver) do
          def systems_bulk_action_id(options)
            host_collection_id(options)
          end
          def systems_id(options)
            host_collection_id(options)
          end
        end
        custom_resolver.new(api, HammerCLIKatello::Searchables.new)
      end
    end

    require 'hammer_cli_katello/host_collection_package'
    subcommand HammerCLIKatello::HostCollectionPackageCommand.command_name,
               HammerCLIKatello::HostCollectionPackageCommand.desc,
               HammerCLIKatello::HostCollectionPackageCommand

    require 'hammer_cli_katello/host_collection_package_group'
    subcommand HammerCLIKatello::HostCollectionPackageGroupCommand.command_name,
               HammerCLIKatello::HostCollectionPackageGroupCommand.desc,
               HammerCLIKatello::HostCollectionPackageGroupCommand

    require 'hammer_cli_katello/host_collection_erratum'
    subcommand HammerCLIKatello::HostCollectionErratumCommand.command_name,
               HammerCLIKatello::HostCollectionErratumCommand.desc,
               HammerCLIKatello::HostCollectionErratumCommand

    require 'hammer_cli_katello/host_collection_subscription'
    subcommand HammerCLIKatello::HostCollectionSubscriptionCommand.command_name,
               HammerCLIKatello::HostCollectionSubscriptionCommand.desc,
               HammerCLIKatello::HostCollectionSubscriptionCommand
  end

end
