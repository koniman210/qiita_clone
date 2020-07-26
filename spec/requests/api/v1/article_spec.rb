require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /api/v1/articles" do
    subject { get(api_v1_articles_path )}

    before do
      create_list(:article, 3)
    end
    it "記事の一覧が取得できる" do
      subject
      res = JSON.parse(response.body)
      expect(res.length).to eq 3
      expect(res[0].keys).to eq ["id","title","body","user"]
      expect(res[0]["user"].keys).to eq ["id","name"]
      expect(response).to have_http_status(200)
    end
  end
  describe "GET /api/v1/article/:id" do
    subject{get(api_v1_article_path(article_id))}
    context "指定した記事の詳細がある場合"do
      let(:article){create(:article)}
      let(:article_id){article.id}
      
      it "記事の詳細が見れる" do
        subject
        res = JSON.parse(response.body)
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"]["name"]).to eq article.user.name
        expect(response).to have_http_status(200)
      end
    end
  end
  describe "POST /api/v1/articles" do
    subject{post(api_v1_articles_path, params: params)}
      let(:params){{article: attributes_for(:article)}}
      let(:current_user){create(:user)}
      before do
        allow_any_instance_of(Api::V1::ApiController).to receive(:current_user).and_return(current_user)
      end  
      it  "記事が作成できる" do
        expect{ subject }.to change{current_user.articles.count}.by(1)
        res = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
      end
  end

  describe "PATCH /api/v1/articles/:id" do
    subject{patch(api_v1_article_path(article.id),params: params)}
    let(:params){{article: attributes_for(:article)}}
    let(:article){create(:article, user: current_user)}
    let(:current_user){create(:user)}
    before do
      allow_any_instance_of(Api::V1::ApiController).to receive(:current_user).and_return(current_user)
    end  
    it "記事の更新ができる" do
      
      expect{subject}.to change{article.reload.title}.from(article.title).to(params[:article][:title]) &
      change{article.reload.body}.from(article.body).to(params[:article][:body]) &
      not_change{article.reload.created_at}
      expect(response).to have_http_status(200)
    end
    context "他のuserの記事を更新しようとるすとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }

      it "更新できない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
  describe "DELETE /api/v1/articles/:id" do
    subject{delete(api_v1_article_path(article.id),params: params)}
    let(:params){attributes_for(:article)}
    let!(:article){create(:article, user: current_user)}
    let(:current_user){create(:user)}
    before do
      allow_any_instance_of(Api::V1::ApiController).to receive(:current_user).and_return(current_user)
    end  
    it "記事の削除ができる" do
      expect{subject}.to change{current_user.articles.count}.by(-1)
      binding.pry
      expect(response).to have_http_status(:ok)
    end
  end
end
