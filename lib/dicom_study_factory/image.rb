# frozen_string_literal: true

require 'dicom'
require 'csv'

module DicomStudyFactory
  # It's the dicom object
  # reading with a .dcm file
  class Image
    include DICOM

    class << self
      def csv
        CSV.read('spec/support/dicom_tags.csv', col_sep: ';', headers: true)
      end

      def tags
        @@tags ||= csv.map { |row| [row['Tag'], { vr: row['VR'], name: row['Name'] }] }.to_h
      end
    end

    attr_accessor :required_patient_tags, :required_study_tags, :required_study_id_tags
    attr_reader :dcm

    def initialize(file)
      @dcm = DObject.read(file)
      @required_patient_tags = %w[0010 0020 0030 0040 1010]
      @required_study_tags = %w[0020 0030 0050 0060 1060 0080 0090 1030]
      @required_study_id_tags = %w[0020,0010 0020,000d]
    end

    def tags
      Image.tags
    end

    def patient_tags
      tags.select { |k, _v| k.start_with? '0010' }
    end

    def present_patient_tags
      patient_tags.select { |k, _v| dcm.value(k) }
    end

    def patient_tags_hash
      tag_hash(required_patient_tags, '0010')
    end

    def study_tags_hash
      tag_hash(required_study_tags, '0008')
    end

    def study_id_tags_hash
      tag_hash(required_study_id_tags, '0020')
    end

    private

    def tag_hash(collection, id)
      collection.map do |tag|
        [tag, dcm.value("#{id},#{tag}")]
      end.to_h
    end
  end
end