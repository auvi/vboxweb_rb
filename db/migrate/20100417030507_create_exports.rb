class CreateExports < ActiveRecord::Migration
  def change
    create_table :exports do |t|
      t.string :machine_uuid
      t.string :export_data
      t.string :status
      t.integer :percent_exported

      t.timestamps
    end
  end
end
