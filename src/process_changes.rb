# frozen_string_literal: true

module ProcessChanges
  def self.create_playlist(input_data, new_playlist)
    errors = []
    user = input_data['users'].find { |u| u['id'] == new_playlist['owner_id'] }
    found_song_ids = new_playlist['song_ids'].filter do |song_id|
      input_data['songs'].find { |s| s['id'] == song_id }
    end

    errors << "⛔ User with id #{new_playlist['owner_id']} not found" if !user
    errors << '⛔ No existent songs found to be added' if found_song_ids.length == 0

    if errors.length > 0
      errors << '⛔ The playlist was not created!'
    else 
      new_playlist = {
        'id' => (input_data['playlists'].map { |pl| pl['id'].to_i }.max + 1).to_s,
        'owner_id' => user['id'],
        'song_ids' => found_song_ids
      }
      input_data['playlists'] << new_playlist
    end

    { errors: errors }
  end

  def self.add_song_to_playlist(input_data, add_song)
    errors = []
    playlist = input_data['playlists'].find { |pl| pl['id'] == add_song['playlist_id'] }
    song = input_data['songs'].find { |s| s['id'] == add_song['song_id'] }

    errors << "⛔ Playlist with id #{add_song['playlist_id']} not found" if !playlist
    errors << "⛔ Song with id #{add_song['song_id']} not found" if !song
    if playlist && playlist['song_ids'].include?(add_song['song_id'])
      errors << "⛔ Song with id #{add_song['song_id']} already exists on playlist #{add_song['playlist_id']}"
    end

    if errors.length > 0
      errors << '⛔ The song was not added to the playlist!'
    else
      playlist['song_ids'] << add_song['song_id']
    end
    
    { errors: errors }
  end

  def self.remove_playlist(input_data, remove_playlist_id)
    errors = []
    playlist_index = input_data['playlists'].find_index { |pl| pl['id'] == remove_playlist_id }

    if !playlist_index
      errors << "⛔ Playlist with id #{remove_playlist_id} was not found and could not be removed!"
    else
      input_data['playlists'].delete_at(playlist_index)
    end

    { errors: errors }
  end
end