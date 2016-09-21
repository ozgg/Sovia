require 'fileutils'

namespace :patterns do
  desc 'Load patterns from YAML with deleting old data'
  task load: :environment do
    file_path = "#{Rails.root}/tmp/import/patterns.yml"
    image_dir = "#{Rails.root}/tmp/import/patterns"
    if File.exists? file_path
      puts 'Deleting old patterns...'
      Pattern.destroy_all
      puts 'Done. Importing...'
      File.open file_path, 'r' do |file|
        YAML.load(file).each do |id, data|
          attributes = data.reject { |key| %w(image).include? key }
          pattern    = Pattern.new id: id
          pattern.assign_attributes attributes
          if data.has_key? 'image'
            image_file    = "#{image_dir}/#{id}/#{data['image']}"
            pattern.image = Pathname.new(image_file).open if File.exists?(image_file)
          end
          pattern.save!
          print "\r#{id}    "
        end
        puts
      end
      Pattern.connection.execute "select setval('patterns_id_seq', (select max(id) from patterns));"
      puts "Done. We have #{Pattern.count} patterns now"
    else
      puts "Cannot find file #{file_path}"
    end
  end

  desc 'Dump patterns to YAML'
  task dump: :environment do
    file_path = "#{Rails.root}/tmp/export/patterns.yml"
    image_dir = "#{Rails.root}/tmp/export/patterns"
    ignored   = %w(id image dreams_count comments_count words_count)
    Dir.mkdir image_dir unless Dir.exists? image_dir
    File.open file_path, 'w' do |file|
      Pattern.order('id asc').each do |entity|
        print "\r#{entity.id}    "
        file.puts "#{entity.id}:"
        entity.attributes.reject { |a, v| ignored.include?(a) || v.nil? }.each do |attribute, value|
          file.puts "  #{attribute}: #{value.inspect}"
        end
        unless entity.image.blank?
          image_name = File.basename(entity.image.path)
          Dir.mkdir "#{image_dir}/#{entity.id}" unless Dir.exists? "#{image_dir}/#{entity.id}"
          FileUtils.copy entity.image.path, "#{image_dir}/#{entity.id}/#{image_name}"
          file.puts "  image: #{image_name.inspect}"
        end
      end
      puts
    end
  end
end
