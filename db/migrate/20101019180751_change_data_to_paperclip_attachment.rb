class ChangeDataToPaperclipAttachment < ActiveRecord::Migration
  def self.up
    remove_column :pictures, :data
    add_column    :pictures, :image_file_name,    :string
    add_column    :pictures, :image_content_type, :string
    add_column    :pictures, :image_file_size,    :integer
    add_column    :pictures, :image_updated_at,   :datetime
  end

  def self.down
    add_column    :pictures, :data,               :text
    remove_column :pictures, :image_file_name
    remove_column :pictures, :image_content_type
    remove_column :pictures, :image_file_size
    remove_column :pictures, :image_updated_at
  end
end
