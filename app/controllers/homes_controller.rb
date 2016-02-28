class HomesController < ApplicationController
  before_action :set_home, only: [:show, :edit, :update, :destroy]

  def index
    @homes = Home.all
  end


  def lists
    @lists = List.all
  end


  def wiki
    @wiki = Wiki.all
  end

  def explore
    @explore = explore.all
  end
  

  private
    




end
