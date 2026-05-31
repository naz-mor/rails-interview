require 'rails_helper'

RSpec.describe 'Todo lists', type: :system do
  before do
    driven_by(:rack_test)
  end

  def add_list(name)
    find("input[placeholder='Add your list…']").set(name)
    click_button 'Add todo list'
  end

  def add_task(name)
    find("input[placeholder='Add your task…']").set(name)
    click_button 'Add task'
  end

  def click_delete(name)
    find(:xpath, ".//img[@alt='Delete #{name}']/ancestor::button").click
  end

  def click_complete_task(name)
    find(:xpath, ".//span[@aria-label='Mark #{name} complete']/ancestor::button").click
  end

  def click_complete_all
    find(:xpath, ".//span[@aria-label='Complete all tasks']/ancestor::button").click
  end

  def begin_editing_list_name(name)
    find("a[aria-label='Edit #{name} name']").click
  end

  def set_list_name(name)
    find("input[name='todo_list[name]']").set(name)
  end

  describe 'index page' do
    it 'shows the no lists empty state' do
      visit todo_lists_path

      expect(page).to have_css('h1', text: 'Todo Lists')
      expect(page).to have_css("a.back-navigation__link[aria-label='Go back'][href='#{todo_lists_path}']", text: '←')
      expect(page).to have_text('No lists have been entered yet')
    end

    it 'lists todo lists and paginates them' do
      12.times { |index| TodoList.create!(name: format('List %02d', index)) }

      visit todo_lists_path(per_page: 5)

      expect(page).to have_link('List 00')
      expect(page).to have_link('List 04')
      expect(page).to have_no_link('List 05')
      expect(page).to have_css('turbo-frame#todo_lists_page_2')

      visit todo_lists_path(page: 2, per_page: 5)

      expect(page).to have_link('List 05')
      expect(page).to have_link('List 09')
      expect(page).to have_no_link('List 04')
      expect(page).to have_no_link('List 10')
    end

    it 'adds a list and shows it in the index' do
      visit todo_lists_path

      expect { add_list('Weekend Chores') }.to change(TodoList, :count).by(1)
      expect(page).to have_current_path(todo_lists_path)
      expect(page).to have_link('Weekend Chores')
      expect(page).to have_no_text('No lists have been entered yet')
    end

    it 'shows validation errors when adding a list without a name' do
      visit todo_lists_path

      expect { click_button 'Add todo list' }.not_to change(TodoList, :count)
      expect(page).to have_text("Name can't be blank")
    end

    it 'destroys a list' do
      TodoList.create!(name: 'Errands')
      TodoList.create!(name: 'Work')

      visit todo_lists_path

      expect { click_delete('Errands') }.to change(TodoList, :count).by(-1)
      expect(page).to have_no_link('Errands')
      expect(page).to have_link('Work')
    end
  end

  describe 'edit page' do
    it 'shows the list name and no items empty state' do
      todo_list = TodoList.create!(name: 'Project Tasks')

      visit edit_todo_list_path(todo_list)

      expect(page).to have_css('h1', text: 'Project Tasks')
      expect(page).to have_css("a.back-navigation__link[aria-label='Go back'][href='#{todo_lists_path}']", text: '←')
      expect(page).to have_text('No tasks have been entered yet')
      expect(page).to have_css("form[action='#{todo_list_todo_items_path(todo_list)}']")
    end

    it 'allows returning to the todo lists index from a directly visited edit page' do
      todo_list = TodoList.create!(name: 'Project Tasks')

      visit edit_todo_list_path(todo_list)
      find("a.back-navigation__link[aria-label='Go back']").click

      expect(page).to have_current_path(todo_lists_path)
      expect(page).to have_css('h1', text: 'Todo Lists')
    end

    it 'shows a back link when navigated from the list index' do
      todo_list = TodoList.create!(name: 'Project Tasks')

      visit todo_lists_path
      click_link 'Project Tasks'

      expect(page).to have_css("a.back-navigation__link[aria-label='Go back'][href='#{todo_lists_path}']", text: '←')
    end

    it 'adds a task and shows it in the list' do
      todo_list = TodoList.create!(name: 'Project Tasks')

      visit edit_todo_list_path(todo_list)

      expect { add_task('Draft proposal') }.to change(TodoItem, :count).by(1)
      expect(page).to have_current_path(edit_todo_list_path(todo_list))
      expect(page).to have_text('Draft proposal')
      expect(page).to have_no_text('No tasks have been entered yet')
    end

    it 'cancels editing the list name' do
      todo_list = TodoList.create!(name: 'Project Tasks')

      visit edit_todo_list_path(todo_list)
      begin_editing_list_name('Project Tasks')
      set_list_name('Renamed Project Tasks')
      click_link 'Cancel'

      expect(todo_list.reload.name).to eq('Project Tasks')
      expect(page).to have_current_path(edit_todo_list_path(todo_list))
      expect(page).to have_css('h1', text: 'Project Tasks')
      expect(page).to have_no_css('.todo-list-name-form')
    end

    it 'shows validation errors when editing the list name' do
      todo_list = TodoList.create!(name: 'Project Tasks')

      visit edit_todo_list_path(todo_list)
      begin_editing_list_name('Project Tasks')
      set_list_name('')
      click_button 'Save'

      expect(todo_list.reload.name).to eq('Project Tasks')
      expect(page).to have_text("Name can't be blank")
      expect(page).to have_css('.todo-list-name-form')
    end

    it 'saves edits to the list name' do
      todo_list = TodoList.create!(name: 'Project Tasks')

      visit edit_todo_list_path(todo_list)
      begin_editing_list_name('Project Tasks')
      set_list_name('Renamed Project Tasks')
      click_button 'Save'

      expect(todo_list.reload.name).to eq('Renamed Project Tasks')
      expect(page).to have_css('h1', text: 'Renamed Project Tasks')
      expect(page).to have_no_css('.todo-list-name-form')
    end

    it 'shows validation errors when adding a task without a name' do
      todo_list = TodoList.create!(name: 'Project Tasks')

      visit edit_todo_list_path(todo_list)

      expect { click_button 'Add task' }.not_to change(TodoItem, :count)
      expect(page).to have_text("Name can't be blank")
    end

    it 'paginates tasks' do
      todo_list = TodoList.create!(name: 'Project Tasks')
      12.times { |index| todo_list.todo_items.create!(name: format('Task %02d', index)) }

      visit edit_todo_list_path(todo_list, per_page: 5)

      expect(page).to have_text('Task 11')
      expect(page).to have_text('Task 07')
      expect(page).to have_no_text('Task 06')
      expect(page).to have_css('turbo-frame#todo_items_page_2')

      visit edit_todo_list_path(todo_list, page: 2, per_page: 5)

      expect(page).to have_text('Task 06')
      expect(page).to have_text('Task 02')
      expect(page).to have_no_text('Task 07')
      expect(page).to have_no_text('Task 01')
    end

    it 'completes all existing tasks' do
      todo_list = TodoList.create!(name: 'Project Tasks')
      todo_list.todo_items.create!(name: 'First task')
      todo_list.todo_items.create!(name: 'Second task')

      visit edit_todo_list_path(todo_list)
      click_complete_all

      expect(todo_list.todo_items.reload).to all(be_completed)
      expect(page).to have_css("img[alt='All tasks completed']")
    end

    it 'completes an individual task' do
      todo_list = TodoList.create!(name: 'Project Tasks')
      todo_item = todo_list.todo_items.create!(name: 'Buy milk')

      visit edit_todo_list_path(todo_list)
      click_complete_task('Buy milk')

      expect(todo_item.reload).to be_completed
      expect(find("#todo_item_#{todo_item.id} .todo-row__text")[:class]).to include('todo-row__text--completed')
      expect(page).to have_css("img[alt='Mark Buy milk incomplete']")
    end

    it 'destroys a task' do
      todo_list = TodoList.create!(name: 'Project Tasks')
      todo_list.todo_items.create!(name: 'Keep me')
      todo_list.todo_items.create!(name: 'Delete me')

      visit edit_todo_list_path(todo_list)

      expect { click_delete('Delete me') }.to change(TodoItem, :count).by(-1)
      expect(page).to have_no_text('Delete me')
      expect(page).to have_text('Keep me')
    end
  end
end
