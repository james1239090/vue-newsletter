class NewslettersController < ApplicationController

  def index
    @newsletters = Newsletter.all
    respond_to do |format|
      format.html
      format.json { render json: @newsletters }
    end
  end

  def update

  end

  def create

  end

  def destroy

  end

end
