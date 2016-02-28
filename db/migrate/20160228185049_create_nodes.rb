class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :name
      t.string :summary
      t.integer :section_id
      t.integer :sort
      t.integer :lists_count

      


      t.timestamps null: false
    end
  end
end
