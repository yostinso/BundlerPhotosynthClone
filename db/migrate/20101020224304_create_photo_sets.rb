class CreatePhotoSets < ActiveRecord::Migration
  def self.up
    create_table :photosets do |t|
      t.references :user
      t.string :name
      t.string :description

      t.timestamps
      change_table :pictures do |t|
        t.references :photoset
      end
    end

  end

  def self.down
    drop_table :photosets
    change_table :pictures do |t|
      t.remove :photoset_id
    end
  end
end
