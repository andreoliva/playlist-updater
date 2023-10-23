# playlist-updater

### What is this?
By consumming the `spotify.json` and the `changes.json` files, this app produces an output file with the same structure from the input file with the changes from the other file applied to the data. The app will validate:

- that the user and songs are valid when creating a new playlist
- that the playlist and song are valid when adding a song to an existing playlist
- that the playlist exists when it's being removed

The app will produce the output file with all the applied changes, and inform the user of all the problems it encounters. Even if no change is applied, an output file will be created.

### Setting up and testing the app
You can setup and run this app with or without Docker.

#### With Docker
- install [Docker CE](https://docs.docker.com/install/)
- install [Docker Compose](https://docs.docker.com/compose/install/)
- clone this repository
- once inside the repo you can start you container, it will download all the dependencies and build the `app` image:
```sh
docker-compose up -d
```
- with the container running you can run the script with:
```sh
docker-compose exec app ruby run.rb spotify.json changes.json
```
- if you want you can pass a third parameter with the output file name (it defaults to `output.json`):
```sh
docker-compose exec app ruby run.rb spotify.json changes.json results.json
```
- to run the test suite use:
```sh
docker-compose exec app bin/rspec --format doc
```
- after using it, you can stop and remove the container with (you'll also need to remove the create image):
```sh
docker-compose down
```

#### Without Docker
- install [Ruby 3.2.2](https://gorails.com/setup) on your machine
- clone this repository
- once inside the repo you will also need to install the project's dependencies:
```sh
bundle install
```
- you can run the script with:
```sh
ruby run.rb spotify.json changes.json
```
- if you want you can pass a third parameter with the output file name (it defaults to `output.json`):
```sh
ruby run.rb spotify.json changes.json results.json
```
- to run the test suite use:
```sh
bin/rspec --format doc
```

### Next steps

#### Concerning appliying multiple changes of each type
On this first version the app is working with only one change for each type (eg. it can only remove only one playlist per "changes" file) - one improvement would be to allow the `changes.json` to carry a list of changes for each type. So, if currently our `changes.json` looks like this:
```json
{
  "create_playlist": { "owner_id": "4", "song_ids": ["16", "17", "18"] },
  "add_song_to_playlist": { "playlist_id": "3", "song_id": "6" },
  "remove_playlist": "2"
}
```
It would then look like this:
```json
{
  "create_playlist": [
    { "owner_id": "4", "song_ids": ["16", "17", "18"] },
    { "owner_id": "5", "song_ids": ["19", "20"] }
  ],
  "add_song_to_playlist": [
    { "playlist_id": "2", "song_ids": ["14", "15"] }
    { "playlist_id": "3", "song_ids": ["6"] }
  ],
  "remove_playlist": ["1", "2", "3"]
}
```
And I'd need to update the code accordingly. My first thought would be to create a intermediary module to control the iteractions over the "changes" arrays, and use the `ProcessChanges` module like it's being used right now: to process each singular change and return the errors messages.

#### Possible refactors
Break the `ProcessChanges` into separate modules for each kind of change. If there's the possibility of us wanting to add new types of change (add/remove songs or users, for example) having just one module with all the processes would make it huge and hard to read.

#### Concerning huge JSON files
If we reach a point where our JSON input files are too big and start causing problems, we would need to consider a way to use JSON streaming techniques to processes JSON data in chunks instead of loading the entire file into memory. In Ruby we can use gems like [yajl-ruby](https://github.com/brianmario/yajl-ruby) or [json-streamer](https://github.com/thisismydesign/json-streamer) to help us achieve this - I don't think I ever had to do something like this, so I'm not so sure how it would work exactly, but this is a start.

### How long it took?
3 hours more or less (not contiguous), including setup and unit tests.