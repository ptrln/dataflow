class DatabasesController < ApplicationController

  def index
  end

  def new
    @database = Database.new
  end

  def create
    @database = Database.new(params[:database])
    if @database.save
      redirect_to database_path @database
    else
      render :new
    end
  end

  def show
    @database = Database.find(params[:id])
  end
end
