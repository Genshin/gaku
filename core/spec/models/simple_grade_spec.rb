require 'spec_helper_models'

describe Gaku::SimpleGrade, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to :simple_grade_type }
    it { is_expected.to belong_to :student }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :simple_grade_type_id }
    it { is_expected.to validate_presence_of :student_id }
    it { is_expected.to validate_presence_of :score }
  end
end
