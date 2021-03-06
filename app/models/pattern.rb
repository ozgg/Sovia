# frozen_string_literal: true

# Dreambook pattern
#
# Attributes:
#   created_at [DateTime]
#   data [JSON]
#   description [Text], optional
#   name [String]
#   processed [Boolean]
#   summary [String], optional
#   updated_at [DateTime]
class Pattern < ApplicationRecord
  include Checkable
  include RequiredUniqueName
  include Toggleable

  DESCRIPTION_LIMIT = 65_535
  NAME_LIMIT = 50
  SUMMARY_LIMIT = 255

  toggleable :processed

  scope :letter, ->(v) { where('name ilike ?', "#{v[0]}%") unless v.blank? }
  scope :search, ->(v) { where("patterns_tsvector(name, summary, description) @@ phraseto_tsquery('russian', ?)", v) unless v.blank? }
  scope :recent, -> { order('id desc') }
  scope :list_for_visitors, -> { ordered_by_name }
  scope :list_for_administration, -> { ordered_by_name }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    list_for_administration.page(page)
  end

  def self.entity_parameters
    %i[description name processed summary]
  end

  # @param [String] name
  def self.[](name)
    find_by('name ilike ?', name)
  end
end
