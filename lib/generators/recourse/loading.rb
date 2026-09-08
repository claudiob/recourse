module Recourse
  module Generators
    # Teaches `db/seeds.rb` to load the files under `db/seeds`, once, however many
    # generators write one. Private for the reason `Seeds` is.
    module Loading
      # What loads one file per resource, alphabetically — reorder by hand where one
      # resource's rows need another's to exist first — saying which table it is on,
      # and how many rows stand once its file is done.
      LOADER = <<~'RUBY'

        $stdout.sync = true
        Dir[Rails.root.join('db/seeds/*.rb')].sort.each do |seeds|
          table = File.basename seeds, '.rb'
          print "Seeding #{table}... ⏳"
          load seeds
          rows = ActiveRecord::Base.lease_connection.select_value "select count(*) from #{table}"
          puts "\r\e[KSeeded #{rows} #{table} ✅"
        end
      RUBY

    private

      # Once, however many resources are generated: `db/seeds.rb` loads the directory
      # rather than naming every file in it. The check is the glob rather than the
      # whole block, so a `db/seeds.rb` written by an earlier version keeps the
      # loader it has rather than gaining a second one.
      def load_seed_files
        path = File.join destination_root, 'db/seeds.rb'
        create_file 'db/seeds.rb', '' unless File.exist? path
        return if File.exist?(path) && File.read(path).include?('db/seeds/*.rb')

        append_to_file 'db/seeds.rb', LOADER
      end
    end
  end
end
