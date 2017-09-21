class NewslettersController < ApplicationController

  def index
    @newsletters = Newsletter.all
    respond_to do |format|
      format.html
      format.json { render json: @newsletters }
    end
  end


  def create
    @newsletter = Newsletter.new(newsletter_params)

    respond_to do |format|
      if @newsletter.save
        format.json { render json: @newsletter }
      else
        format.html { render :new }
        format.json { render json: @newsletter.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    @newsletter = Newsletter.find(params[:id])
    respond_to do |format|
      if @newsletter.update(newsletter_params)
        format.json { render json: @newsletter }
      else
        format.html { render :edit }
        format.json { render json: @newsletter.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @newsletter = Newsletter.find(params[:id])
    respond_to do |format|
      if @newsletter.destroy
        format.json { render json: @newsletter }
      else
        format.json { render json: @newsletter.errors, status: :unprocessable_entity }
      end
    end
  end

  def sendWithMailgun
    @newsletter = Newsletter.find(params[:id])
    res= SendEmailService.new(@newsletter).send_with_mailgun
    respond_to do |format|
      if !defined?(res.response)
        format.json { render json: res }
      else
        format.json { render json: res , :status => res.response.code}
      end
    end
  end

  def sendWithSendgrid
    @newsletter = Newsletter.find(params[:id])
    res = SendEmailService.new(@newsletter).send_with_sendgrid

    respond_to do |format|
      if !defined?(res.response)
        format.json { render json: res }
      else
        format.json { render json: res , :status => res.response.code}
      end
    end
  end

  def sendEmail
    @newsletter = Newsletter.find(params[:id])
    res = SendEmailService.new(@newsletter).send_with_sendgrid

    respond_to do |format|
      if !defined?(res.response)
        format.json { render json: res }
      else
        format.json { render json: res , :status => res.response.code}
      end
    end
  end

  private
  def newsletter_params
    params.require(:newsletter).permit(:subject, :content, :mail_to_list => [], :mail_cc_list => [], :mail_bcc_list => [])
  end
end
