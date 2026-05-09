class ApplicationSerializer < ActiveModel::Serializer
  def attributes(*args)
    hash = super

    hash.each do |key, value|
      if value.is_a?(ActiveSupport::TimeWithZone) || value.is_a?(Time) || value.is_a?(Date)
        hash[key] = value.iso8601
      end
    end

    hash
  end
end
