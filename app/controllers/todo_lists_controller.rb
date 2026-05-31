class TodoListsController < App::ApplicationController
  before_action :set_todo_list, only: %i[edit update destroy]

  # GET /todolists
  def index
    @todo_lists = paginate(TodoList.ordered_by_recently_updated)

    respond_to do |format|
      format.html do
        if turbo_frame_request?
          render partial: "todo_lists/page", locals: pagination_locals.merge(todo_lists: @todo_lists)
        end
      end
    end
  end

  # POST /todolists
  def create
    @todo_list = TodoList.new(todo_list_create_params)

    if @todo_list.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to todo_lists_path, notice: 'Todo list created successfully.' }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /todolists/:id/edit
  def edit
    @todo_items = paginate(@todo_list.todo_items)
  end

  # PATCH/PUT /todolists/:id
  def update
    if @todo_list.update(todo_list_params)
      redirect_to todo_lists_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /todolists/:id
  def destroy
    @todo_list.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to todo_lists_path }
    end
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params.require(:id))
  end

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end

  def todo_list_create_params
    params.require(:todo_list).permit(
      :name,
      todo_items_attributes: %i[name completed]
    )
  end

  def pagination_locals
    { page: @current_page, next_page: @next_page, per_page: @per_page }
  end
end
