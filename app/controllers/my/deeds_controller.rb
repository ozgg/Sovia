class My::DeedsController < ApplicationController
  before_action :allow_authorized_only

  def index
    page   = params[:page] || 1
    @title = t('controllers.my.deeds.index', page: page)
    @deeds = current_user.deeds.page(page).per(20)
  end
end