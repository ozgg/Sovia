class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :agent, index: true, foreign_key: true
      t.inet :ip
      t.timestamps null: false
      t.integer :rating, null: false, default: 0
      t.integer :upvote_count, null: false, default: 0
      t.integer :downvote_count, null: false, default: 0
      t.integer :comments_count, null: false, default: 0
      t.boolean :answered, null: false, default: false
      t.boolean :locked, null: false, default: false
      t.boolean :deleted, null: false, default: false
      t.text :body, null: false
    end
  end
end
