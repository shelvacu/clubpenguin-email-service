require "sinatra"
require "sinatra-websocket"
require "./mini-smtp-server"
require "pp"

CHARS = [*('a'..'z')]
ID_LENGTH = 13 # This is chosen to be one longer than the maximum name length so that the email can be pasted into the username field and only the first 12 characters will go in, so the username will not match the user part of the email (which clubpenguin does not allow)

$websockets = {} # email id => websocket

class Socket
  def self.gethostname #Hack? Yes. Works? We'll see.
    "24nm.us"
  end
end

class PenguinSMTPD < MiniSmtpServer
  def new_message_event(m)
    STDOUT.puts "#{m[:from].inspect} => #{m[:to].inspect}"
    STDOUT.flush
    mdata = nil
    if m[:to].is_a? Array
      m[:to].find do |el|
        mdata = el.match(/<?(?<name>[^@]+)@24nm\.us>?/)
      end
    else
      mdata = m[:to].match(/<?(?<name>[^@]+)@24nm\.us>?/)
    end
    return if mdata.nil?
    puts "matched"
    STDOUT.flush
    id = mdata[:name]
    return unless $websockets.has_key?(id)
    puts "websockets has key"
    STDOUT.flush
    m[:data].each_line do |line|
      if %r{https://secured.clubpenguin.com/penguin/activate/\d\d} === line
        url = line.strip
        puts "line matched, url is #{url.inspect}"
        STDOUT.flush
        $websockets[id].send(url)
        $websockets[id].close
        $websockets.delete(id)
        return
      end
    end
  end
end

$mtp_server = PenguinSMTPD.new(2525, "0.0.0.0", 20) 

$mtp_server.start
Thread.new do
  #I think I'm going crazy
  $mtp_server.join
end

get "/" do
  haml :index
end

get "/socket" do
  if !request.websocket?
    next "nah"
  else
    request.websocket do |ws|
      id = ID_LENGTH.times.map{CHARS.sample}.join

      ws.onopen do
        $websockets[id] = ws
        ws.send(id)
      end

      ws.onclose do
        $websockets.delete(id)
      end
    end
  end
end

