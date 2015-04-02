require 'spec_helper'

describe DataExtParams do
  describe '#to_data_extension' do
    it 'converts an Array of Hashes based on key field' do
      expect(DataExtParams.new(:uga).transform([{uga: 1, buga: 2}, {uga: 3, buga: 4}])).
          to eq [{keys: {'Uga' => 1}, values: {'Buga' => 2}},
                 {keys: {'Uga' => 3}, values: {'Buga' => 4}}]
    end
    it 'converts an Array of Hashes based on key_field with no snake_to_camel' do
      expect(DataExtParams.new(:uga, snake_to_camel: false).transform([{uga: 1, buga: 2}, {uga: 3, buga: 4}])).
          to eq [{keys: {uga: 1}, values: {buga: 2}},
                 {keys: {uga: 3}, values: {buga: 4}}]
    end
    it 'converts a simple Hash' do
      expect(DataExtParams.new(:uga).transform(uga: 1, buga: 2)).
          to eq [{keys: {'Uga' => 1}, values: {'Buga' => 2}}]
    end
    it 'converts with multiple key fields' do
      expect(DataExtParams.new('uga', 'buga').transform(uga: 1, buga: 2, turuga: 3, kabuga: 4)).
          to eq [{keys: {'Uga' => 1, 'Buga' => 2}, values: {'Turuga' => 3, 'Kabuga' => 4}}]
    end
  end
end