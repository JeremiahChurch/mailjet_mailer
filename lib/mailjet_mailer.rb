require 'action_view'
require 'active_job'
require 'mailjet_mailer/railtie'
require 'mailjet_mailer/mock'
require 'mailjet_mailer/message_mailer'
require 'mailjet_mailer/version'

module MailjetMailer
  autoload :Mailjet, 'mailjet'

  if defined?(Rails)
    def self.configure(&block)
      if block_given?
        block.call(MailjetMailer::Railtie.config.mailjet_mailer)
      else
        MailjetMailer::Railtie.config.mailjet_mailer
      end
    end

    def self.config
      MailjetMailer::Railtie.config.mailjet_mailer
    end
  else
    def self.config
      @@config ||= OpenStruct.new(api_key: nil, secret_key: nil)
      @@config
    end
  end
end
