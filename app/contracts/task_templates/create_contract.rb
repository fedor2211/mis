module TaskTemplates
  class CreateContract < ApplicationContract
    params do
      required(:title).filled(:string)
      optional(:description).value(:string)
      optional(:periodicity).filled(:string, included_in?: TaskTemplate.periodicities.keys)
      required(:scheduled_at).filled(:date_time)
      optional(:ndays).filled(:integer)
      optional(:month_day).filled(:integer)
      optional(:active_until).filled(:date)
      optional(:tags).array(:string)
      optional(:for_dates).array(:date)
    end

    rule do
      next if values[:for_dates].present?

      if values[:periodicity] == "for_dates"
        key(:for_dates).failure("is required")
        next
      end

      key(:periodicity).failure("is required") if values[:periodicity].blank?
      key(:ndays).failure("must be greater than 0") if values[:periodicity] == "daily" && !positive?(values[:ndays])

      if values[:periodicity] == "monthly" && !valid_month_day?(values[:month_day])
        key(:month_day).failure("must be between 1 and 31")
      end
    end

    rule(:tags) do
      validate_tag_names(key, value) if key?
    end
  end
end
