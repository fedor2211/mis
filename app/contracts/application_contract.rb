class ApplicationContract < Dry::Validation::Contract
  private

  def validate_tag_names(key, names)
    key.failure("must not include blank names") if names.any?(&:blank?)

    missing_names = names.uniq - Tag.where(name: names).pluck(:name)
    key.failure("contains unknown tags: #{missing_names.join(', ')}") if missing_names.any?
  end

  def tag_name_taken?(name, except_id: nil)
    relation = Tag.where(name: name.downcase)
    relation = relation.where.not(id: except_id) if except_id
    relation.exists?
  end

  def positive?(value)
    value.present? && value.positive?
  end

  def valid_month_day?(value)
    value.present? && value.between?(1, 31)
  end

  def validate_future_datetime(key, value)
    key.failure("must be greater than current datetime") if value && value.to_time <= Time.current
  end
end
