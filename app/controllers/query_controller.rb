class QueryController < ApplicationController

  def index
    db = Database.first
    execute(db)
  end

  def show
    db = Database.find(params[:id])
    execute(db)
  end

  private

  def execute(db)
    @schema = db.build_schema
    db.build_classes

    select = {"customers" => ["id", "age", "name", "gender"]}
    filter = {"customers" => [["name", "starts_with", "D"]]}
    sort = [["customers", "age", "desc"]]

    sql = construct_sql(select, filter, sort)

    @data = [column_name_array(select)] + ClientBase.connection.select_rows(sql)

    p sql

    respond_to do |format|
      format.json { render :json => @data }
      format.html { render :index }
    end
  end

  def column_name_array(select_params, escape = false)
    columns = []
    select_params.each do |table_name, column_names|
      if escape
        columns += column_names.map { |column_name| "\"#{table_name}\".\"#{column_name}\"" }
      else
        columns += column_names.map { |column_name| "#{table_name}.#{column_name}" }
      end
    end
    columns
  end

  def construct_sql(select, filter, sort)
    main_klass = construct_select_sql(select, filter, sort)
    main_klass = construct_filter_sql(main_klass, filter)
    main_klass = construct_sort_sql(main_klass, sort)
    main_klass.to_sql
  end

  def construct_select_sql(select, filter, sort)
    tables = (select.keys + filter.keys + sort.map(&:first)).uniq
    main_klass = tables.shift.classify.constantize
    tables.each do |table|
      main_klass = main_klass.joins(table.to_sym)
    end
    main_klass.select(column_name_array(select, true))
  end

  def construct_filter_sql(main_klass, filters)
    if filters.length > 0
      filters.each do |table_name, column_filters|
        column_filters.each do |column_filter|
          op, arg = filter_operation(column_filter[1], column_filter[2])
          main_klass = main_klass.where("\"#{table_name}\".\"#{column_filter[0]}\" #{op}", arg) if op
        end
      end
    end
    main_klass = main_klass.where("")
  end

  def filter_operation(operand, values)
    case operand
    when "greater_than" then [" > ? ", values]
    when "less_than" then [" < ? ", values]
    when "equal_to", "equal", "exactly_matches" then [" = ? ", values]
    when "in" then [" IN (?) ", values.split(",")]
    when "contains" then [" LIKE ?", values]
    when "ends_with" then [" LIKE ?", "%#{values}"]
    when "starts_with" then [" LIKE ?", "#{values}%"]
    else nil
    end
  end

  def construct_sort_sql(main_klass, sort)
    main_klass
  end

 end