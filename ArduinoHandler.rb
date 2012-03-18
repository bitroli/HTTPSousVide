require "serialport"
require "thread"

class ArduinoHandler
  attr_reader :adc_temp_q, :proc_id

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
    p message
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
    pin = 0xC0 | pin
    p "#{pin}\x69\xF7"
    @sp.write = "#{pin}\x69\xF7"
  end



  def beginProcessing()
    @proc_id = Thread.new do
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
          @adc_temp_q << parseAnalogMessage(input_data)
        end
      end      

    end
  end


  def initialize(device, speed=57600)
    @sp = SerialPort.new(device, speed, 8, 1, SerialPort::NONE)
    @adc_temp_q = Queue.new
    @proc_id = -1

    #in the startup phase, all we're trying to do is consume the
    #useless version sysex and protocol version messages
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
      end
    end
    time.sleep(1)
    prepareADCInput(5)

  end

end
