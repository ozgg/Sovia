class PostsController < ApplicationController
  before_action :restrict_anonymous_access, except: [:index, :show, :tagged]
  before_action :set_entity, only: [:show, :edit, :update, :destroy]
  before_action :restrict_editing, only: [:edit, :update, :destroy]

  def index
    if current_user_has_role? :administrator
      @collection = Post.in_languages(visitor_languages).order('id desc').page(current_page).per(5)
    else
      @collection = Post.in_languages(visitor_languages).visible.order('id desc').page(current_page).per(5)
    end
  end

  def new
    @entity = Post.new
  end

  def create
    @entity = Post.new creation_parameters
    if @entity.save
      set_tags
      redirect_to @entity, notice: t('posts.create.success')
    else
      render :new
    end
  end

  def show

  end

  def edit

  end

  def update
    if @entity.update entity_parameters
      set_tags
      redirect_to @entity, notice: t('posts.update.success')
    else
      render :edit
    end
  end

  def destroy
    if @entity.destroy
      flash[:notice] = t('posts.destroy.success')
    end
    redirect_to posts_path
  end

  def tagged

  end

  protected

  def restrict_editing
    raise UnauthorizedException unless @entity.editable_by? current_user
  end

  def set_entity
    @entity = Post.find params[:id]
  end

  def entity_parameters
    parameters = params.require(:post).permit(:show_in_list, :title, :image, :lead, :body)
    parameters.reject!(:show_in_list) if parameters.include?(:show_in_list) && !current_user_has_role?(:administrator)
    parameters
  end

  def creation_parameters
    entity_parameters.merge(owner_for_entity).merge(language_for_entity).merge(tracking_for_entity)
  end

  def set_tags
    @entity.tags_string = params.require(:post).permit(:tags_string).to_s
    @entity.cache_tags!
  end
end
