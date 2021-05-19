require 'spec_helper'

describe InteractionEventParams do
  describe '#to_interaction_event' do
    describe 'accepts different params:' do
      it 'Hash' do
        expect(InteractionEventParams.new.transform({ field_one: 1, field_two: 2 }))
          .to eq({:Data => {:field_one => 1, :field_two => 2}})
      end
      it 'keyword arguments' do
        expect(InteractionEventParams.new.transform(field_one: 1, field_two: 2))
          .to eq({:Data => {:field_one => 1, :field_two => 2}})
      end
    end

    it 'returns defined keys in top level' do
      expect(InteractionEventParams.new(:field_one, :field_two).transform(field_one: 1, field_two: 1))
        .to eq({:FieldOne => 1, :FieldTwo => 1})
    end

    it 'returns Data if other fields present' do
      expect(InteractionEventParams.new(:field_one).transform(field_one: 1, field_two: 1))
        .to eq({:FieldOne => 1, :Data => {:field_two => 1}})
    end

    it 'moves additional field to Data' do
      payload = {
        contact_key: 'unique',
        event_definition_key: 'uuid for event',
        email: "foobar@example.com",
        subscriberkey: 'subscriber-key',
        HS_reg_date: 'ISO-8601 datetime string',
        first_name: 'John',
        business_name: 'Awesomeness'
      }

      result = {
        ContactKey: 'unique',
        EventDefinitionKey: 'uuid for event',
        Data: {
          email: "foobar@example.com",
          subscriberkey: 'subscriber-key',
          HS_reg_date: 'ISO-8601 datetime string',
          first_name: 'John',
          business_name: 'Awesomeness'
        }
      }

      expect(InteractionEventParams.new(:contact_key, :event_definition_key).transform(payload)).to eq result
    end
  end
end
