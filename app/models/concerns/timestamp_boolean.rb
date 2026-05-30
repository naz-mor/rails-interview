module TimestampBoolean
  extend ActiveSupport::Concern

  module ClassMethods
    def timestamp_boolean(*attrs)
      attrs.each do |attr|
        timestamp_field = :"#{attr}_at"

        define_method(:"#{attr}?") do
          public_send(timestamp_field).present?
        end

        define_method(:"#{attr}=") do |value|
          if ActiveModel::Type::Boolean.new.cast(value)
            public_send(:"#{timestamp_field}=", public_send(timestamp_field) || Time.current)
          else
            public_send(:"#{timestamp_field}=", nil)
          end
        end
      end
    end
  end
end
