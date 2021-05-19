module ExactTargetRest
  # Transformer for InteractionEvent payload
  class InteractionEventParams
    def initialize(*top_level_fields)
      @top_level_fields = top_level_fields.map(&:to_sym)
    end

    def transform(params)
      result, data = params.partition { |k, _| @top_level_fields.include?(k.to_sym) }
      result = result.map { |k, v| [k.to_s.snake_to_camel.to_sym, v] }.to_h

      if data.length > 0
        result[:Data] = data.map { |k, v| [k, v] }.to_h
      end

      result
    end
  end
end
