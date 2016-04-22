# Public: Matcher for asserting subject
#
#   expected_subject: - Expected subject of email
#
# WelcomeMailer is an instance of MailjetMailler::TemplateMailer
#
# let(:user) { create(:user) }
# let(:mailer) { WelcomeMailer.welcome_registered(user) }
# it 'has the correct data' do
#   expect(mailer).to have_subject('Welcome Subscriber')
# end
#
# Returns true or an error message on failure
#
RSpec::Matchers.define :have_subject do |expected_subject|
  match do |mailer|
    mailer_subject(mailer) == expected_subject
  end

  failure_message_for_should do |actual|
    <<-MESSAGE.strip_heredoc
    Expected subject: #{mailer_subject(mailer).inspect} to be: #{expected_subject.inspect}.
  MESSAGE
  end

  failure_message_for_should_not do |actual|
    <<-MESSAGE.strip_heredoc
    Expected subject: #{mailer_subject(mailer).inspect} to not be: #{expected_subject.inspect}.
  MESSAGE
  end

  description do
    "be the same subject as #{expected_subject.inspect}"
  end

  def mailer_subject(mailer)
    mailer.message['subject']
  end
end
