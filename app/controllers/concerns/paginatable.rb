module Paginatable
  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 10

  private

  def paginate(scope)
    scope.offset((current_page - 1) * per_page).limit(per_page)
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
