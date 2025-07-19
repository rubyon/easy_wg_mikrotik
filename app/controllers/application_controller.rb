class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale

  private
  def set_locale
    if session[:locale].present? && I18n.available_locales.include?(session[:locale].to_sym)
      I18n.locale = session[:locale]
    else
      I18n.locale = I18n.default_locale
    end
  end
end
