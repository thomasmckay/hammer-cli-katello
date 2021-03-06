module HammerCLIKatello

  class HostCollection < HammerCLIKatello::Command
    resource :host_collections

    module UuidRequestable
      def self.included(base)
        base.option "--host-collection-ids",
                    "HOST_COLLECTION_IDS",
                    _("Array of system ids to replace the content hosts in host collection"),
                    :format => HammerCLI::Options::Normalizers::List.new
      end

      def request_params
        params = super
        params['system_uuids'] = option_host_collection_ids unless option_host_collection_ids.nil?
        params.delete('host_collection_ids') if params.keys.include? 'host_collection_ids'
        params
      end
    end

    class ListCommand < HammerCLIKatello::ListCommand
      resource :host_collections, :index

      output do
        field :id, _("ID")
        field :name, _("Name")
        field :max_content_hosts, _("Limit")
        field :description, _("Description")
      end

      build_options
    end

    class CreateCommand < HammerCLIKatello::CreateCommand
      include UuidRequestable
      resource :host_collections, :create

      success_message _("Host collection created")
      failure_message _("Could not create the host collection")
      build_options :without => [:system_uuids]
    end

    class InfoCommand < HammerCLIKatello::InfoCommand
      resource :host_collections, :show

      output ListCommand.output_definition do
        field :total_content_hosts, _("Total Content Hosts")
        field :max_content_hosts, _("Max Content Hosts")
      end

      build_options
    end

    class ContentHostsCommand < HammerCLIKatello::ListCommand
      resource :host_collections, :systems
      command_name "content-hosts"

      output do
        field :uuid, _("ID")
        field :name, _("Name")
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
      action  :add_systems

      success_message _("The content host(s) has been added")
      failure_message _("Could not add content host(s)")

      build_options
    end

    class RemoveContentHostCommand < HammerCLIKatello::SingleResourceCommand
      command_name 'remove-content-host'
      action  :remove_systems

      success_message _("The content host(s) has been removed")
      failure_message _("Could not remove content host(s)")

      build_options
    end

    autoload_subcommands
  end
end

HammerCLI::MainCommand.subcommand 'host-collection', _("Manipulate host collections"),
                                  HammerCLIKatello::HostCollection
