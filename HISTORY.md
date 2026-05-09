# History
## 1
/init

## 2
add rspec and factory_bot for this project, also update AGENTS.md

## 3
Build an api for task tracker in medical information system. Responses should have json format.
Technical details and preferred stack:
1. Validation logic should be placed in dry contract (dry-validation + dry-schema)
2. Don't bloat models and controllers with business-logic, move it to service objects, base class for service should look like this:
   ```ruby
   class ApplicationService
     def self.call(*)
	   new(*).call
	 end

	 def call
	   raise NotImplementedError
	 end
   end
   ```
1. For serializers use base class:
   ```ruby
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
   ```
### Step 1
Create basic CRUD for tasks. It should have next actions: create, update, destroy, show and list. List should have filters by date (scheduled_at and created_at) and status.
#### Model and migration
Model should be named Task. It should have basic fields (id and timestamps) and core fields:

| Name         | Type     | Null  | Default      | Index |
| ------------ | -------- | ----- | ------------ | ----- |
| title        | string   | false |              | false |
| description  | string   | false | empty string | false |
| scheduled_at | datetime | false |              | true  |
| status       | integer  | false | 0            | true  |
Status should be enum and have next values - new (default), in_progress, completed, cancelled. Integer values should be used only inside application, responses should return their string values.
