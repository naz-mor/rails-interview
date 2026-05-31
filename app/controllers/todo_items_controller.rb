class TodoItemsController < App::ApplicationController
  before_action :set_todo_list

  def index
    @todo_items = paginate(@todo_list.todo_items)

    respond_to do |format|
      format.html { render partial: "todo_items/todo_item", collection: @todo_items, locals: { todo_list: @todo_list } }
    end
  end

  def create
    @todo_item = @todo_list.todo_items.build(todo_item_params)

    if @todo_item.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_todo_list_path(@todo_list), notice: 'Todo item created successfully.' }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @todo_item = @todo_list.todo_items.find(params.require(:id))

    if @todo_item.update(todo_item_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_todo_list_path(@todo_list), notice: 'Todo item updated successfully.' }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @todo_item = @todo_list.todo_items.find(params.require(:id))
    @todo_item.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to edit_todo_list_path(@todo_list), notice: 'Todo item deleted successfully.' }
    end
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params.require(:todo_list_id))
  end

  def todo_item_params
    params.require(:todo_item).permit(:name, :completed)
  end
end
