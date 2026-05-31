require 'rails_helper'

RSpec.describe Paginatable do
  subject(:controller) { controller_class.new }

  let(:controller_class) do
    Class.new do
      include Paginatable

      attr_accessor :params

      def records_for(scope)
        paginate(scope)
      end
    end
  end

  before do
    controller.params = ActionController::Parameters.new(params)
  end

  let(:params) { {} }
  let(:scope) { TodoList.ordered_by_recently_updated }

  describe '#paginate' do
    before do
      12.times { |index| TodoList.create!(name: "List #{index}") }
    end

    it 'uses the calculated page values exactly once to offset and prefetch one extra record' do
      records = (1..6).to_a
      limited_scope = instance_double(ActiveRecord::Relation, to_a: records)
      offset_scope = instance_double(ActiveRecord::Relation)
      fake_scope = instance_double(ActiveRecord::Relation)

      expect(controller).to receive(:current_page).once.and_return(2)
      expect(controller).to receive(:per_page).once.and_return(5)
      expect(fake_scope).to receive(:offset).with(5).and_return(offset_scope)
      expect(offset_scope).to receive(:limit).with(6).and_return(limited_scope)
      expect(limited_scope).to receive(:to_a).and_return(records)

      expect(controller.records_for(fake_scope)).to eq([1, 2, 3, 4, 5])
      expect(controller.instance_variable_get(:@next_page)).to eq(3)
    end

    it 'returns an array, not a relation' do
      expect(controller.records_for(scope)).to be_an(Array)
    end

    it 'returns the first default page and stores pagination state' do
      records = controller.records_for(scope)

      expect(records).to eq(scope.limit(10).to_a)
      expect(controller.instance_variable_get(:@current_page)).to eq(1)
      expect(controller.instance_variable_get(:@per_page)).to eq(10)
      expect(controller.instance_variable_get(:@next_page)).to eq(2)
    end

    context 'with requested page and page size' do
      let(:params) { { page: '2', per_page: '5' } }

      it 'returns the requested page and stores the following page' do
        records = controller.records_for(scope)

        expect(records).to eq(scope.offset(5).limit(5).to_a)
        expect(controller.instance_variable_get(:@current_page)).to eq(2)
        expect(controller.instance_variable_get(:@per_page)).to eq(5)
        expect(controller.instance_variable_get(:@next_page)).to eq(3)
      end
    end

    context 'when there is no following page' do
      let(:params) { { page: '3', per_page: '5' } }

      it 'stores a nil next page' do
        expect(controller.records_for(scope)).to eq(scope.offset(10).limit(5).to_a)
        expect(controller.instance_variable_get(:@next_page)).to be_nil
      end
    end
  end

  describe '#current_page' do
    it 'defaults to the first page' do
      expect(controller.send(:current_page)).to eq(1)
    end

    context 'with a positive page param' do
      let(:params) { { page: '4' } }

      it 'returns the requested page' do
        expect(controller.send(:current_page)).to eq(4)
      end
    end
  end

  describe '#per_page' do
    it 'defaults to ten records per page' do
      expect(controller.send(:per_page)).to eq(10)
    end

    context 'with a positive per_page param' do
      let(:params) { { per_page: '7' } }

      it 'returns the requested page size' do
        expect(controller.send(:per_page)).to eq(7)
      end
    end
  end

  describe '#positive_integer_param' do
    it 'returns the default when the param is missing' do
      expect(controller.send(:positive_integer_param, :page, 9)).to eq(9)
    end

    context 'with a positive integer string' do
      let(:params) { { page: '6' } }

      it 'returns the parsed integer' do
        expect(controller.send(:positive_integer_param, :page, 9)).to eq(6)
      end
    end

    context 'with zero' do
      let(:params) { { page: '0' } }

      it 'returns the default' do
        expect(controller.send(:positive_integer_param, :page, 9)).to eq(9)
      end
    end

    context 'with a negative integer' do
      let(:params) { { page: '-1' } }

      it 'returns the default' do
        expect(controller.send(:positive_integer_param, :page, 9)).to eq(9)
      end
    end

    context 'with a non-integer value' do
      let(:params) { { page: 'wat' } }

      it 'returns the default' do
        expect(controller.send(:positive_integer_param, :page, 9)).to eq(9)
      end
    end
  end
end
