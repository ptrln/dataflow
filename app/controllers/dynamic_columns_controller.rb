class DynamicColumnsController < ApplicationController

  def new
    @database = Database.find(params[:database_id])
    @schema = @database.schema
    @dynamic_column = @database.dynamic_columns.build
  end

  def create
    @database = Database.find(params[:database_id])
    @dynamic_column = @database.dynamic_columns.build(params[:dynamic_column])
    if @dynamic_column.save
      redirect_to query_path @database
    else
      render :new
    end
  end

end
