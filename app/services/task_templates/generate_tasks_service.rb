module TaskTemplates
  class GenerateTasksService < ApplicationService
    def initialize(template:, month: Date.current)
      @template = template
      @month = month.to_date
    end

    def call
      tasks = generated_dates.filter_map do |date|
        create_task(date)
      rescue StandardError => error
        log_error("Failed to generate task", error, date: date)
        nil
      end

      { success: true, tasks: tasks }
    end

    private

    attr_reader :template, :month

    def generated_dates
      dates = candidate_dates.select { |date| scheduled_at_for(date) >= Time.current }
      dates = dates.select { |date| date <= template.active_until } if template.active_until
      dates
    end

    def candidate_dates
      dates = case template.periodicity
      when "daily" then month_dates.select { |date| ((date - anchor_date).to_i % template.ndays).zero? }
      when "monthly" then monthly_dates
      when "odd_days" then month_dates.select { |date| date.day.odd? }
      when "even_days" then month_dates.select { |date| date.day.even? }
      when "for_dates" then template.dates.map(&:to_date)
      end

      dates.select { |date| date >= anchor_date }
    end

    def month_dates
      month.beginning_of_month..month.end_of_month
    end

    def monthly_dates
      return [] unless template.month_day <= month.end_of_month.day

      [ Date.new(month.year, month.month, template.month_day) ]
    end

    def anchor_date
      template.created_at.to_date
    end

    def create_task(date)
      scheduled_at = scheduled_at_for(date)
      return if Task.exists?(task_template: template, scheduled_at: scheduled_at)

      Task.transaction do
        Task.create!(
          title: template.title,
          description: template.description,
          scheduled_at: scheduled_at,
          task_template: template
        ).tap { |task| task.tags = template.tags }
      end
    rescue ActiveRecord::RecordNotUnique => error
      log_error("Skipped duplicate generated task", error, date: date, scheduled_at: scheduled_at)
      nil
    end

    def scheduled_at_for(date)
      source_time = template.scheduled_at.in_time_zone
      date.in_time_zone.change(hour: source_time.hour, min: source_time.min)
    end

    def log_error(message, error, date: nil, scheduled_at: nil)
      Rails.logger.error(
        "#{message}: task_template_id=#{template.id.inspect} month=#{month} date=#{date.inspect} " \
        "scheduled_at=#{scheduled_at.inspect} error=#{error.class}: #{error.message}\n" \
        "#{Array(error.backtrace).first(5).join("\n")}"
      )
    end
  end
end
