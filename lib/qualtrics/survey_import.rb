module Qualtrics
  class SurveyImport < Entity
    attr_accessor :survey_name, :survey, :survey_data_location, :survey_data_url

    def initialize(options={})
      @survey_name = options[:survey_name]
      @survey_data_location = options[:survey_data_location]
      @survey_data_url = options[:survey_data_url]
      @survey = Qualtrics::Survey.new(survey_name: survey_name)
    end

    def save
      payload = {}
      payload['Name'] = survey.survey_name
      payload['Data'] = Faraday::UploadIO.new(survey_data_location, 'text/plain') unless survey_data_location.blank?
      payload['URL'] = survey_data_url unless survey_data_url.blank?

      response = post 'importSurvey', payload

      if response.success?
        survey.id = response.result['SurveyID']
        true
      else
        false
      end
    end
  end
end
