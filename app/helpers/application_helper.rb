module ApplicationHelper
  def back_navigation_path(fallback: todo_lists_path)
    return fallback if request.referer.blank?

    referrer_uri = URI.parse(request.referer)
    return fallback unless same_host_referrer?(referrer_uri)

    referrer_request_uri(referrer_uri).presence || fallback
  rescue URI::InvalidURIError
    fallback
  end

  private

  def same_host_referrer?(referrer_uri)
    return true if referrer_uri.host.blank?

    referrer_uri.host == request.host && referrer_uri.port == request.port
  end

  def referrer_request_uri(referrer_uri)
    return referrer_uri.request_uri if referrer_uri.respond_to?(:request_uri)

    referrer_uri.to_s
  end
end
