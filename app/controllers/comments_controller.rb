class CommentsController < ApplicationController
  def new
  end

  def create
    @comment = Comment.new(comment_params)
    check_rights
    if suspect_spam?(@comment.user, @comment.body)
      redirect_with_confirmation
    else
      save_comment
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :entry_id).merge(user: current_user)
  end

  def check_rights
    entry = @comment.entry
    raise ForbiddenException unless entry.nil? || entry.visible_to?(current_user)
  end

  def save_comment
    if @comment.save
      Comments.entry_reply(@comment).send if @comment.notify_entry_owner?
      redirect_with_confirmation
    else
      render action: :new
    end
  end

  def redirect_with_confirmation
    flash[:notice] = t('comment.created')
    redirect_to view_context.verbose_entry_path(@comment.entry)
  end
end