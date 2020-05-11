# frozen_string_literal: true

ActiveRecord::Schema.define do
  # Set up any tables you need to exist for your test suite that don't belong
  # in migrations.
  create_table "users", :force => true do |t|
    t.string "name",        :null => false
    t.string "uid",         :null => false
    t.string "email",       :null => false
    t.boolean "remotely_signed_out"
    t.text   "permissions"
    t.string "organisation_slug"
    t.string "organisation_content_id"
    t.boolean "disabled",  :default => false
  end
end
