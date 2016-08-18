class CreateTokens < ActiveRecord::Migration[5.0]
  def change
    create_table  :tokens do |t|
      t.integer   :token_type
      t.string    :access_token
      t.string    :refresh_token
      t.datetime  :expires_at
      t.string    :email

      t.integer   :user_id
      t.integer   :mailbox_id

      t.timestamps
    end
  end
end
