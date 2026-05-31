module Paginatable
  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 10

  private

  def paginate(scope)
    @current_page = current_page
    @per_page = per_page

    records = scope.offset((@current_page - 1) * @per_page).limit(@per_page + 1).to_a
    @next_page = if records.size > @per_page
      @current_page + 1
    end

    records.first(@per_page)
  end

  def current_page
    positive_integer_param(:page, DEFAULT_PAGE)
  end

  def per_page
    positive_integer_param(:per_page, DEFAULT_PER_PAGE)
  end

  def positive_integer_param(name, default)
    value = Integer(params[name])
    value.positive? ? value : default
  rescue ArgumentError, TypeError
    default
  end
end
