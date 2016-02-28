class ListsController < ApplicationController
  before_action :login_required, :no_locked_required, except: [:index, :show, :search]
  before_action :find_list, only: [:edit, :update, :trash]
  before_action :set_list, only: [:show, :edit, :update, :destroy]

  # GET /lists
  # GET /lists.json
  def index
    @lists = List.includes(:user, :category).page(params[:page])

    if params[:category_id]
      @category = Category.where('lower(slug) = ?', params[:category_id].downcase).first!
      @lists = @lists.where(category: @category)
    end

    # Set default tab
    unless %w(newest excellent).includes? params[:tab]
      params[:tab] = 'newest'
    end

    case params[:tab]
    when 'newest'
      @lists = @lists.order(hot: :desc)
    when 'excellent'
      @lists = @lists.order(id: :desc)
    end
  end

  def search
    @lists = List.search(
      query: {
        multi_match: {
          query: params[:q].to_s,
          fields: ['title', 'body']
        }
      },
      filter: {
        term: {
          trashed: false
        }
      }
    ).page(params[:page]).records
  end

  def feed
    @lists = List.without_hide_nodes.recent.without_body.limit(20).include(:node, :user, :last_reply_user)
    render layout: false
  end

  def node
    @node = Node.find(params[:id])
    @lists = @node.lists.last_actived.fields_for_list
    @lists = @lists.includes(:user).piginate(page: params[:page], per_page: 25)
    set_seo_meta title, "#{Setting.app_name}#{'menu.lists'}#{@node.name}", @node.summary
    render action: 'index'
  end

  def node_feed
    @node = Node.find(params[:id])
    @lists = @node.lists.recent.without_body.limit(20)
    render layout: false
  end

  %w(no_reply popular).each do |name|
    define_method(name) do
      @lists = List.without_hide_nodes.send(name.to_sym).last_actived.fields_for_list.includes(:user)
      @lists = @lists.paginate(page: params[:page], per_page: 25, total_entries: 1500)

      set_seo_meta [t("lists.list_list.#{name}"), t('menu.topics')].join(' &raquo; ')
      render action: 'index'
    end
  end

  def recent
    @lists = List.without_hide_nodes.recent.fields_for_list.includes(:user)
    @lists = @lists.paginate(page: params[:page], per_page: 25, total_entries: 1500)
    set_seo_meta [t('topics.topic_list.recent'), t('menu.topics')].join(' &raquo; ')
    render action: 'index'
  end

  def excellent
    @lists = List.excellent.recent.fields_for_list.includes(:user)
    @lists = @lists.paginate(page: params[:page], per_page: 25, total_entries: 1500)

    set_seo_meta [t('topics.topic_list.excellent'), t('menu.topics')].join(' &raquo; ')
    render action: 'index'
  end




  def show
    @list = List.find params[:id]

    if params[:comment_id] and comment = @list.comments.find_by(id: params.delete(:comment_id))
      params[:page] = comment.page
    end

    @comments = @list.comments.includes(:user).order(id: :asc).page(params[:page])

    respond_to do |format|
      format.html
    end
  end

  # GET /lists/new
  def new
    @category = Category.where('lower(slug) = ?', params[:category_id].downcase).first if params[:category_id].present?
    @list = List.new category: @category
  end

  # GET /lists/1/edit
  def edit

  end

  # POST /lists
  # POST /lists.json
  def create
    @list = current_user.topics.create list_params
  end

  # PATCH/PUT /lists/1
  # PATCH/PUT /lists/1.json
  def update
    @list.update_attributes list_params
  end

  # DELETE /lists/1
  # DELETE /lists/1.json
  def destroy
    @list.destroy
    redirect_via_turbolinks_to lists_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def find_list
      @list = current_user.lists.find params[:id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def list_params
      params.require(:list).permit(:title, :category_id, :body)
    end
end
