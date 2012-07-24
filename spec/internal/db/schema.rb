ActiveRecord::Schema.define do
  create_table "users", :force => true do |t|
    t.string "name",        :null => false
    t.string "uid",         :null => false
    t.string "email",       :null => false
    t.boolean "remotely_signed_out"
    t.text   "permissions"
  end
end