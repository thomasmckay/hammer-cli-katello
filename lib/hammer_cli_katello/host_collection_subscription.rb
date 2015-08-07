module HammerCLIKatello
  class HostCollectionSubscriptionCommand < HammerCLIKatello::Command
    command_name "subscription"
    desc _("Manipulate subscriptions for a host collection")

    class AddSubscriptionsCommand < HammerCLIKatello::Command
      resource :host_collections, :add_subscriptions
      #action :add_subscriptions

      desc "Add subscription"
      command_name "attach"

      #option "--subscription-id", "SUBSCRIPTION_ID", _("ID of subscription"),
      #       :attribute_name => :option_subscription_id, :required => true

      #build_options do |o|
      #  o.expand.except(:subscriptions)
      #  o.without(:subscriptions)
      #end

      success_message _("Subscription added to activation key")
      failure_message _("Could not add subscription to activation key")
    end

    class RemoveSubscriptionCommand < HammerCLIKatello::SingleResourceCommand
      action :remove_subscriptions

      desc _("Remove subscription")
      command_name "unattach"

      option "--subscription-id", "SUBSCRIPTION_ID", _("ID of subscription"),
             :attribute_name => :option_subscription_id, :required => true

      build_options do |o|
        o.expand.except(:subscriptions)
        o.without(:subscriptions)
      end

      success_message _("Subscription removed from activation key")
      failure_message _("Could not remove subscription from activation key")
    end

    autoload_subcommands
  end
end
