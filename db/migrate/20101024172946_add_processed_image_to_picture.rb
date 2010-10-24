class AddProcessedImageToPicture < ActiveRecord::Migration
  def self.up
    add_column    :pictures, :processed_image_file_name,    :string
    add_column    :pictures, :processed_image_content_type, :string
    add_column    :pictures, :processed_image_file_size,    :integer
    add_column    :pictures, :processed_image_updated_at,   :datetime
    add_column    :pictures, :processed_image_processing,   :boolean
  end

  def self.down
    remove_column :pictures, :processed_image_file_name
    remove_column :pictures, :processed_image_content_type
    remove_column :pictures, :processed_image_file_size
    remove_column :pictures, :processed_image_updated_at
    remove_column :pictures, :processed_image_processing
  end
end
