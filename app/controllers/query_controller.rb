class QueryController < ApplicationController

  def index
    db = Database.first
    if db
      execute(db)
    else

    end
  end

  def show
    db = Database.find(params[:id])
    execute(db)
  end

  private

  def execute(db)
    @schema = db.dynamic_schema
    db.build_classes

    select = params[:select] || {}

    if select.empty?
      @data = []
    else
      dynamic_select, is_dynamic, dynamic_fields = dynamicify_select(db, select)
      filter = {}#{"customers" => [["name", "starts_with", "D"]]}
      sort = [["customers", "age", "asc"]]

      sql = construct_sql(dynamic_select, filter, sort)

      sql = sql.gsub(/^SELECT/, "SELECT #{column_name_array(dynamic_select, true).join(",")}")

      @data = [column_name_array(select)] + ClientBase.connection.select_rows(sql)
      @data = process_dynamic_column(@data, dynamic_fields) if is_dynamic
    end

    respond_to do |format|
      format.json { render :json => @data }
      format.html { render :index }
    end
  end

  def dynamicify_select(db, select)
    modified_select = select.clone
    dynamic_fields = []
    modified_select.each do |table, columns|
      cloned = columns.clone

      cloned.each_with_index do |column, index|
        if db.dynamic_columns.where(table: table, name: column).count > 0
          cloned[index] = "id"
          dynamic_fields << [table.classify.constantize, column]
        else
          dynamic_fields << nil
        end
      end

      modified_select[table] = cloned
    end
    
    if dynamic_fields.compact.count > 0
      [modified_select, true, dynamic_fields]
    else
      [select, false, []]
    end
  end

  def process_dynamic_column(data, dynamic_fields)
    data.each_with_index do |row, index|
      next if index == 0

      dynamic_fields.each_with_index do |(klass, method), row_index|
        next unless klass && method
        row[row_index] = klass.find(row[row_index]).send(method)
      end
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
    main_klass.select("")
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
    sort.each do |table, column, order|
      next unless ["DESC", "ASC"].include?(order.upcase)
      main_klass = main_klass.order("\"#{table}\".\"#{column}\" #{order.upcase}")
    end
    main_klass
  end

 end