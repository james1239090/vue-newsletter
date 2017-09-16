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

  describe "POST create" do
    it "create a new newsletter " do
    newsletter = build(:newsletter)

    expect do
      post :create, params: { :newsletter => attributes_for(:newsletter) }, format: :json
    end.to change{ Newsletter.count }.by(1)
  end

  end
end
