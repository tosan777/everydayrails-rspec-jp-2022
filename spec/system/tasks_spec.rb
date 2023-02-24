require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  # ユーザーがタスクの状態を切り替える
  scenario "user toggles a task", js: true do
    user = FactoryBot.create(:user)
    project = FactoryBot.create(:project,
                                name: "RSpec tutorial",
                                owner: user)
    task = project.tasks.create!(name: "Finish RSpec tutorial")

    visit root_path
    click_link "Sign in"
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    click_link "RSpec tutorial"
    check "Finish RSpec tutorial"

    expect(page).to have_css "label#task_#{task.id}.completed"
    expect(task.reload).to be_completed

    uncheck "Finish RSpec tutorial"
    expect(page).to_not have_css "label#task_#{task.id}.completed"
    expect(task.reload).to_not be_completed
  end

  # ユーザーがタスクを作成する
  scenario "user create task" do
    user = FactoryBot.create(:user)
    project = FactoryBot.create(:project, owner: user)

    visit root_path
    click_link "Sign in"
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    expect {
      click_link "Project 1"
      click_link "Add Task"
      fill_in "task[name]", with: "meeting"
      click_button "Create Task"
      expect(page).to have_content "Task was successfully created."
      expect(page).to have_content "meeting"
    }.to change(project.tasks, :count).by(1)
  end

  # ユーザーがタスクを削除する
  scenario "user destroy task", js: true do
    user = FactoryBot.create(:user)
    project = FactoryBot.create(:project, owner: user)
    task = project.tasks.create(name: 'タスク')

    visit root_path
    click_link "Sign in"
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    expect {
      click_link "Project 2"
      click_link "Delete"
      expect(page.accept_confirm).to eq "Are you sure?"
      expect(page).to have_content "Task was successfully destroyed."
    }.to change(project.tasks, :count).by(-1)
  end
end
