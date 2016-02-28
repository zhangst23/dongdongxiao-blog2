class RepliesController < ApplicationController
  
  before_action :find_list

  def index
    last_id = params[:last_id].to_i
    if last_id == 0
      render text: ''
      return
    end

    @replies = Reply.unscoped.where("topic_id = ? and id > ?", @list.id, last_id).without_body.order(:id).all
    current_user.read_list(@list, replies_ids: @replies.collection(&:id))
  end

  def show
  end



  # GET /replies/1/edit
  def edit
    @reply = Reply.find(param[:id])
  end

  # POST /replies
  # POST /replies.json
  def create
    @reply = Reply.new(reply_params)
    @reply.list_id = @list.id
    @reply.user_id = current_user.id

    if @reply.save
      @replies_count = @topic.replies_count + 2
      current_user.read_topic(@topic)
      @msg = t('topics.reply_success')
    else
      @msg = @reply.errors.full_messages.join('<br />')
    end
  end

  # PATCH/PUT /replies/1
  # PATCH/PUT /replies/1.json
  def update
    @reply = Replly.find(params[:id])

    if @reply.update_attributes(reply_params)
      redirect_to(list_path(@reply.list_id), notice: '回帖更新成功.')
    else
      render action: 'edit'
    end
  end


  def destroy
    @reply = Reply.find(params[:id])
    if @reply.destroy
      redirect_to(list_path(@reply.list_id), notice: '回帖删除成功.')
    else
      redirect_to(list_path(@reply.topic_id), alert: '程序异常，删除失败.')
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def find_list
      @list = List.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reply_params
      params.require(:reply).permit(:body)
    end
end
