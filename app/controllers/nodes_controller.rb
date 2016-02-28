class NodesController < ApplicationController
  before_action :require_node, only: [:block, :unblock]


  def index
    @nodes = Node.all
    render json: @nodes, only: [:name], methods: [:id]
  end

  def block
    current_user.block_node(params[:id])
    render json: { code: 0 }
  end

  def unblock
    current_user.unblock_node(params[:id])
    render json: { code: 0 }
  end
end