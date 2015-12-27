require 'rubygems'
require 'bundler/setup'
require 'json'
require 'faraday'
require 'faraday_middleware'
require 'faker'
require 'base64'

class Spomodoro
  attr_accessor :user_id, :source_playlist, :spotify_refresh_token, :client_credentials, :spotify_token, :track_uri, :playlist_id

  def initialize
    @user_id = ENV['SPOTIFY_USER_ID']
    @source_playlist = ENV['SPOTIFY_SOURCE_PLAYLIST_ID']
    @spotify_refresh_token = ENV['SPOTIFY_REFRESH_TOKEN']

    #Get Authorization Token
    client_id = ENV['SPOTIFY_CLIENT_ID']
    client_secret = ENV['SPOTIFY_CLIENT_SECRET']
    @client_credentials = Base64.strict_encode64(client_id + ":" + client_secret)
    token = auth_spotify('post').body
    @spotify_token = token['access_token']
  end

  def auth_spotify(verb)
    conn = Faraday.new(:url => 'https://accounts.spotify.com') do |faraday|
      faraday.adapter Faraday.default_adapter
      faraday.response :json, :content_type => /\bjson$/
    end

    response = conn.send(verb) do |req|
      req.headers['Authorization'] = 'Basic ' + client_credentials
      req.url "/api/token"
      req.body = "grant_type=refresh_token&refresh_token=" + spotify_refresh_token
    end

    return response
  end

  def query_spotify(verb, call, args:[])

    case call
    when 'get_playlist'
      url = "/v1/users/#{user_id}/playlists/#{source_playlist}"
    when 'create_playlist'
      url = "/v1/users/#{user_id}/playlists"
      body = args[0]
    when 'tracks'
      playlist_id = args[0]
      url = "/v1/users/#{user_id}/playlists/#{playlist_id}/tracks"
      body = args[1]
    when 'authorize'
      url = "/"
    end

    conn = Faraday.new(:url => 'https://api.spotify.com', :params => {:market => 'US', :limit => 1000}) do |faraday|
      faraday.adapter Faraday.default_adapter
      faraday.request :json
      faraday.response :json, :content_type => /\bjson$/
    end

    response = conn.send(verb) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = 'Bearer ' + spotify_token
      req.url url
      req.body = body
    end

    data = response.body
    return data
  end

  def track_uris(data)
    i = 0
    uri_list = Array.new

    while i < data['tracks']['items'].length do
      uri = data['tracks']['items'][i]['track']['uri']
      duration = data['tracks']['items'][i]['track']['duration_ms']
      info = { :uri => uri, :duration => duration }
      uri_list.push(info)
      i+=1
    end

    return uri_list
  end

  def build_list(data)
    duration = 0
    pomodoro = 1500000
    song_list = Array.new

    while duration < pomodoro do
      random = Random.rand(data.length)
      song = data[random]
      song_uri = song[:uri]
      song_list.push(song_uri)

      duration += song[:duration]
    end
    return song_list
  end

  def create_playlist(data)
    #create new spotify playlist
    playlist_name = "pomodoro-" + Faker::Hipster.word + "-" + Faker::Hipster.word
    playlist_payload = {:name => playlist_name, :public => false}.to_json
    playlist_id = query_spotify('post','create_playlist', args:[playlist_payload])['id']
    #Post Data to New Playlist
    query_spotify('post','tracks', args:[playlist_id, data])
  end

end

s = Spomodoro.new
tracks = s.query_spotify('get','get_playlist')
uris = s.track_uris(tracks)
list = s.build_list(uris)
json_list = { :uris => list }.to_json
s.create_playlist(json_list)
