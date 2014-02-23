class QueryController < ApplicationController

  def index
    db = Database.first
    if db
      execute(db)
    else
      redirect_to new_database_path
    end
  end

  def show
    db = Database.find(params[:id])
    execute(db)
  end

  private

  def execute(db)
    @database = db
    @schema = db.dynamic_schema
    db.build_classes

    select = params[:select] || {}

    if select.empty?
      @data = []
    else
      dynamic_select, is_dynamic_select, dynamic_fields = dynamicify_select(db, select)
      filter = parse_filter(params[:filter])#{"customers" => [["item_count", "starts_with", "1"]]}

      dynamic_filter_fields, is_dynamic_filter = dynamicify_filter(db, filter)

      sort = []#[["customers", "age", "asc"]]

      sql = construct_sql(dynamic_select, filter, sort)

      sql = sql.gsub(/^SELECT/, "SELECT #{column_name_array(dynamic_select, true).join(",")}")

      @data = [column_name_array(select)] + ClientBase.connection.select_rows(sql)

      @data = process_dynamic_column(@data, dynamic_fields, dynamic_filter_fields) if (is_dynamic_select || is_dynamic_filter)

    end

    respond_to do |format|
      format.json { render :json => @data }
      format.html { render :index }
    end
  end

  def parse_filter(filter)
    if filter
      filter.each do |table, _|
        filter[table] = filter[table].values
      end
      filter
    else
      {}
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
          dynamic_fields << [table, column]
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

  def dynamicify_filter(db, filter)
    dynamic_fields = Hash.new { Array.new }
    filter.each do |table, columns|
      columns.each_with_index do |column, index|
        if db.dynamic_columns.where(table: table, name: column.first).count > 0
          dynamic_fields[table] = dynamic_fields[table] << column
          columns[index] = nil
        end
      end
      filter[table] = columns.compact
    end

    if dynamic_fields.empty?
      [{}, false]
    else
      [dynamic_fields, true]
    end

  end

  def process_dynamic_column(data, dynamic_select_fields, dynamic_filter_fields)
    data.each_with_index do |row, index|
      next if index == 0

      dynamic_select_fields.each_with_index do |(table_klass, method), row_index|
        next unless table_klass && method
        klass = table_klass.classify.constantize
        #begin
          row[row_index] = klass.find(row[row_index]).send(method)

          if dynamic_filter_fields[table_klass] && dynamic_filter_fields[table_klass].any? { |field| field.first == method }
            _, operand, values = dynamic_filter_fields[table_klass].select { |field| field.first == method }.first

            data[index] = nil unless filter_dynamic_field(operand, row[row_index], values)
          end
        # rescue
        #   row[row_index] = "ERROR"
        # end
      end
    end
    data.compact
  end

  def filter_dynamic_field(operand, data, values)
    case operand
    when "greater_than" then data > values.to_i
    when "less_than" then data < values.to_i
    when "equal_to", "equal", "exactly_matches" then data == values.to_i
    when "in" then values.split(",").include?(data.to_s)
    when "contains" then data.to_s.match(eval("/#{values}/"))
    when "ends_with" then data.to_s.match(eval("/#{values}$/"))
    when "starts_with" then data.to_s.match(eval("/^#{values}/"))
    else true
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