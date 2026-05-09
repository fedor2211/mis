class TagSerializer < ApplicationSerializer
  attributes :id, :name, :persistent, :created_at, :updated_at
end
