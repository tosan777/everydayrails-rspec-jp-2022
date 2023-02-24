require 'rails_helper'

RSpec.describe "ProjectsApis", type: :request do
  # 1件のプロジェクトを読み出すこと
  it 'loads a project' do
    user = FactoryBot.create(:user)
    FactoryBot.create(:project,
      name: "Sample Project")
    FactoryBot.create(:project,
      name: "Second Sample Project",
      owner: user)

    get api_projects_path, params: {
      user_email: user.email,
      user_token: user.authentication_token
    }

    expect(response).to have_http_status(:success)
    json = JSON.parse(response.body)
    expect(json.length).to eq 1
    project_id = json[0]["id"]

    get api_project_path(project_id), params: {
      user_email: user.email,
      user_token: user.authentication_token
    }

    expect(response).to have_http_status(:success)
    json = JSON.parse(response.body)
    expect(json["name"]).to eq "Second Sample Project" # などなど
  end

  # 認証済みのユーザーとして
  context "as an authenticated user" do
    before do
      @user = FactoryBot.create(:user)
    end

    # 有効な属性値の場合
    context "with valid attributes" do
      # プロジェクトを追加できること
      it "adds a project" do
        project_params = FactoryBot.attributes_for(:project)
        sign_in @user
        expect {
          post projects_path, params: { project: project_params }
        }.to change(@user.projects, :count).by(1)
      end

      # プロジェクトを更新できること
      it "update a project" do
        # プロジェクトの作成
        project = FactoryBot.create(:project, owner: @user)
        project_params = FactoryBot.attributes_for(:project, name: "Update Project")
        sign_in @user
        # プロジェクトの編集
        patch project_path(project.id), params: { project: project_params }
        expect(response).to have_http_status "302"
      end

      # プロジェクトを削除できること
      it "destroy a project" do
        # プロジェクトの作成
        project = FactoryBot.create(:project, owner: @user)
        sign_in @user
        # プロジェクトの削除
        expect {
          delete project_path(project.id), params: { id: project.id }
        }.to change(@user.projects, :count).by(-1)
      end
    end

    # 無効な属性値の場合
    context "with invalid attributes" do
      # プロジェクトを追加できないこと
      it "does not add a project" do
        project_params = FactoryBot.attributes_for(:project, :invalid)
        sign_in @user
        expect {
          post projects_path, params: { project: project_params }
        }.to_not change(@user.projects, :count)
      end

      # プロジェクトを更新できないこと
      it "does not update a project" do
        project = FactoryBot.create(:project, owner: @user)
        project_params = FactoryBot.attributes_for(:project, :invalid)
        sign_in @user
        patch project_path(@user.id), params: { project: project_params }
        expect(response).to have_http_status "422"
      end
    end
  end

  # 認証済みではないユーザーとして
  context "unauthenticated user" do
    before do
      @user = FactoryBot.create(:user)
    end

    # プロジェクトを追加できないこと
    it "does not add a project" do
      project_params = FactoryBot.attributes_for(:project)
      post projects_path, params: { project: project_params }
      expect(response).to have_http_status "302"
    end

    it "does not update a project" do
      project = FactoryBot.create(:project, owner: @user)
      project_params = FactoryBot.attributes_for(:project, name: "Update Project")
      patch project_path(project.id), params: { project: project_params }
      expect(response).to have_http_status "302"
    end

    it "does not destroy a project" do
      project = FactoryBot.create(:project, owner: @user)
      delete project_path(project.id)
      expect(response).to have_http_status "302"
    end
  end
end
