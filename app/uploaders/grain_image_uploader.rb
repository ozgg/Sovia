class GrainImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::BombShelter

  def max_pixel_dimensions
    [4000, 4000]
  end

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id/10000.floor}/#{model.id/100.floor}/#{model.id}"
  end

  process :auto_orient

  def auto_orient
    manipulate! do |image|
      image.tap(&:auto_orient)
    end
  end

  version :big do
    resize_to_fit 640, 640
  end

  version :medium, from_version: :big do
    resize_to_fit 320, 320
  end

  version :small, from_version: :medium do
    resize_to_fit 160, 160
  end

  def extension_white_list
    %w(jpg jpeg)
  end

  def filename
    "#{model.uuid}.jpg" if original_filename
  end
end