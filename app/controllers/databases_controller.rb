class DatabasesController < ApplicationController

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
  
end
