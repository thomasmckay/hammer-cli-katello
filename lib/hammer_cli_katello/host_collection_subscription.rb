module HammerCLIKatello
  class HostCollectionSubscriptionCommand < HammerCLIKatello::Command
    command_name "subscription"
    desc _("Manipulate subscriptions for a host collection")

    class ListSubscriptionsCommand < HammerCLIKatello::ListCommand
      command_name "list"
      resource :systems_bulk_actions
      action :subscriptions

      #option "--id", "ID", _("ID of host collection"),
      #       :attribute_name => :option_id
      #option "--name", "NAME", _("Name of host collection"),
      #       :attribute_name => :option_name
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
        end
        custom_resolver.new(api, HammerCLIKatello::Searchables.new)
      end

      output do
        field :product_name, _("Name")
        field :contract_number, _("Contract")
        field :account_number, _("Account")
        field :support_level, _("Support")
        field :format_quantity, _("Quantity")
        field :consumed, _("Consumed")
        field :end_date, _("End Date")
        field :id, _("ID")
        field :product_name, _("Product")
        field :consumed, _("Attached")
      end

      def extend_data(data)
        data["format_quantity"] = data["quantity"] == -1 ? _("Unlimited") : data["quantity"]
        data
      end
    end

    class AutoAttachSubscriptionsCommand < HammerCLIKatello::SingleResourceCommand
      include HammerCLIForemanTasks::Async
      resource :host_collections, :autoattach_subscriptions
      command_name "auto-attach"

      build_options

      success_message _("Auto-attach subscriptions completed on content hosts in collection")
      failure_message _("Unable to auto-attach subscriptions to content hosts in collection")
    end

    class AddSubscriptionsCommand < HammerCLIKatello::SingleResourceCommand
      include HammerCLIForemanTasks::Async
      resource :host_collections, :add_subscriptions
      command_name "attach"

      option "--subscription-id", "SUBSCRIPTION_ID", _("ID of subscription"),
             :attribute_name => :option_subscription_id, :required => true
      option "--quantity", "QUANTITY", _("Subscription quantity (do not specify to indicate automatic)"),
             :attribute_name => :option_quantity, :required => false

      build_options do |o|
        o.expand.except(:subscriptions)
        o.without(:subscriptions)
      end

      def request_params
        params = super
        params[:subscriptions] = [{
            :id => options['option_subscription_id'],
            :quantity => options['option_quantity'] || -1
        }]
        params
      end

      success_message _("Subscription added to content hosts in collection")
      failure_message _("Could not add subscription to content hosts in collection")
    end

    class RemoveSubscriptionCommand < HammerCLIKatello::SingleResourceCommand
      include HammerCLIForemanTasks::Async
      resource :host_collections, :remove_subscriptions

      desc _("Remove subscription")
      command_name "unattach"

      option "--subscription-id", "SUBSCRIPTION_ID", _("ID of subscription"),
             :attribute_name => :option_subscription_id, :required => true

      build_options do |o|
        o.expand.except(:subscriptions)
        o.without(:subscriptions)
      end

      def request_params
        params = super
        params[:subscriptions] = [{
            :id => options['option_subscription_id'],
            :quantity => options['option_quantity'] || -1
        }]
        params
      end

      success_message _("Subscription removed from content hosts in collection")
      failure_message _("Could not remove subscription from content hosts in collection")
    end

    autoload_subcommands
  end
end
