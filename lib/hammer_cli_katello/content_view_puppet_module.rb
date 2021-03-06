module HammerCLIKatello

  class ContentViewPuppetModule < HammerCLIKatello::Command

    resource :content_view_puppet_modules
    command_name 'puppet-module'
    desc 'View and manage puppet modules'

    class ListCommand < HammerCLIKatello::ListCommand
      output do
        field :id, _("ID")
        field :uuid, _("UUID")
        field :name, _("Name")
        field :author, _("Author")
        field :version, _("Version")
      end

      def extend_data(mod)
        if mod['uuid']
          mod['version'] = mod['computed_version']
        else
          mod['version'] = _("Latest(Currently %s)") % mod['computed_version']
        end
        mod
      end

      build_options
    end

    class CreateCommand < HammerCLIKatello::CreateCommand
      command_name "add"

      success_message _("Puppet module added to content view")
      failure_message _("Could not add the puppet module")

      build_options
    end

    class DeleteCommand < HammerCLIKatello::DeleteCommand
      command_name "remove"

      success_message _("Puppet module removed from content view")
      failure_message _("Couldn't remove puppet module from the content view")

      build_options
    end

    autoload_subcommands
  end
end
