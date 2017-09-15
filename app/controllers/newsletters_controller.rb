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

  private
  def newsletter_params
    params.require(:newsletter).permit(:subject, :content)

  end
end
