class CreateBundlerBundles < ActiveRecord::Migration
  def self.up
    create_table :bundler_bundles do |t|
      t.references :photoset
      t.string :arguments

      t.timestamps
    end
  end

  def self.down
    drop_table :bundler_bundles
  end
end
