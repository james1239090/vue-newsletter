require 'rails_helper'

RSpec.describe NewslettersController, type: :controller do
  describe "GET index" do
    it "assigns @newsletters" do
      newsletter1 = create(:newsletter)
      newsletter2 = create(:newsletter)

      get :index

      expect(assigns[:newsletters]).to eq([newsletter1, newsletter2])

    end

    it 'render template' do
      newsletter1 = create(:newsletter)
      newsletter2 = create(:newsletter)
      get :index
      expect(response).to render_template("index")
    end
  end
end
