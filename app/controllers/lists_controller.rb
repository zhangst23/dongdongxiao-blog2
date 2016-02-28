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



  # GET /lists/1
  # GET /lists/1.json
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
