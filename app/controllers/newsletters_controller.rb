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

  end

  def destroy

  end

  private
  def newsletter_params
    params.require(:newsletter).permit(:subject, :content)

  end
end
