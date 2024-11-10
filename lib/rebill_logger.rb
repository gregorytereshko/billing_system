class RebillLogger
  @logger = Logger.new(STDOUT)

  def self.log(message)
    @logger.info(message)
  end
end