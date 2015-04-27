# MandrilMailer class for sending transactional emails through mandril.
# Only template based emails are supported at this time.

# Example usage:

# class InvitationMailer < MandrillMailer::TemplateMailer
#   default from: 'support@codeschool.com'

#   def invite(invitation)
#     invitees = invitation.invitees.map { |invitee| { email: invitee.email, name: invitee.name } }
#
#     mandrill_mail template: 'Group Invite',
#                   subject: I18n.t('invitation_mailer.invite.subject'),
#                   to: invitees,
#                   # to: invitation.email
#                   # to: { email: invitation.email, name: invitation.recipient_name }
#                   vars: {
#                     'OWNER_NAME' => invitation.owner_name,
#                     'PROJECT_NAME' => invitation.project_name
#                   },
#                   recipient_vars: invitation.invitees.map do |invitee| # invitation.invitees is an Array
#                                     { invitee.email =>
#                                       {
#                                         'INVITEE_NAME' => invitee.name,
#                                         'INVITATION_URL' => new_invitation_url(invitee.email, secret: invitee.secret_code)
#                                       }
#                                     }
#                                   end,
#                   template_content: {},
#                   attachments: [{contents: File.read(File.expand_path('assets/some_image.png')), name: 'MyImage.png', type: 'image/png'}],
#                   important: true,
#                   inline_css: true
#   end
# end

# #default:
#   :from - set the default from email address for the mailer

# .mandrill_mail
#   :template(required) - Template name from within Mandrill

#   :subject(required) - Subject of the email

#   :to(required) - Accepts an email String, a Hash with :name and :email keys
#                   or an Array of Hashes with :name and :email keys
#     examples:
#       1)
#         'example@domain.com`
#       2)
#         { email: 'someone@email.com', name: 'Bob Bertly' }
#       3)
#         [{ email: 'someone@email.com', name: 'Bob Bertly' },
#          { email: 'other@email.com', name: 'Claire Nayo' }]
#

#   :vars - A Hash of merge tags made available to the email. Use them in the
#     email by wrapping them in '*||*' vars: {'OWNER_NAME' => 'Suzy'} is used
#     by doing: *|OWNER_NAME|* in the email template within Mandrill
#
#   :recipient_vars - Similar to :vars, this is a Hash of merge tags specific to a particular recipient.
#     Use this if you are sending batch transactions and hence need to send multiple emails at one go.
#     ex. [{'someone@email.com' => {'INVITEE_NAME' => 'Roger'}}, {'another@email.com' => {'INVITEE_NAME' => 'Tommy'}}]

#   :template_content - A Hash of values and content for Mandrill editable content blocks.
#     In MailChimp templates there are editable regions with 'mc:edit' attributes that look
#     a little like: '<div mc:edit="header">My email content</div>' You can insert content directly into
#     these fields by passing a Hash {'header' => 'my email content'}

#   :attachments - An array of file objects with the following keys:
#       content: The file contents, this will be encoded into a base64 string internally
#       name: The name of the file
#       type: This is the mimetype of the file. Ex. png = image/png, pdf = application/pdf, txt = text/plain etc

#   :images - An array of embedded images to add to the message:
#       content: The file contents, this will be encoded into a base64 string internally
#       name: The name of the file
#       type: This is the mimetype of the file. Ex. png = image/png, pdf = application/pdf, txt = text/plain etc

# :headers - Extra headers to add to the message (currently only Reply-To and X-* headers are allowed) {"...": "..."}

# :bcc - Add an email to bcc to

# :tags - Array of Strings to tag the message with. Stats are
#   accumulated using tags, though we only store the first 100 we see,
#   so this should not be unique or change frequently. Tags should be
#   50 characters or less. Any tags starting with an underscore are
#   reserved for internal use and will cause errors.

# :google_analytics_domains - Array of Strings indicating for which any
#   matching URLs will automatically have Google Analytics parameters appended
#   to their query string automatically.

# :google_analytics_campaign - String indicating the value to set for
#   the utm_campaign tracking parameter. If this isn't provided the email's
#   from address will be used instead.

# :inline_css - whether or not to automatically inline all CSS styles provided in the
#   message HTML - only for HTML documents less than 256KB in size

# :important - whether or not this message is important, and should be delivered ahead of non-important messages
require 'base64'
require 'mandrill_mailer/core_mailer'
require 'mandrill_mailer/arg_formatter'

module MandrillMailer
  class TemplateMailer < MandrillMailer::CoreMailer

    # Public: The name of the template to use
    attr_accessor :template_name

    # Public: Template content
    attr_accessor :template_content

    # Public: Triggers the stored Mandrill params to be sent to the Mandrill api
    def deliver
      mandrill = Mandrill::API.new(api_key)
      mandrill.messages.send_template(template_name, template_content, message, async, ip_pool, send_at)
    end

    # Public: Build the hash needed to send to the mandrill api
    #
    # args - The Hash options used to refine the selection:
    #             :template - Template name in Mandrill
    #             :subject - Subject of the email
    #             :to - Email to send the mandrill email to
    #             :vars - Global merge vars used in the email for dynamic data
    #             :recipient_vars - Merge vars used in the email for recipient-specific dynamic data
    #             :bcc - bcc email for the mandrill email
    #             :tags - Tags for the email
    #             :google_analytics_domains - Google analytics domains
    #             :google_analytics_campaign - Google analytics campaign
    #             :inline_css - whether or not to automatically inline all CSS styles provided in the message HTML
    #             :important - whether or not this message is important
    #             :async - whether or not this message should be sent asynchronously
    #             :ip_pool - name of the dedicated IP pool that should be used to send the message
    #             :send_at - when this message should be sent
    #
    # Examples
    #
    #   mandrill_mail template: 'Group Invite',
    #               subject: I18n.t('invitation_mailer.invite.subject'),
    #               to: invitation.email,
    #               vars: {
    #                 'OWNER_NAME' => invitation.owner_name,
    #                 'INVITATION_URL' => new_invitation_url(email: invitation.email, secret: invitation.secret)
    #               }
    #
    # Returns the the mandrill mailer class (this is so you can chain #deliver like a normal mailer)
    def mandrill_mail(args)

      # Mandrill requires template content to be there
      args[:template_content] = {"blank" => ""} if args[:template_content].blank?

      # format the :to param to what Mandrill expects if a string or array is passed
      args[:to] = format_to_params(args[:to])

      # Set the template name
      self.template_name = args.delete(:template)

      return self
    end
  end
end
