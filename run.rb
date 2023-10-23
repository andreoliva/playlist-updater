# frozen_string_literal: true

require 'json'
require_relative 'src/process_changes'

puts 'Parsing files...'

input_data = JSON.parse(File.read("./#{ARGV[0]}"))
changes_data = JSON.parse(File.read("./#{ARGV[1]}"))
output_file = ARGV[2] || 'output.json'
errors = []

changes_data.each do |key, value|
  errors << case key
  when 'create_playlist'
    puts 'Creating new playlists... '
    result = ProcessChanges.create_playlist(input_data, value)
    result[:errors]
  when 'add_song_to_playlist'
    puts 'Adding songs to playlists... '
    result = ProcessChanges.add_song_to_playlist(input_data, value)
    result[:errors]
  when 'remove_playlist'
    puts 'Removing playlists... '
    result = ProcessChanges.remove_playlist(input_data, value)
    result[:errors]
  else
    "⛔ '#{key}' is not a supported operation"
  end
end

errors.flatten!
errors.compact!

puts 'Results:'
puts errors.length > 0 ? errors : '🎉 All changes applied successfully!'

File.write("./#{output_file}", JSON.dump(input_data))

puts "✅ #{output_file} file created!"
