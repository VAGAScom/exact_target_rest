require 'spec_helper'

describe String do
  describe '#snake_to_camel' do
    it 'converts snake_case to CamelCase' do
      expect('test'.snake_to_camel).to eq 'Test'
      expect('test_123'.snake_to_camel).to eq 'Test123'
      expect('test_uga'.snake_to_camel).to eq 'TestUga'
      expect('TEST'.snake_to_camel).to eq 'TEST'
      expect('TEST_UGA'.snake_to_camel).to eq 'TESTUGA'
      expect('test_ID'.snake_to_camel).to eq 'TestID'
    end
  end
end