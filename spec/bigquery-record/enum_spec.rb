require "spec_helper"

describe BigQueryRecord::Enum do
  class EnumSample
    extend BigQueryRecord::Enum
    enum enum_field: { foo: 1, bar: 2 }
  end

  describe '#enum_field_name' do
    let(:record) { EnumSample.new.tap{|sample| sample.enum_field = 1} }
    subject { record.enum_field_name }
    it { should eq :foo }
  end

  describe '.enum_fields' do
    subject { EnumSample.enum_fields }
    it { should eq foo: 1, bar: 2 }
  end
end
