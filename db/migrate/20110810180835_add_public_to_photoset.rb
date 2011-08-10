class AddPublicToPhotoset < ActiveRecord::Migration
  def self.up
    add_column :photosets, :public, :boolean
  end

  def self.down
    remove_column :photosets, :public
  end
end
