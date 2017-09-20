class SendEmailService
  def initialize(newsletter)
    @newsletter = newsletter
    @sendState = false
  end

  def send_with_mailgun
    data = {}
    data[:from] = "SiteMinder <no-reply@mailgun.siteminder.com>"

    data[:to] = @newsletter.mail_to_list
    data[:cc] = @newsletter.mail_cc_list if @newsletter.mail_cc_list.length > 0
    data[:bcc] ||= @newsletter.mail_bcc_list if @newsletter.mail_bcc_list.length > 0
    data[:text] = @newsletter.content.gsub('\n', '\r\n')
    data[:subject] = @newsletter.subject
    # data["o:testmode"] = true
    puts "------------"
    puts data
    errors = {}
    begin
      res = RestClient.post "https://api:#{ENV['Mailgun_API_KEY']}"\
        "@api.mailgun.net/v3/#{ENV['Mailgun_Domain']}/messages", data
    rescue Exception => e
      case e.response.code
      when 500, 502, 503, 504
        if @sendState == false
          @sendState = true
          send_with_sendgrid
        else
          errors[:code] = e.response.code
          errors[:message] = "Mailgun and Sendgrid both of Service are failed"
          OpenStruct.new(errors)
        end
      else
        errors[:code] = e.response.code
        errors[:message] = "Sending Errors, please check the response code"
        puts "--------------"
        puts e.response
        OpenStruct.new(errors)
      end
    end
  end


  def send_with_sendgrid
    data = {}
    data[:to] = @newsletter.mail_to_list
    data[:cc] = @newsletter.mail_cc_list if @newsletter.mail_cc_list.length > 0
    data[:bcc] ||= @newsletter.mail_bcc_list if @newsletter.mail_bcc_list.length > 0
    data[:subject] = @newsletter.subject
    data[:text] = @newsletter.content.gsub('\n', '\r\n')
    data[:from] = "SiteMinder <no-reply@sendgrid.siteminder.com>"
    data[:api_user] = ENV['SENDGRID_API_USER']
    data[:api_key] = ENV['SENDGRID_API_KEY']
    errors = {}
    begin
      res = RestClient.post "https://api.sendgrid.com/api/mail.send.json", data
    rescue Exception => e
      case e.response.code
      when 500..599
        if @sendState == false
          @sendState = true
          send_with_mailgun
        else
          errors[:code] = e.response.code
          errors[:message] = "Mailgun and Sendgrid both of Service are failed"
          OpenStruct.new(errors)
        end
      else
        e
      end
    end
  end
end
