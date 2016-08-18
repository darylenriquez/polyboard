class CreateMailboxes < ActiveRecord::Migration[5.0]
  def change
    create_table  :mailboxes do |t|
      t.string    :name
      t.text      :description

      t.integer   :created_by_id

      t.timestamps
    end
  end
end
