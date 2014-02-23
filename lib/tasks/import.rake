require 'csv'

desc "Import teams from csv file"
task :import => [:environment] do

  file = "db/teams.csv"

  CSV.foreach(file, :headers => true) do |row|
    Team.create {
      :name => row[1],
      :league => row[2],
      :some_other_data => row[4]
    }
  end

end