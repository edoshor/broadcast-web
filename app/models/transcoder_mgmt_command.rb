class TranscoderMgmtCommand

  # constants

  UNKNOWN_COMMAND = -1
  LOAD = 1
  UNLOAD = 2
  CHANGE_TEST_TRANSCODER = 3

  # attributes

  attr_reader :type, :args

  # constructors

  def initialize(type, args)
    @type = type
    @args = args
  end

  # public methods

  def execute(transcoder)
    case @type
      when LOAD
        TranscoderManager.instance.load_source(@args[:source].name)
      when UNLOAD
        TranscoderManager.instance.unload_source
      when CHANGE_TEST_TRANSCODER
        'change test transcoder'
      else
        raise ArgumentError, 'unknown mgmt command'
    end
  end

  def to_s
    "#{display_name}: #@args"
  end

  def display_name
    case @type
      when LOAD
        'load source'
      when UNLOAD
        'unload source'
      when CHANGE_TEST_TRANSCODER
        'change test transcoder'
      else
        'unknown command'
    end
  end
end