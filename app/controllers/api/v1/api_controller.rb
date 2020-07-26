class Api::V1::ApiController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  def current_user
    @current_user ||= User.first
  end
end
