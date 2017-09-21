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
    data["o:testmode"] = true
    result = {}
    begin
      res = RestClient.post "https://api:#{ENV['Mailgun_API_KEY']}"\
        "@api.mailgun.net/v3/#{ENV['Mailgun_Domain']}/messages", data
      result[:code] = res.code
      result[:message]= "[Mailgun] Success Send Email with Mailgun"
      result
    rescue Exception => e
      case e.response.code
      when 500, 502, 503, 504
        if @sendState == false
          @sendState = true
          send_with_sendgrid
        else
          e.message = "[Mailgun] Server Errors - something is wrong on Mailgun’s end, Mailgun and Sendgrid both of Service are failed"
        end
      when 400
        e.message  = "[Mailgun] Bad Request - Often missing a required parameter"
      when 401
        e.message  = "[Mailgun] Unauthorized - No valid API key provided"
      when 402
        e.message = "[Mailgun] Request Failed - Parameters were valid but request failed"
      end
      e
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
    result = {}
    begin
      res = RestClient.post "https://api.sendgrid.com/api/mail.send.json", data
      if res.code == 200
        result[:code] = res.code
        result[:message]  = "[Sendgrid] Your message is valid, but it is not queued to be delivered."

      elsif res.code == 202
        result[:code] = res.code
        result[:message]  ="[Sendgrid] Your message is both valid, and queued to be delivered."
      end
      result
    rescue Exception => e
      case e.response.code
      when 500,503
        if @sendState == false
          @sendState = true
          send_with_mailgun
        else
          e.message = "[Sendgrid] The SendGrid v3 Web API is not available, Mailgun and Sendgrid both of Service are failed"
        end
      when 401
        e.message = "[Sendgrid] You do not have authorization to make the request."
      when 403
        e.message = "[Sendgrid] FORBIDDEN"
      when 404
        e.message = "[Sendgrid] The resource you tried to locate could not be found or does not exist."
      when 405
        e.message = "[Sendgrid] METHOD NOT ALLOWED"
      when 413
        e.message = "[Sendgrid] The JSON payload you have included in your request is too large."
      when 415
        e.message = "[Sendgrid] UNSUPPORTED MEDIA TYPE"
      when 429
        e.message = "[Sendgrid] The number of requests you have made exceeds SendGrid’s rate limitations"
      end
      e
    end
  end
end
