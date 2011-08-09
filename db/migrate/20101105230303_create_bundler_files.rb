class CreateBundlerFiles < ActiveRecord::Migration
  def self.up
    create_table :bundler_files do |t|
      t.string :name
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :bundler_files
  end
end
