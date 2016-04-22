# Mailjet Mailer

I love renz45's mandrill_mailer gem, I hate the new price structure of mandrill/mailchimp, I equally didn't like the lackluster mailjet official gem
and it's non-standard mailer handling.

Thus mailjet mailer - a find & replace port of mandrill_mailer to mailjet. it's a day-one gem with barely minimimal features but it's at least working for us. Any contributions are welcomed & encouraged

Inherit the MailjetMailer class in your existing Rails mailers to send transactional emails through Mailjet using their template-based emails.

## Installation
Add this line to your application's Gemfile:

```
gem 'mailjet_mailer'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install mailjet_mailer
```

## Usage
Add the following to your `mail.rb` in your Rails app's `config/initializers` directory:

```ruby
Mailjet.configure do |config|
  config.api_key = ENV['MAILJET_API_KEY']
  config.secret_key = ENV['MAILJET_SECRET_KEY']
end

MailjetMailer.configure do |config|
  config.default_from = ENV['MAILJET_DEFAULT_FROM']
  config.default_from_name = ENV['MAILJET_DEFAULT_FROM_NAME']
  config.deliver_later_queue_name = :default # optional
end
```

Do not forget to setup the environment (`ENV`) variables on your server instead
of hardcoding your Mailjet username and password in the `mail.rb` initializer.

You will also need to set `default_url_options` for the mailer, similar to ActionMailer
in your environment config files in `config/environments`:

```ruby
config.mailjet_mailer.default_url_options = { :host => 'localhost' }
```

## Creating a new mailer
Creating a new Mailjet mailer is similar to a typical Rails one:

```ruby
class InvitationMailer < MailjetMailer::MessageMailer
  default from: 'support@example.com'

  def invite(invitation)
    # in this example `invitation.invitees` is an Array
    invitees = invitation.invitees.map { |invitee| { email: invitee.email, name: invitee.name } }

    mailjet_mail(
      template: '132456', # mailjet ID number of template
      subject: I18n.t('invitation_mailer.invite.subject'),
      to: invitees,
        # to: invitation.email,
        # to: { email: invitation.email, name: 'Honored Guest' },
      vars: {
        'OWNER_NAME' => invitation.owner_name,
        'PROJECT_NAME' => invitation.project_name
      }
      end
     )
  end
end
```

* `#default:`
  * `:from` - set the default from email address for the mailer.  Defaults to `'example@email.com'`.
  * `:from_name` - set the default from name for the mailer. If not set, defaults to from email address. Setting :from_name in the .mailjet_mail overrides the default.
  
* `.mailjet_mail`
   * `:template`(required) - Template slug from within Mailjet

   * `:subject` - Subject of the email. If no subject supplied, it will fall back to the template default subject from within Mailjet

   * `:to`(required) - Accepts an email String, a Hash with :name and :email keys, or an Array of Hashes with :name, :email, and :type keys
      - examples:
        1. `'example@domain.com'`
        2. `{ email: 'someone@email.com', name: 'Bob Bertly' }`
        3. `[{ email: 'someone@email.com', name: 'Bob Bertly' }, { email: 'other@email.com', name: 'Claire Nayo' }]`
        4. `[{ email: 'someone@email.com', name: 'Bob Bertly', type: 'to'}, { email: 'secret_recipient1@email.com', name: 'Secret Recipient One'}, { email: 'secret_recipient2@email.com', name: 'Secret Recipient Two'}]`

   * `:vars` - A Hash of merge tags made available to the email. Use them in the
     email by wrapping them in `*||*`. For example `{'OWNER_NAME' => 'Suzy'}` is used by doing: `*|OWNER_NAME|*` in the email template within Mailjet

   * `:recipient_vars` - Similar to `:vars`, this is a Hash of merge vars specific to a particular recipient.
     Use this if you are sending batch transactions and hence need to send multiple emails at one go.
     ex. `[{'someone@email.com' => {'INVITEE_NAME' => 'Roger'}}, {'another@email.com' => {'INVITEE_NAME' => 'Tommy'}}]`

   * `:headers` - Extra headers to add to the message (currently only `Reply-To` and `X-*` headers are allowed) {"...": "..."}

   * `:attachments` - An array of file objects with the following keys:
     * `content`: The file contents, this will be encoded into a base64 string internally
     * `name`: The name of the file
     * `type`: This is the mimetype of the file. Ex. png = image/png, pdf = application/pdf, txt = text/plain etc etc

   * `:images` - An array of embedded images to add to the message:
     * `content`: The file contents, this will be encoded into a base64 string internally
     * `name`: The name of the file
     * `type`: This is the mimetype of the file. Ex. png = image/png, pdf = application/pdf, txt = text/plain etc etc etc


## Sending a message without template
Sending a message without template is similar to sending a one with a template. Unlike the mandrill mailer you don't have to inherit a different class. you just use different values

