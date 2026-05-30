require 'active_support/all'
require 'active_model'
require_relative '../../../app/models/concerns/timestamp_boolean'

RSpec.describe TimestampBoolean do
  subject(:record) { model_class.new }

  let(:model_class) do
    Class.new do
      include TimestampBoolean

      attr_accessor :published_at, :archived_at

      timestamp_boolean :published, :archived
    end
  end

  describe '#published?' do
    it 'returns false when the timestamp is nil' do
      expect(record.published?).to be(false)
    end

    it 'returns true when the timestamp is present' do
      record.published_at = Time.current

      expect(record.published?).to be(true)
    end
  end

  describe '#published=' do
    it 'sets the timestamp when assigned a truthy boolean value' do
      now = Time.utc(2026, 5, 30, 12, 0, 0)
      allow(Time).to receive(:current).and_return(now)

      record.published = '1'

      expect(record.published_at).to eq(now)
    end

    it 'clears the timestamp when assigned a falsey boolean value' do
      record.published_at = Time.current

      record.published = '0'

      expect(record.published_at).to be_nil
    end

    it 'does not overwrite an existing timestamp when assigned a truthy value again' do
      original_time = Time.utc(2026, 5, 29, 12, 0, 0)
      record.published_at = original_time
      allow(Time).to receive(:current).and_return(Time.utc(2026, 5, 30, 12, 0, 0))

      record.published = true

      expect(record.published_at).to eq(original_time)
    end
  end

  describe '#archived?' do
    it 'is defined for additional attributes' do
      record.archived_at = Time.current

      expect(record.archived?).to be(true)
    end
  end

  describe '#archived=' do
    it 'writes to the matching timestamp field for additional attributes' do
      now = Time.utc(2026, 5, 30, 12, 0, 0)
      allow(Time).to receive(:current).and_return(now)

      record.archived = true

      expect(record.archived_at).to eq(now)
      expect(record.published_at).to be_nil
    end
  end
end
