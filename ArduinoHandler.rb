require "serialport"
require "thread"

class ArduinoHandler
  attr_reader :adc_temp_q, :proc_id, :derp

  INPUT = 0
  OUTPUT = 1
  ANALOG = 2

  LOW = 0
  HIGH = 1

  ANALOG_MESSAGE = (0xE0..0xE5)
  REPORT_ANALOG = 0xC0
  PROTOCOL_VERSION = 0xF9

  SYSEX_START = 0xF0
  SYSEX_END = 0xF7

  def parseAnalogMessage(message)
    # We know an analog message is header + 2 bytes
    minor, major = message[1], message[2]
    return ((major << 7) | minor ) 
  end

  def parseProtocolMessage(message)
    # We know a protocol description is 3 bytes,
    puts "Protocol!"
    major, minor = message[1], message[2]
    puts "Major version: #{major} | Minor version : #{minor}"
    return major, minor
  end

  def parseSysexMessage(message)
    # Stub
    p message
  end

  def prepareADCInput(pin)
    message = [0xC0 | pin, 0x01].pack('C2')
    @sp.write message
  end

  def getReadings(acc=5)
    out = 0
    acc.times do
      out += @adc_temp_q.pop
    end
    return out/acc
  end


  def beginProcessing()
    @proc_id = Thread.new() do
      while true do
        input_data = []
        input_data.push(@sp.read(1).unpack('C')[0])
        case input_data[0]
        when PROTOCOL_VERSION
          # We know a protocol description is 3 bytes, we've read 1 so 2 more
          input_data.push(@sp.read(1).unpack('C')[0])
          input_data.push(@sp.read(1).unpack('C')[0])
          puts "Major version: #{major} | Minor version : #{minor}"
        when SYSEX_START
          #end this initial step after we see the SYSEX message
          puts "SYSEX Begin"
          opcode = input_data[0]
          while opcode != SYSEX_END do
            opcode = @sp.read(1).unpack('C')[0]
            input_data.push(opcode)
          end
          parseSysexMessage(input_data)
          break
        when ANALOG_MESSAGE
          # Analog message should be header + 2 bytes
          input_data.push(@sp.read(1).unpack('C')[0])
          input_data.push(@sp.read(1).unpack('C')[0])
          outmsg =  parseAnalogMessage(input_data)
          if (@adc_temp_q.size >= 10)
            @adc_temp_q.clear()
          end
          @adc_temp_q << outmsg
        end
      end      

    end
  end

  def endProcessing()
    @proc_id.exit
  end

  def initialize(device, speed=57600)
    @sp = SerialPort.new(device, speed, 8, 1, SerialPort::NONE)
    @adc_temp_q = Queue.new
    @proc_id = -1
    @derp = []

    #in the startup phase, all we're trying to do is consume the
    #useless version sysex and protocol version messages
    while true do
      input_data = []
      input_data.push(@sp.read(1).unpack('C')[0])
      case input_data[0]
      when PROTOCOL_VERSION
        # We know a protocol description is 3 bytes, we've read 1 so 2 more
        major = input_data.push(@sp.read(1).unpack('C')[0])
        minor = input_data.push(@sp.read(1).unpack('C')[0])
        puts "Major version: #{major} | Minor version : #{minor}"
      when SYSEX_START
        #end this initial step after we see the SYSEX message
        puts "SYSEX Begin"
        opcode = input_data[0]
        while opcode != SYSEX_END do
          opcode = @sp.read(1).unpack('C')[0]
          input_data.push(opcode)
        end
        parseSysexMessage(input_data)
        break
      end
    end
    prepareADCInput(5)

  end

end


#ah = ArduinoHandler.new('/dev/tty.usbmodemfa131', 57600)
#ah.beginProcessing()
#while true do
#  a = ah.getReadings
#    p a unless a.size == 0
#end
