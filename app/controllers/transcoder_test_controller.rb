class TranscoderTestController < ApplicationController
  require 'transcoder_api'
  require 'stub_transcoder_api'

  def index
  end

  def perform
    commands = split_commands().map { |cmd| TranscoderCommand.create(cmd) }
    commands.delete nil
    @validations = commands.map{|cmd| [cmd, cmd.validate]}

    if @validations.all? {|cmd, validation| 'valid'.eql? validation}
      transcoder = TranscoderManager.instance.get_transcoder('main')
      #transcoder.api = StubTranscoderApi.new(host: 'host', port: 'port')

      @results = commands.map {|cmd| [cmd, cmd.execute(transcoder)]}
      render :partial => 'batch_results'
    else
      render :partial => 'invalid_batch'
    end
  end


  def status
    transcoder = TranscoderManager.instance.get_transcoder('main')
    @results, @running = prepare_status_results transcoder.get_status
    render :partial => 'transcoder_status'
  end

  private

  def split_commands
    params[:commands].split(/\r?\n/).map {|cmd| cmd.gsub(/"/,'')}
  end

  def prepare_status_results(results)
    running = 0
    ret = results.map { |cmd, result|
      result[:running]= false
      result[:uptime] = 'stopped'
      unless result[:result].nil?
        running += 1
        result[:running]= true
        status = result[:result]
        result[:source1] = TranscoderManager.instance.get_source_by_address(status[:ip1], status[:port1]).name
        result[:source2] = TranscoderManager.instance.get_source_by_address(status[:ip2], status[:port2]).name
        result[:signal] = status[:signal]
        result[:uptime] = format_duration status[:uptime]
      end
      result
    }
    [ret, running]
  end

  def format_duration(secs)
    mins  = secs / 60
    hours = mins / 60
    days  = hours / 24

    time_in_day = format("%02d:%02d:%02d", hours % 24, mins % 60, secs % 60)
    days > 0 ? "#{days} days #{time_in_day}" : time_in_day
  end
end
