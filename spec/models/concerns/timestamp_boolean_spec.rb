require 'rails_helper'

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

  describe '.timestamp_boolean' do
    let(:active_record_class) do
      Class.new(ApplicationRecord) do
        self.table_name = 'todo_items'

        include TimestampBoolean

        timestamp_boolean :completed
      end
    end

    it 'defines a timestamp-backed ordering scope on Active Record models' do
      expect(active_record_class).to respond_to(:ordered_by_completed)
    end

    it 'orders records with nil timestamps before present timestamps by default' do
      todo_list = TodoList.create!(name: 'My List')
      incomplete = active_record_class.create!(name: 'Incomplete', todo_list_id: todo_list.id)
      complete = active_record_class.create!(name: 'Complete', todo_list_id: todo_list.id, completed_at: Time.current)

      expect(active_record_class.ordered_by_completed.to_a).to eq([incomplete, complete])
    end

    it 'orders records with present timestamps before nil timestamps when descending' do
      todo_list = TodoList.create!(name: 'My List')
      incomplete = active_record_class.create!(name: 'Incomplete', todo_list_id: todo_list.id)
      complete = active_record_class.create!(name: 'Complete', todo_list_id: todo_list.id, completed_at: Time.current)

      expect(active_record_class.ordered_by_completed(:desc).to_a).to eq([complete, incomplete])
    end

    it 'uses ascending order when the generated scope is called without a direction' do
      expect(active_record_class.ordered_by_completed.to_sql).to include('END ASC')
    end

    it 'passes the generated scope direction to the timestamp ordering method' do
      allow(active_record_class).to receive(:order_by_timestamp_boolean).with(:completed, :desc).and_call_original

      active_record_class.ordered_by_completed(:desc).load

      expect(active_record_class).to have_received(:order_by_timestamp_boolean).with(:completed, :desc)
    end
  end

  describe '.order_by_timestamp_boolean' do
    it 'quotes the requested timestamp column and uses the requested direction' do
      relation = TodoItem.order_by_timestamp_boolean(:completed, :desc)

      expect(relation.to_sql).to include('"todo_items"."completed_at" IS NULL')
      expect(relation.to_sql).to include('END DESC')
    end

    it 'uses ascending order by default' do
      expect(TodoItem.order_by_timestamp_boolean(:completed).to_sql).to include('END ASC')
    end

    it 'accepts string directions' do
      relation = TodoItem.order_by_timestamp_boolean(:completed, 'asc')

      expect(relation.to_sql).to include('END ASC')
    end

    it 'rejects unsupported directions' do
      expect { TodoItem.order_by_timestamp_boolean(:completed, :sideways) }.to raise_error(
        ArgumentError,
        'direction must be :asc or :desc'
      )
    end
  end
end
