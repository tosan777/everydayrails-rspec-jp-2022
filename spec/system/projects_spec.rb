require 'rails_helper'

RSpec.describe "Projects", type: :system do
  # ユーザーは新しいプロジェクトを作成する
  scenario "user creates a new project" do
    user = FactoryBot.create(:user)

    visit root_path
    click_link "Sign in"
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    expect {
      click_link "New Project"
      fill_in "Name", with: "Test Project"
      fill_in "Description", with: "Trying out Capybara"
      click_button "Create Project"

      expect(page).to have_content "Project was successfully created"
      expect(page).to have_content "Test Project"
      expect(page).to have_content "Owner: #{user.name}"
    }.to change(user.projects, :count).by(1)
  end

  # プロジェクトの作成に失敗
  scenario "user project creation failed" do
    user = FactoryBot.create(:user)

    visit root_path
    click_link "Sign in"
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    click_link "New Project"
    fill_in "Name", with: nil
    fill_in "Description", with: "backend"
    click_button "Create Project"

    expect(page).to have_content "1 error prohibited this project from being saved:"
    expect(page).to have_content "Name can't be blank"
  end

  # プロジェクトの編集に成功
  scenario "user project updating failed" do
    user = FactoryBot.create(:user)
    project = FactoryBot.create(:project, owner: user)

    visit root_path
    click_link "Sign in"
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    click_link "Project 1"
    click_link "Edit"
    fill_in "project[name]", with: "update project"
    fill_in "project[description]", with: "backend"
    click_button "Update Project"

    expect(page).to have_content "Project was successfully updated."
    expect(page).to have_content "update project"
  end
end
