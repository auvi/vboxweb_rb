class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.string :filepath
      t.string :status
      t.integer :percent_imported
      t.string :machine_uuid

      t.timestamps
    end
  end
end
