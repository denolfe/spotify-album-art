# encoding: utf-8

require 'rautomation'
require 'rspotify'
require 'open-uri'
require 'certified' # Resolves ssl issues when downloading image. http://stackoverflow.com/questions/10728436/opensslsslsslerror-ssl-connect-returned-1-errno-0-state-sslv3-read-server-c


class Monitor
  

  attr_accessor :window, :title, :last_title, :state

  def initialize
    @window = RAutomation::Window.new(title: /spotify/i, class: "SpotifyMainWindow")
    @state == 'Paused'
    return unless @window.exists?
  end

  def start
    while true do
      @title = @window.title.to_s[10..-1]

      @title.to_s.encode!(@title.to_s.encoding, 'binary', invalid: :replace, undef: :replace)

      if @title.to_s.length == 0
        # puts "No song playing, length #{title.to_s.length}"
        pause
      elsif @last_title != @title or @state == 'Paused'
        @state = 'Playing'
        
        File.open('nowplaying.txt', 'wb') do |fo|
          fo.write(@title)
        end

        @title = File.open('nowplaying.txt', "rb") {|io| io.read}
        song_change(@title)
      end
      sleep 1
    end
  end

  def pause
    @state = 'Paused'
  end

  def song_change(title)
    if title.length > 0
      puts title
      @last_title = @title
      get_art(@title)
    end

  end

  def get_art(search)
    tracks = RSpotify::Track.search(search)
    art_url = tracks.first.album.images[1]['url']
    puts art_url

    File.open('cover.png', 'wb') do |fo|
      fo.write open(art_url).read 
    end
  end

end

if __FILE__ == $0
  mon = Monitor.new
  mon.start
end