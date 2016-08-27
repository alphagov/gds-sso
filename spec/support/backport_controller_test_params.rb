module BackportControllerTestParams
  def delete(*args)
    action, rest = *args
    super(action, rest[:params])
  end

  def get(*args)
    action, rest = *args
    super(action, rest[:params])
  end

  def post(*args)
    action, rest = *args
    super(action, rest[:params])
  end

  def put(*args)
    action, rest = *args
    super(action, rest[:params])
  end
end
