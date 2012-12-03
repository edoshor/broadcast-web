class Transcoder

  require 'socket'
  require 'timeout'
  require 'ipaddr'

  SOCKET_BLOCK = 1400

  # Board errors
  RET_OK = 1
  RET_ERROR = 2
  RET_EFORMAT = 3
  RET_EVALUE = 4
  RET_ERES = 5

  # Internal errors
  RET_SOCKET = 254

  # Commands
  MOD_GET_SLOTS = 1
  MOD_GET_NET_CONFIG = 2
  MOD_SET_NET_CONFIG = 3
  MOD_RESTART = 4
  MOD_CREATE_SLOT = 5
  MOD_REMOVE_SLOT = 6
  MOD_GET_SLOT = 7
  MOD_SAVE_CONFIG = 8
  MOD_SLOT_CMD = 9

  # Commands for MOD_SLOT_CMD
  CMD_SLOT_GET_STATUS = 101
  CMD_SLOT_STOP = 102
  CMD_SLOT_RESTART = 103

  # Slot status ???
  SLOT_STOPPED = 0
  SLOT_RUNNING = 1

  def initialize(options, &block)
    @host = options.delete(:host)
    @port = options.delete(:port)
    @debug = options.delete(:debug)
    @timeout = 5
    @results = []

    #instance_eval &block
  end

  def format_output
    '<div class="output">' + "#{Time.now} " + @results.inject('') do |res, json|
      output = '<div class="item">'
      output << "<b>#{json[:func].upcase}</b>: "
      output << (json[:error] == Transcode::RET_OK ? "#{json[:message]}<br/>" : "<b>Error</b> #{json[:error]} (#{json[:message]})<br/>")
      if json[:result]
        output << '<div class="result" style="display: none;">'
        json[:result].each { |h, v|
          output << "#{h}: #{v}<br/>"
        }
        output << '</div>'
      end
      if json[:command]
        output << '<div class="command" style="display: none;">Command: '
        output << json[:command].unpack('C*').map { |c| '%02x' % c }.join(' ')
        output << '</div>'
      end
      if json[:response]
        output << '<div class="response" style="display: none;">Response: '
        output << json[:response].unpack('C*').map { |c| '%02x' % c }.join(' ').gsub(/( 20)+$/, '')
        output << '</div>'
      end
      output << '</div>'

      res + output
    end + '</div>'

  end

  def mod_get_slots
    error, response, command = send_request('C', MOD_GET_SLOTS)
    ret = {func: 'mod_get_slots', error: error, message: response, command: command, response: response}
    @results << ret and return ret if error != RET_OK

    unpacked = response.unpack('CC*')
    response_code, slots_cnt, slot_ids = [unpacked[0], unpacked[1], unpacked[2..-1]]
    ret[:error] = response_code
    ret[:message] = get_error(response_code)
    ret[:result] = {slots_cnt: slots_cnt, slots_ids: slot_ids[0... slots_cnt]} if error == RET_OK

    @results << ret
    ret
  end

  def mod_get_net_config(slot_id)
    command = MOD_GET_NET_CONFIG
    error, response, real_command = send_request(command)
    ret = {func: 'mod_get_net_config', error: error, message: response, command: command, response: response}
    @results << ret and return ret if error != RET_OK

    unpacked = response.unpack('CNNNNN')
    response_code, ip1, netmask1, ip2, netmask2, gateway = [unpacked[0], unpacked[1], unpacked[2], unpacked[3], unpacked[4]]
    ret[:error] = response_code
    ret[:message] = get_error(response_code)
    @results << ret and return ret if response_code != RET_OK

    ip1 = IPAddr.new ip1, Socket::AF_INET
    ip2 = IPAddr.new ip2, Socket::AF_INET
    netmask1 = IPAddr.new netmask1, Socket::AF_INET
    netmask2 = IPAddr.new netmask2, Socket::AF_INET
    gateway = IPAddr.new gateway, Socket::AF_INET
    ret[:result] = {ip1: ip1.to_s, netmask1: netmask1, ip2: ip2.to_s, netmask2: netmask2, gateway: gateway}

    @results << ret
    ret
  end

  def mode_save_config
    error, response, command = send_request('C', MOD_SAVE_CONFIG)
    ret = {func: 'mode_save_config', error: error, message: response, command: command, response: response}
    @results << ret and return ret if error != RET_OK

    response_code = response.unpack('C')[0]
    ret[:error] = response_code
    ret[:message] = response_code == RET_OK ? "Module config was saved" : "Module config was NOT saved"

    @results << ret
    ret
  end

  def mod_restart
    error, response, command = send_request('C', MOD_RESTART)
    ret = {func: 'mod_restart', error: error, message: response, command: command, response: response}
    @results << ret and return ret if error != RET_OK

    response_code = response.unpack('C')[0]
    ret[:error] = response_code
    ret[:message] = response_code == RET_OK ? "Module was (re)started" : "Module was NOT (re)started"

    @results << ret
    ret
  end

  def mod_create_slot(slot_id, force, tracks_cnt, tracks)
    error, response, command = send_request('CCCCC*', MOD_CREATE_SLOT, slot_id, force, tracks_cnt, tracks)
    ret = {func: 'mod_create_slot', error: error, message: response, command: command, response: response}
    @results << ret and return ret if error != RET_OK

    response_code = response.unpack('C')[0]
    ret[:error] = response_code
    ret[:message] = response_code == RET_OK ? "Slot #{slot_id} was created" : "Slot #{slot_id} was NOT created"

    @results << ret
    ret
  end

  def mod_remove_slot(slot_id)
    error, response, command = send_request('CC', MOD_REMOVE_SLOT, slot_id)
    ret = {func: 'mod_remove_slot', error: error, message: response, command: command, response: response}
    @results << ret and return ret if error != RET_OK

    response_code = response.unpack('C')[0]
    ret[:error] = response_code
    ret[:message] = response_code == RET_OK ? "Slot #{slot_id} was removed" : "Slot #{slot_id} was NOT removed"

    @results << ret
    ret
  end

  def mod_get_slot(slot_id)
    error, response, command = send_request('CC', MOD_GET_SLOT, slot_id)
    ret = {func: 'mod_get_slot', error: error, message: response, command: command, response: response}
    @results << ret and return ret if error != RET_OK

    unpacked = response.unpack('CCCN*')
    response_code, force, tracks_cnt, tracks = [unpacked[0], unpacked[1], unpacked[2], unpacked[3..-1]]

    ret[:error] = response_code
    ret[:message] = get_error(response_code)
    @results << ret and return ret if response_code != RET_OK

    tracks = tracks[0... tracks_cnt].map do |track|
      [track].pack('N').unpack('C*')
    end

    ret[:result] = {force: force, total_tracks: tracks_cnt, tracks: tracks}

    @results << ret
    ret
  end

  def mod_slot_get_status(slot_id)
    error, response, command = send_request('CCC', MOD_SLOT_CMD, slot_id, CMD_SLOT_GET_STATUS)
    ret = {func: 'mod_slot_get_status', error: error, message: response, command: command, response: response}
    @results << ret and return ret if error != RET_OK

    unpacked = response.unpack('CCCNNnNnCC*')
    response_code, slot_status, signal, uptime, ip1, port1, ip2, port2, tracks_cnt, tracks =
        [unpacked[0], unpacked[1], unpacked[2], unpacked[3], unpacked[4], unpacked[5], unpacked[6], unpacked[7], unpacked[8], unpacked[9..-1]]
    ret[:error] = response_code
    ret[:message] = get_error(response_code)
    @results << ret and return ret if response_code != RET_OK

    ret[:error] = RET_OK
    if slot_status == SLOT_STOPPED
      ret[:message] = "Slot is stopped"
      @results << ret and return ret
    end

    ip1 = IPAddr.new ip1, Socket::AF_INET
    ip2 = IPAddr.new ip2, Socket::AF_INET
    tracks = tracks[0... tracks_cnt]

    ret[:message] = "Slot is running"
    ret[:result] = {signal: signal, uptime: uptime, ip1: ip1.to_s, port1: port1, ip2: ip2.to_s, port2: port2, total_tracks: tracks_cnt, tracks: tracks}

    @results << ret
    ret
  end

  def mod_slot_stop(slot_id)
    error, response, command = send_request('CCC', MOD_SLOT_CMD, slot_id, CMD_SLOT_STOP)
    ret = {func: 'mod_slot_stop', error: error, message: response, command: command, response: response}
    @results << ret and return ret if error != RET_OK

    response_code = response.unpack('C')[0]
    ret[:error] = response_code
    ret[:message] = response_code == RET_OK ? "Slot #{slot_id} was stopped" : "Slot #{slot_id} was NOT stopped"

    @results << ret
    ret
  end

  def mod_slot_restart(slot_id, ip1, port1, ip2, port2, tracks_cnt, tracks)
    ip1 = IPAddr.new ip1, Socket::AF_INET
    ip2 = IPAddr.new ip2, Socket::AF_INET
    error, response, command = send_request('CCCNnNnCC*', MOD_SLOT_CMD, slot_id, CMD_SLOT_RESTART, ip1.to_i, port1, ip2.to_i, port2, tracks_cnt, tracks)
    ret = {func: 'mod_slot_restart', error: error, message: response, command: command, response: response}
    @results << ret and return ret if error != RET_OK

    response_code = response.unpack('C')[0]
    ret[:error] = response_code
    ret[:message] = response_code == RET_OK ? "Slot #{slot_id} was (re)started" : "Slot #{slot_id} was NOT (re)started"

    @results << ret
    ret
  end

  private
  def send_request(pack_mask, *command)
    socket = nil

    begin
      timeout(@timeout) do # the server has timeout seconds to answer
        socket = TCPSocket.open(@host, @port)
      end
    rescue
      return [RET_SOCKET, "#{$!}"]
    end

    begin
      real_command = command.flatten.pack(pack_mask)
      socket.send real_command, 0
      response = socket.recv(SOCKET_BLOCK)
    rescue
      return [RET_SOCKET, "#{$!}"]
    ensure
      socket.close
    end

    [RET_OK, response, real_command]
  end


  def get_error(error_code, message = nil)
    case error_code
      when RET_OK
        'Command completed successfully'
      when RET_ERROR
        'Internal error when processing command'
      when RET_EFORMAT
        'Bad format of request message'
      when RET_EVALUE
        'Bad value of some parameter in request message'
      when RET_ERES
        'Not enough resources to create slot'
      else
        message
    end
  end

  # convert a dotted decimal IPv4 address to dotted binary format
  def ipv4_to_binary(ipv4)
    ia = ipv4.to_s.split(/\./)
    if ia.size != 4
      return "Not a valid IPv4 Address."
    end

    ["%08d" % ia[0].to_i.to_s(2), "%08d" % ia[1].to_i.to_s(2), "%08d" % ia[2].to_i.to_s(2), "%08d" % ia[3].to_i.to_s(2)].join(".")
  end

  # convert a IPv4 address in binary dotted format to a dotted IPv4 address
  def binary_to_ipv4(ipv4addr)
    ia = ipv4addr.to_s.split('.')
    if ia.size != 4
      return "0.0.0.0"
    end
    output = ""
    i = 1
    for octett in ia
      output = output + octett.to_s.to_i(2).to_s
      if i < 4
        output = output + "."
      end
      i += 1
    end
    output
  end

end