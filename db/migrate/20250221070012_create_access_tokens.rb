class CreateAccessTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :access_tokens do |t|
      t.string :token, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
