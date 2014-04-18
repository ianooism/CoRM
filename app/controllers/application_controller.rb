# encoding: utf-8

##
# Main Controller (for protected pages)
#
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  
  before_filter :getAbility
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_url, :alert => exception.message
  end

  private
  def getAbility
    @ability = Ability.new(current_user)
  end
  
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_url
  end
end
