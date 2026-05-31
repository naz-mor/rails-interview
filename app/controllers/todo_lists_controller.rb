class TodoListsController < App::ApplicationController
  before_action :set_todo_list, only: %i[edit update destroy]

  # GET /todolists
  def index
    @todo_lists = TodoList.all
  end

  # POST /todolists
  def create
    @todo_list = TodoList.new(todo_list_params)

    render :new, status: :unprocessable_entity unless @todo_list.save
  end

  # GET /todolists/:id/edit
  def edit
    @todo_item = @todo_list.todo_items.build
  end

  # PATCH/PUT /todolists/:id
  def update
    if @todo_list.update(todo_list_params)
      redirect_to todo_lists_path
    else
      @todo_item = @todo_list.todo_items.build
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /todolists/:id
  def destroy
    @todo_list.destroy
    redirect_to todo_lists_path
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params.require(:id))
  end

  def todo_list_params
    params.require(:todo_list).permit(
      :name,
      todo_items_attributes: %i[id name completed _destroy]
    )
  end
end
