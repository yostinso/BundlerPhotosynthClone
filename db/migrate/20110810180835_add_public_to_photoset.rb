class AddPublicToPhotoset < ActiveRecord::Migration
  def self.up
    add_column :photosets, :public, :boolean, :default => false
  end

  def self.down
    remove_column :photosets, :public
  end
end
