namespace :oneshot do
  desc "Create persistent system tags in production"
  task create_system_tags: :environment do
    Tag::SYSTEM_NAMES.map do |name|
      tag = Tag.find_or_initialize_by(name: name)
      tag.update!(persistent: true)
    end
  end
end
