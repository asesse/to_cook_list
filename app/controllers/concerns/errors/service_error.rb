
class Errors::ServiceError < StandardError
  def initialize(message:)
    @message = message
  end

  def message 
    @message || "A service failed"
  end
end


  