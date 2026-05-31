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

        scope :"ordered_by_#{attr}", ->(direction = :asc) { order_by_timestamp_boolean(attr, direction) } if respond_to?(:scope)
      end
    end

    def order_by_timestamp_boolean(attr, direction = :asc)
      direction = direction.to_sym
      raise ArgumentError, 'direction must be :asc or :desc' unless %i[asc desc].include?(direction)

      timestamp_field = connection.quote_column_name("#{attr}_at")

      order(Arel.sql("CASE WHEN #{quoted_table_name}.#{timestamp_field} IS NULL THEN 0 ELSE 1 END #{direction.to_s.upcase}"))
    end
  end
end
