class AddAttachmentBundleListsToBundlerBundle < ActiveRecord::Migration
  def self.up
    add_column :bundler_bundles, :bundle_lists_file_name, :string
    add_column :bundler_bundles, :bundle_lists_content_type, :string
    add_column :bundler_bundles, :bundle_lists_file_size, :integer
    add_column :bundler_bundles, :bundle_lists_updated_at, :datetime
  end

  def self.down
    remove_column :bundler_bundles, :bundle_lists_file_name
    remove_column :bundler_bundles, :bundle_lists_content_type
    remove_column :bundler_bundles, :bundle_lists_file_size
    remove_column :bundler_bundles, :bundle_lists_updated_at
  end
end
