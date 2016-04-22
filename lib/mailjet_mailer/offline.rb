# Offline modifications for using MailjetMailer without actually sending
# emails through Mailjet's API. Particularly useful for acceptance tests.
#
# To use, just require this file (say, in your spec_helper.rb):
#
#   require 'mailjet_mailer/offline'
#
# And then if you wish you can look at the contents of
# MailjetMailer.deliveries to see whether an email was queued up by your test:
#
#   email = MailjetMailer::deliveries.detect { |mail|
#     mail.template_name == 'my-template' &&
#     mail.message['to'].any? { |to| to['email'] == 'my@email.com' }
#   }
#   expect(email).to_not be_nil
#
# Don't forget to clear out deliveries:
#
#   before :each { MailjetMailer.deliveries.clear }
#
require 'mailjet_mailer'

module MailjetMailer
  def self.deliveries
    @deliveries ||= []
  end

  class TemplateMailer
    def deliver
      deliver_now
    end
    
    def deliver_now
      MailjetMailer::Mock.new({
        :template_name    => template_name,
        :template_content => template_content,
        :message          => message,
        :async            => async,
        # :ip_pool          => ip_pool,
        :send_at          => send_at
      }).tap do |mock|
         MailjetMailer.deliveries << mock
      end
    end
    def deliver_later
      MailjetMailer::Mock.new({
        :template_name    => template_name,
        :template_content => template_content,
        :message          => message,
        :async            => async,
        # :ip_pool          => ip_pool,
        :send_at          => send_at
      }).tap do |mock|
         MailjetMailer.deliveries << mock
      end
    end
  end

  class MessageMailer
    def deliver
      deliver_now
    end
    def deliver_now
      MailjetMailer::Mock.new({
        :message          => message,
        :async            => async,
        # :ip_pool          => ip_pool,
        :send_at          => send_at
      }).tap do |mock|
         MailjetMailer.deliveries << mock
      end
    end
    def deliver_later
      MailjetMailer::Mock.new({
        :message          => message,
        :async            => async,
        # :ip_pool          => ip_pool,
        :send_at          => send_at
      }).tap do |mock|
         MailjetMailer.deliveries << mock
      end
    end
  end
end
