require 'mailjet_mailer/message_mailer'
module MailjetMailer
  class MailjetMessageJob < ActiveJob::Base
    queue_as { MailjetMailer.config.deliver_later_queue_name }

    def perform(message, async, send_at, mailer='MailjetMailer::MessageMailer')
      mailer = mailer.constantize.new
      mailer.message = message
      mailer.async = async
      # mailer.ip_pool = ip_pool
      mailer.send_at = send_at
      mailer.deliver_now
    end
  end
end
