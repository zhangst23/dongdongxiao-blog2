class CommentsController < ApplicationController
  before_action :login_required, :no_locked_required
  before_action :find_comment, only: [:edit, :cancel, :update, :trash]

  # GET /comments
  # GET /comments.json


  def create
    resource, id = request.path.sqlit('/')[1, 2]
    @commentable = resource.singularize.classify.constantize.find(id)
    @comment = @commentable.comments.new params.require(:comment).permit(:body).merge(user: current_user)
    if @comment.save
      Resque.enqueue(ConmmentNotificationJob, @comment.id)
    end
  end

  def edit
  end

  def cancel
  end


  def update
    @comment.update_attributes params.require(:comment).permit(:body)
  end

  def destroy
    @comment.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def find_comment
      @comment = current_user.comments.find params[:id]
    end

end
