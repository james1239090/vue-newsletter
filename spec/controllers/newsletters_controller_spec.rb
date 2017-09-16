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
    context "when newsletter has subject" do
      it "create a new newsletter " do
        newsletter = build(:newsletter)

        expect do
          post :create, params: { :newsletter => attributes_for(:newsletter) }, format: :json
        end.to change{ Newsletter.count }.by(1)
      end
    end

    context "when newsletter doesn't have subject or contnet" do
      it "doesn't create a record without subject" do
        expect do
          post :create, params: { newsletter: { :content => "bar" }}, format: :json
        end.to change { Newsletter.count }.by(0)
      end
      it "doesn't create a record without content" do
        expect do
          post :create, params: { newsletter: { :subject => "foo" }}, format: :json
        end.to change { Newsletter.count }.by(0)
      end
      it "doesn't create a record without subject and content" do
        expect do
          post :create, params: { newsletter: { :subject => "", :conent => "" }}, format: :json
        end.to change { Newsletter.count }.by(0)
      end
    end

  end

  describe "PUT update" do
    context "when newsletter has subject" do
      it "assign @newsletter" do
        newsletter = create(:newsletter)

        put :update , params: { id: newsletter.id, newsletter: { subject: "Subject", content: "Content" } }, format: :json

        expect(assigns[:newsletter]).to eq(newsletter)
      end
      it "changes value" do
        newsletter = create(:newsletter)

        put :update , params: { id: newsletter.id, newsletter: { subject: "UpdateSubject", content: "UpdateContent" } }, format: :json

        expect(assigns[:newsletter].subject).to eq("UpdateSubject")
        expect(assigns[:newsletter].content).to eq("UpdateContent")
      end
    end

    context "when newsletter doesn't have subject or contnet" do
      it "doesn't update a record without subject" do
        newsletter = create(:newsletter)

        put :update , params: { id: newsletter.id, newsletter: { subject: "", content: "UpdateContent" } }, format: :json

        expect(newsletter.subject).not_to eq("UpdateContent")
      end
      it "doesn't update a record without content" do
        newsletter = create(:newsletter)

        put :update , params: { id: newsletter.id, newsletter: { subject: "UpdateSubject", content: "" } }, format: :json

        expect(newsletter.subject).not_to eq("UpdateSubject")
      end
      it "doesn't update a record without content and subject" do
        newsletter = create(:newsletter)

        put :update , params: { id: newsletter.id, newsletter: { subject: "", content: "" } }, format: :json

        expect(newsletter.subject).not_to eq("")
        expect(newsletter.content).not_to eq("")
      end
    end

  end

end
