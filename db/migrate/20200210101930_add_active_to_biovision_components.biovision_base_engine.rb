# frozen_string_literal: true
# This migration comes from biovision_base_engine (originally 20200203101010)

# Add flag "active" to biovision components table
class AddActiveToBiovisionComponents < ActiveRecord::Migration[5.2]
  def up
    return if column_exists?(:biovision_components, :active)

    add_column :biovision_components, :active, :boolean, default: true, null: false
  end

  def down
    # No rollback needed
  end
end
