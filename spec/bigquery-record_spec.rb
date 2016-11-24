require "spec_helper"

describe BigQueryRecord do
  it "has a version number" do
    expect(BigQueryRecord::VERSION).not_to be nil
  end
end
