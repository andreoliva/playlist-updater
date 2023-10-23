# frozen_string_literal: true

require_relative '../src/process_changes'

RSpec.describe ProcessChanges do
  let(:input_data) {
    {
      'users' => [
        { 'id' => '1', 'name' => 'Albin Jaye' },
        { 'id' => '2', 'name' => 'Dipika Crescentia' }
      ],
      'playlists' => [
        { 'id' => '1', 'owner_id' => '1', 'song_ids' => ['1'] }
      ],
      'songs' => [
        { 'id' => '1', 'artist' => 'Camila Cabello', 'title' => 'Never Be the Same' },
        { 'id' => '2', 'artist' => 'Zedd', 'title' => 'The Middle' }
      ]
    }
  }

  context '.create_playlist' do
    it 'creates a new playlist' do
      new_playlist = { 'owner_id' => '2', 'song_ids' => ['1', '2'] }

      result = ProcessChanges.create_playlist(input_data, new_playlist)

      playlists = input_data['playlists']
      expect(playlists.length).to eq(2)
      expect(playlists.last['id']).to eq('2')
      expect(playlists.last['owner_id']).to eq('2')
      expect(playlists.last['song_ids']).to eq(['1', '2'])
      expect(result[:errors]).to be_empty
    end

    it 'returns error message if user is not found' do
      new_playlist = { 'owner_id' => '13', 'song_ids' => ['1', '2'] }

      result = ProcessChanges.create_playlist(input_data, new_playlist)

      expect(input_data['playlists'].length).to eq(1)
      expect(result[:errors]).to eq([
        '⛔ User with id 13 not found',
        '⛔ The playlist was not created!'
      ])
    end

    it 'returns error message if no valid songs are found' do
      new_playlist = { 'owner_id' => '1', 'song_ids' => ['111', '222'] }

      result = ProcessChanges.create_playlist(input_data, new_playlist)

      expect(input_data['playlists'].length).to eq(1)
      expect(result[:errors]).to eq([
        '⛔ No existent songs found to be added',
        '⛔ The playlist was not created!'
      ])
    end
  end

  context '.add_song_to_playlist' do
    it 'adds song to playlist' do
      add_song = { 'playlist_id' => '1', 'song_id' => '2' }

      result = ProcessChanges.add_song_to_playlist(input_data, add_song)

      playlist = input_data['playlists'].first
      expect(playlist['song_ids'].length).to eq(2)
      expect(playlist['song_ids']).to include('2')
      expect(result[:errors]).to be_empty
    end

    it 'returns error message if playlist is not found' do
      add_song = { 'playlist_id' => '13', 'song_id' => '2' }

      result = ProcessChanges.add_song_to_playlist(input_data, add_song)

      expect(result[:errors]).to eq([
        '⛔ Playlist with id 13 not found',
        '⛔ The song was not added to the playlist!'
      ])
    end

    it 'returns error message if song is not found' do
      add_song = { 'playlist_id' => '1', 'song_id' => '13' }

      result = ProcessChanges.add_song_to_playlist(input_data, add_song)

      expect(result[:errors]).to eq([
        '⛔ Song with id 13 not found',
        '⛔ The song was not added to the playlist!'
      ])
    end

    it 'returns error message if song is already on the playlist' do
      add_song = { 'playlist_id' => '1', 'song_id' => '1' }

      result = ProcessChanges.add_song_to_playlist(input_data, add_song)

      expect(result[:errors]).to eq([
        '⛔ Song with id 1 already exists on playlist 1',
        '⛔ The song was not added to the playlist!'
      ])
    end
  end

  context '.remove_playlist' do
    it 'removes playlist' do
      remove_playlist_id = '1'

      result = ProcessChanges.remove_playlist(input_data, remove_playlist_id)

      expect(input_data['playlists'].length).to eq(0)
      expect(result[:errors]).to be_empty
    end

    it 'returns error message if playlist is not found' do
      remove_playlist_id = '13'

      result = ProcessChanges.remove_playlist(input_data, remove_playlist_id)

      expect(input_data['playlists'].length).to eq(1)
      expect(result[:errors]).to eq([
        '⛔ Playlist with id 13 was not found and could not be removed!'
      ])
    end
  end
end