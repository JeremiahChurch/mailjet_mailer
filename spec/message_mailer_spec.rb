require "spec_helper"

describe MailjetMailer::MessageMailer do
  let(:mailer) { described_class.new }
  let(:api_key) { '1237861278' }
  let(:secret_key) { '87654321' }

  before do
    MailjetMailer.config.api_key = api_key
    MailjetMailer.config.secret_key = secret_key
  end

  describe "#deliver_now" do
    let(:async) { double(:async) }
    # let(:ip_pool) { double(:ip_pool) }
    let(:send_at) { double(:send_at) }
    let(:message) { double(:message) }

    before do 
      mailer.async = async
      # mailer.ip_pool = ip_pool
      mailer.send_at = send_at
      mailer.message = message
    end

    it "calls the messages api with #send" do
      expect_any_instance_of(Mailjet::MessageDelivery).to receive(:create).with(message)
      mailer.deliver_now
    end
    it "has an alias deliver" do
      expect_any_instance_of(Mailjet::MessageDelivery).to receive(:create).with(message)
      mailer.deliver
    end
  end
  describe "#deliver_later" do
    let(:async) { 'async' }
    # let(:ip_pool) { 'ip_pool' }
    let(:send_at) { 'send_at'}
    let(:message) { 'this is a message'}

    it "calls the messages api with #send" do
      mailer.async = async
      # mailer.ip_pool = ip_pool
      mailer.send_at = send_at
      mailer.message = message

      expect_any_instance_of(Mailjet::MessageDelivery).to receive(:create).with(message)
      mailer.deliver_later
    end
  end
end
