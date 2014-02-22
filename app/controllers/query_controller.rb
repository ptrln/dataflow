class QueryController < ApplicationController

  def index
    db = Database.first
    params[:id] = 1
  	show
  end

  def show
    db = Database.find(params[:id])
    @schema = db.build_schema
    db.build_classes

    @data = [Client::Customer.column_names] + ClientBase.connection.select_rows("SELECT * FROM customers")

    render :index
  end

 end