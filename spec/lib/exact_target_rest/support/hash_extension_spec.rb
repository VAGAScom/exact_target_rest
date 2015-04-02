require 'spec_helper'

describe Hash do
  describe '#snake_to_camel' do
    it 'converts snake_case to CamelCase recursively' do
      expect({test_one: 'one'}.snake_to_camel).to eq({'TestOne' => 'one'})
      expect({test_one: {test_two: 'two'}}.snake_to_camel).to eq({'TestOne' => {'TestTwo' => 'two'}})
    end
  end
end