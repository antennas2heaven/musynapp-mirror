class Image < ActiveRecord::Base
  has_attached_file :upload, styles: { thumb: '150x150' }
  belongs_to :imageable, polymorphic: true

  validates_attachment_content_type :upload, content_type: %w(image/gif image/jpeg image/png)
  validate :dont_exceed_limit

  include Rails.application.routes.url_helpers

  def to_jq_upload
    {
      "name" => read_attribute(:upload_file_name),
      "size" => read_attribute(:upload_file_size),
      "url" => upload.url(:thumb),
      "content_type" => upload_content_type, 
      "delete_url" => upload_path(:id => id, type: 'image')
    }
  end

  def dont_exceed_limit
    errors.add(:upload, 'Only 3 images allowed') if self.imageable.images.count >= 3 
  end
end
