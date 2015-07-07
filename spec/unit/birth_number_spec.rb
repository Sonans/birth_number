require 'birth_number'
require 'date'

VALID_BIRTH_NUMBERS   = %w(01017000027 12056647528 09063725843)
INVALID_BIRTH_NUMBERS = %w(01017000000 99999999999 23)

MALE_BIRTH_NUMBERS   = %w(06044530323 02028325544 17071942961)
FEMALE_BIRTH_NUMBERS = %w(02057048010 16021002872 06090018203)

HISTORIC_BIRTH_NUMBERS       = %w(11067760303 04078173039 30098454744)
PRE_EPOCH_BIRTH_NUMBERS      = %w(26013207819 24055102798 27065923713)
PRE_MILLENIA_BIRTH_NUMBERS   = %w(07067816387 22108720631 04019822821)
POST_MILLENNIA_BIRTH_NUMBERS = %w(26030291270 18070582364 14041163918)

RSpec.describe BirthNumber do
  describe '.initialize' do
    it 'creates a new BirthNumber when passed a Date object' do
      expect(described_class.new(Date.new(1970, 1, 1), '00027')).to be_instance_of described_class
    end

    it 'creates a new BirthNumber when passed a date string' do
      expect(described_class.new('1970-01-01', '00027')).to be_instance_of described_class
    end
  end

  describe '.valid?' do
    VALID_BIRTH_NUMBERS.each do |birth_number|
      it "is true for \"#{birth_number}\"" do
        expect(described_class.valid? birth_number).to be true
      end
    end

    INVALID_BIRTH_NUMBERS.each do |birth_number|
      it "is false for \"#{birth_number}\"" do
        expect(described_class.valid? birth_number).to be false
      end
    end
  end

  describe '.to_s' do
    it 'correctly formats the birth number' do
      expect(described_class.new(Date.new(1970, 1, 1), '00027').to_s).to eq '01017000027'
    end
  end

  describe '.parse' do
    VALID_BIRTH_NUMBERS.each do |birth_number|
      it "successfully parses \"#{birth_number}\"" do
        expect(described_class.parse(birth_number)).to_not be_nil
      end
    end

    it 'parses the birth date of "01017000027" to "1970-01-01"' do
      birth_number = described_class.parse('01017000027')
      expect(birth_number.birth_date).to eq Date.new(1970, 01, 01)
    end

    POST_MILLENNIA_BIRTH_NUMBERS.each do |birth_number|
      it "parses the birth year as 20XX for #{birth_number}" do
        expect(BirthNumber.parse(birth_number).birth_date.year).to be_between(2000, 2039)
      end
    end

    (PRE_EPOCH_BIRTH_NUMBERS + PRE_MILLENIA_BIRTH_NUMBERS).each do |birth_number|
      it "parses the birth year as 19XX for #{birth_number}" do
        expect(BirthNumber.parse(birth_number).birth_date.year).to be_between(1900, 1999)
      end
    end

    HISTORIC_BIRTH_NUMBERS.each do |birth_number|
      it "parses the birth year as 18XX for #{birth_number}" do
        expect(BirthNumber.parse(birth_number).birth_date.year).to be_between(1854, 1899)
      end
    end
  end

  describe '#male?' do
    MALE_BIRTH_NUMBERS.each do |birth_number|
      it "is true for \"#{birth_number}\"" do
        expect(BirthNumber.parse(birth_number)).to be_male
      end
    end

    FEMALE_BIRTH_NUMBERS.each do |birth_number|
      it "is false for \"#{birth_number}\"" do
        expect(BirthNumber.parse(birth_number)).to_not be_male
      end
    end
  end

  describe '#female?' do
    FEMALE_BIRTH_NUMBERS.each do |birth_number|
      it "is true for \"#{birth_number}\"" do
        expect(BirthNumber.parse(birth_number)).to be_female
      end
    end

    MALE_BIRTH_NUMBERS.each do |birth_number|
      it "is false for \"#{birth_number}\"" do
        expect(BirthNumber.parse(birth_number)).to_not be_female
      end
    end
  end

  describe '==' do
    it 'is true for the same birth number' do
      expect(described_class.parse('01017000027')).to eq described_class.parse('01017000027')
    end

    it 'is false for a different birth number' do
      expect(described_class.parse('01017000027')).to_not eq described_class.parse('12056647528')
    end
  end

  describe '===' do
    it 'is true for the same birth number given as a string' do
      expect(described_class.parse('01017000027')).to satisfy { |value| value === '01017000027' }
    end
  end

  describe 'eql?' do
    it 'is true for the same birth number' do
      expect(described_class.parse('01017000027')).to eql described_class.parse('01017000027')
    end

    it 'is false for a different birth number' do
      expect(described_class.parse('01017000027')).to_not eql described_class.parse('12056647528')
    end
  end
end
