class Hash
  def snake_to_camel
    self.map { |k, v| [k.to_s.snake_to_camel, Hash === v ? v.snake_to_camel : v]}.to_h
  end
end