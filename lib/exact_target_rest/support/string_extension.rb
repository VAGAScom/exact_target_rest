class String
  def snake_to_camel
    self.gsub(/(?:_|^)([[:word:]])/) { $1.upcase }
  end
end