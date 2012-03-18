require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require 'json'
require_relative 'ArduinoHandler'

class SousVideServer < Sinatra::Base
  temperature = 75
  target_temp = 100

  def initialize()
    super
    @a_one = ArduinoHandler.new('/dev/tty.usbmodemfa131', 57600)
    @p_id = @a_one.beginProcessing()
    p @a_one, @p_id
  end

  get '/' do
    erb :index
  end

  get '/readTemperature' do
    rsp = JSON.generate({:temperature => temperature})
    if temperature >= 212
      temperature = 75
    else
      temperature += 5
    end
    rsp
  end

  get '/setTargetTemperature/:tgttemp' do
    target_temp = params[:tgttemp]
    return JSON.generate({:target => target_temp})
  end

  get '/getTargetTemperature/' do
    return JSON.generate({:target => target_temp})
  end

  get '/test/' do
    v = @a_one.getReadings
    p v
    return JSON.generate({:test => (v*47.3/681).round(1), :scale => "C" })
  end

end

SousVideServer.run!
