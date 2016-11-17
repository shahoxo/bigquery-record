require "spec_helper"

describe BigQueryRecord::Base do
  subject { ActionLog.search(time_from: Time.parse("2016-11-04"), time_to: Time.parse("2016-11-06"), limit: 10).result }
  it { should be_present }
  it { should all(be_a ActionLog) }
end