# frozen_string_literal: true

# Administrative part of dream patterns management
class Admin::PatternsController < AdminController
  include ToggleableEntity

  before_action :set_entity, except: :index

  # get /admin/patterns
  def index
    @collection = Pattern.page_for_administration(current_page)
  end

  # get /admin/patterns/:id
  def show
  end

  private

  def component_class
    Biovision::Components::DreambookComponent
  end

  def set_entity
    @entity = Pattern.find_by(id: params[:id])
    handle_http_404('Cannot find pattern') if @entity.nil?
  end
end
