class BundlerFileHasBundle < ActiveRecord::Migration
  def self.up
    change_table :bundler_files do |t|
      t.references :bundler_bundle
    end
  end

  def self.down
    remove_column :bundler_files, :bundler_bundle_id
  end
end
