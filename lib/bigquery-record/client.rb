require 'bigquery-client'

module BigQueryRecord
  BigQuery::Client.send(:attr_accessor, :dataset, :email, :private_key_path, :project) # monkey patch for dataset

  # TODO: move to config
  Client = BigQuery::Client.new(
    project: ENV['BIGQUERY_RECORD_PROJECT'],
    dataset: ENV['BIGQUERY_RECORD_DATASET'],
    email: ENV['BIGQUERY_RECORD_EMAIL'],
    private_key_path: ENV['BIGQUERY_KEY_PATH'],
    private_key_passphrase: "notasecret",
    auth_method: "private_key"
  )
end
