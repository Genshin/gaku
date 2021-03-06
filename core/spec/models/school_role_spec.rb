require 'spec_helper_models'

describe Gaku::SchoolRole, type: :model do
  describe 'relations' do
    it { is_expected.to belong_to :school_rolable }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_uniqueness_of :name }
  end

  describe '#to_s' do
    let(:school_role) { build(:school_role) }

    specify { school_role.to_s.should eq school_role.name }
  end
end
