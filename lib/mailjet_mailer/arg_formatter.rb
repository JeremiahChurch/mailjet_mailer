require 'base64'

module MailjetMailer
  class ArgFormatter
    ACCEPTED_MERGE_LANGUAGES = ['mailchimp', 'handlebars'].freeze

    def self.attachment_args(args)
      return unless args
      args.map do |attachment|
        attachment.symbolize_keys!
        type = attachment[:mimetype] || attachment[:type]
        name = attachment[:filename] || attachment[:name]
        file = attachment[:file] || attachment[:content]
        {"Content-Type" => type, "Filename" => name, "content" => Base64.encode64(file)}.compact
      end
    end

    def self.images_args(args)
      return unless args
      attachment_args(args).compact
    end

    # convert a normal hash into the format mailjet needs
    def self.mailjet_args(args)
      return [] unless args
      args.map do |k,v|
        {'name' => k, 'content' => v}.compact
      end
    end

    def self.rcpt_metadata(args)
      return [] unless args
      args.map do |item|
        rcpt = item.keys[0]
        {'rcpt' => rcpt, 'values' => item.fetch(rcpt)}.compact
      end
    end

    # ensure only true or false is returned given arg
    def self.boolean(arg)
      !!arg
    end

    # handle if to params is an array of either hashes or strings or the single string
    def self.params(to_params)
      if to_params.kind_of? Array
        to_params.map do |p|
          params_item(p)
        end
      else
        [params_item(to_params)]
      end
    end

    # single to params item
    def self.params_item(item)
      if item.kind_of? Hash
        item.compact # remove empty hashes so mailjet api doesn't complain
       else
         {"email": item, "name": item}.compact
      end
    end

    def self.format_messages_api_message_data(args, defaults)
      # If a merge_language attribute is given and it's not one of the accepted
      # languages Raise an error
      if args[:merge_language] && !ACCEPTED_MERGE_LANGUAGES.include?(args[:merge_language])
        raise MailjetMailer::CoreMailer::InvalidMergeLanguageError.new("The :merge_language value `#{args[:merge_language]}`is invalid, value must be one of: #{ACCEPTED_MERGE_LANGUAGES.join(', ')}.")
      end

      {
        "html": args[:html],
        "text": args[:text],
        "subject": args[:subject],
        "from": args[:from] || defaults[:from],
        "from_email": args[:from_email] || args[:from] || defaults[:from],
        "from_name": args[:from_name] || defaults[:from_name] || defaults[:from],
        "recipients": params(args[:to]),
        "cc": args[:cc],
        "bcc": args[:bcc],
        "headers": args[:headers],
        "Mj-TemplateID": args[:template],
        "Mj-TemplateLanguage": args[:template].presence ? true : nil,
        # "important": boolean(args[:important]),
        "mj-trackopen": args.fetch(:track_opens, true),
        "mj-trackclick": boolean(args.fetch(:track_clicks, true)),
        # "auto_text": boolean(args.fetch(:auto_text, true)),
        # "auto_html": boolean(args[:auto_html]),
        # "inline_css": boolean(args[:inline_css]),
        # "url_strip_qs": boolean(args.fetch(:url_strip_qs, true)),
        # "preserve_recipients": boolean(args[:preserve_recipients]),
        # "view_content_link": boolean(args[:view_content_link] || defaults[:view_content_link]),
        # "tracking_domain": args[:tracking_domain],
        # "signing_domain": args[:signing_domain],
        # "return_path_domain": args[:return_path_domain],
        # "merge": boolean(args[:merge]),
        # "merge_language": args[:merge_language],
        # "global_merge_vars": mailjet_args(args[:vars] || args[:global_merge_vars] || defaults[:merge_vars]),
        "vars": args[:vars].presence ? args[:vars].compact : nil,
        # "tags": args[:tags],
        # "subaccount": args[:subaccount],
        # "google_analytics_domains": args[:google_analytics_domains],
        # "google_analytics_campaign": args[:google_analytics_campaign],
        # "metadata": args[:metadata],
        # "recipient_metadata": args[:recipient_metadata],
        "attachments": attachment_args(args[:attachments]),
        "inline_attachments": images_args(args[:images])
      }.compact
    end
  end
end