```ruby
class InvitationMailer < MailjetMailer::MessageMailer
  default from: 'support@example.com'

  def invite(invitation)
    # in this example `invitation.invitees` is an Array
    invitees = invitation.invitees.map { |invitee| { email: invitee.email, name: invitee.name } }

    # no need to set up template and template_content attributes, set up the html and text directly
    mailjet_mail subject: I18n.t('invitation_mailer.invite.subject'),
                  to: invitees,
                  # to: invitation.email,
                  # to: { email: invitation.email, name: 'Honored Guest' },
                  text: "Example text content",
                  html: "<p>Example HTML content</p>",
                  # when you need to see the content of individual emails sent to users
                  attachments: [
                    {
                      content: File.read(File.expand_path('assets/offer.pdf')),
                      name: 'offer.pdf',
                      type: 'application/pdf'
                    }
                  ],
                  recipient_vars: invitation.invitees.map do |invitee| # invitation.invitees is an Array
                    { invitee.email =>
                      {
                        'INVITEE_NAME' => invitee.name,
                        'INVITATION_URL' => new_invitation_url(invitee.email, secret: invitee.secret_code)
                      }
                    }
                  end
  end
end
```

## Sending an email

You can send the email by using the familiar syntax:

`InvitationMailer.invite(invitation).deliver_now`
`InvitationMailer.invite(invitation).deliver_later(wait: 1.hour)`
For deliver_later, Active Job will need to be configured 

## Creating a test method
When switching over to Mailjet for transactional emails we found that it was hard to setup a mailer in the console to send test emails easily (those darn designers), but really, you don't want to have to setup test objects everytime you want to send a test email. You can set up a testing 'mock' once and then call the `.test` method to send the test email.

You can test the above email by typing: `InvitationMailer.test(:invite, email:<your email>)` into the Rails Console.

The test for this particular Mailer is setup like so:

```ruby
test_setup_for :invite do |mailer, options|
    invitation = MailjetMailer::Mock.new({
      email: options[:email],
      owner_name: 'foobar',
      secret: rand(9000000..1000000).to_s
    })
    mailer.invite(invitation).deliver
end
```

Use MailjetMailer::Mock to mock out objects.

If in order to represent a url within a mock, make sure there is a `url` or `path` attribute,
for example, if I had a course mock and I was using the `course_url` route helper within the mailer
I would create the mock like so:

```ruby
course = MailjetMailer::Mock.new({
  title: 'zombies',
  type: 'Ruby',
  url: 'http://funzone.com/zombies'
})
```

This would ensure that `course_url(course)` works as expected.

The mailer and options passed to the `.test` method are yielded to the block.

The `:email` option is the only required option, make sure to add at least this to your test object.

## Offline Testing
You can turn on offline testing by requiring this file (say, in your spec_helper.rb):

```ruby
require 'mailjet_mailer/offline'
```

And then if you wish you can look at the contents of `MailjetMailer.deliveries` to see whether an email was queued up by your test:

```ruby
email = MailjetMailer::deliveries.detect { |mail|
  mail.template_name == 'my-template' &&
  mail.message['to'].any? { |to| to[:email] == 'my@email.com' }
}
expect(email).to_not be_nil
```

Don't forget to clear out deliveries:

```ruby
before :each { MailjetMailer.deliveries.clear }
```

## Using Delayed Job
The typical Delayed Job mailer syntax won't work with this as of now. Either create a custom job or que the mailer as you would que a method. Take a look at the following examples:

```ruby
def send_hallpass_expired_mailer
  HallpassMailer.hallpass_expired(user).deliver
end
handle_asynchronously :send_hallpass_expired_mailer
```

or using a custom job

```ruby
def update_email_on_newsletter_subscription(user)
  Delayed::Job.enqueue( UpdateEmailJob.new(user_id: user.id) )
end
```
The job looks like (Don't send full objects into jobs, send ids and requery inside the job. This prevents Delayed Job from having to serialize and deserialize whole ActiveRecord Objects and this way, your data is current when the job runs):

```ruby
class UpdateEmailJob < Struct.new(:user_id)
  def perform
    user = User.find(user_id)
    HallpassMailer.hallpass_expired(user).deliver
  end
end
```

## Using Sidekiq
Create a custom worker:

```ruby
class UpdateEmailJob
  include Sidekiq::Worker
  def perform(user_id)
    user = User.find(user_id)
    HallpassMailer.hallpass_expired(user).deliver
  end
end

#called by
UpdateEmailJob.perform_async(<user_id>)
```

Or depending on how up to date things are, try adding the following to `config/initializers/mailjet_mailer_sidekiq.rb`

```ruby
::MailjetMailer::MessageMailer.extend(Sidekiq::Extensions::ActionMailer)
```

This should enable you to use this mailer the same way you use ActionMailer.
More info: https://github.com/mperham/sidekiq/wiki/Delayed-Extensions#actionmailer


## Using an interceptor
You can set a mailer interceptor to override any params used when you deliver an e-mail.
The interceptor is a Proc object that gets called with the mail object being sent
to the api.

Example that adds multiple bcc recipients:

```ruby
MailjetMailer.configure do |config|
  config.interceptor = Proc.new {|params|

    params[:to] =  [
      params[:to],
      { email: "bccEmailThatWillBeUsedInAll@emailsSent1.com", name: "name", type: "bcc" },
      { email: "bccEmailThatWillBeUsedInAll@emailsSent2.com", name: "name", type: "bcc" },
      { email: "bccEmailThatWillBeUsedInAll@emailsSent3.com", name: "name", type: "bcc" }
    ].flatten
  }
end
```
