namespace :oneshot do
  desc "Create persistent system tags in production"
  task create_system_tags: :environment do
    abort "This task is intended for production only" unless Rails.env.production?

    Tags::EnsureSystemTagsService.call
  end
end
