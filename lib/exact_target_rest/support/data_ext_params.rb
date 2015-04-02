module ExactTargetRest
  class DataExtParams
    def initialize(*key_fields, snake_to_camel: true)
      @key_fields = key_fields.map(&:to_sym)
      @snake_to_camel = snake_to_camel
    end

    def transform(params)
      (Hash === params ? [params] : params).lazy
          .map { |h| h.partition { |k, _| @key_fields.include?(k.to_sym) } }
          .map { |a, b| {keys: @snake_to_camel ? a.to_h.snake_to_camel : a.to_h,
                         values: @snake_to_camel ? b.to_h.snake_to_camel : b.to_h} }
          .to_a
    end
  end
end