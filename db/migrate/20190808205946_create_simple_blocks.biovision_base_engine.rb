# frozen_string_literal: true
# This migration comes from biovision_base_engine (originally 20190326120000)

# Table for simple editable blocks
class CreateSimpleBlocks < ActiveRecord::Migration[5.2]
  def up
    return if SimpleBlock.table_exists?

    create_table :simple_blocks, comment: 'Simple editable block' do |t|
      t.timestamps
      t.boolean :visible, default: true, null: false
      t.boolean :background_image, default: false, null: false
      t.string :slug, index: true, null: false
      t.string :name, index: true
      t.string :image
      t.string :image_alt_text
      t.text :body
    end

    seed_default_blocks
  end

  def down
    drop_table :simple_blocks if SimpleBlock.table_exists?
  end

  private

  def seed_default_blocks
    data = [
      ['counters', 'Счётчики для сайта'],
      ['head_counters_js', 'Счётчики для head с поддержкой JS'],
      ['head_counters_no_js', 'Счётчики для head без JS']
    ]

    data.each do |row|
      SimpleBlock.create(slug: row[0], name: row[1])
    end
  end
end
