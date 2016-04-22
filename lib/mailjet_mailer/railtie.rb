if defined?(Rails)
  require 'rails'
  module MailjetMailer
    class Railtie < Rails::Railtie
      config.mailjet_mailer = ActiveSupport::OrderedOptions.new
    end
  end
end
