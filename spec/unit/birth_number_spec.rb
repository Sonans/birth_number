require 'birth_number'
require 'date'
require 'csv'

RSpec.describe BirthNumber do
  where do
    table = CSV.read File.expand_path('birth_numbers.csv', __dir__),
                     headers: true,
                     skip_blanks: true,
                     header_converters: :symbol

    rows = table.map do |row|
      hsh         = row.to_hash
      hsh[:valid] = hsh[:valid] == 'true'
      hsh[:date]  = Date.parse(hsh[:date])

      ["with birth number #{row[:birth_number]}", hsh]
    end

    rows.to_h
  end

  with_them do
    describe '.new' do
      let(:personal_number) { birth_number[-5, 5] }

      context 'with valid date object as argument' do
        subject { described_class.new(date, personal_number)}
        it do
          expect { described_class.new(date, personal_number) }
            .to_not raise_error
        end

        it do
          is_expected.to have_attributes birth_date: be_a(Date),
                                         personal_number: be_a(String)
        end
      end

      context 'with valid date string as argument' do
        subject { described_class.new(date.to_s, personal_number) }
        it do
          expect { described_class.new(date.to_s, personal_number) }
            .to_not raise_error
        end

        it do
          is_expected.to have_attributes birth_date: be_a(Date),
                                         personal_number: be_a(String)
        end
      end
    end

    describe '.valid?' do
      subject { described_class.valid? birth_number }

      it { is_expected.to be valid }
    end

    describe '#valid?' do
      subject { described_class.parse(birth_number).valid? }

      it { is_expected.to be valid }
    end

    describe '.parse' do
      subject { described_class.parse(birth_number) }

      it { is_expected.to be_an described_class }
    end

    describe '#to_s' do
      subject { described_class.parse(birth_number).to_s }

      it { is_expected.to eq birth_number }
    end

    describe '#birth_date' do
      subject { described_class.parse(birth_number).birth_date }

      it { is_expected.to eq date }
    end

    describe '#male?' do
      let(:male?) { sex == 'm' }
      subject { described_class.parse(birth_number).male? }

      it { is_expected.to eq male? }
    end

    describe '#female?' do
      let(:female?) { sex == 'f' }
      subject { described_class.parse(birth_number).female? }

      it { is_expected.to eq female? }
    end

    describe '#to_hash' do
      let(:personal_number) { birth_number[-5, 5] }
      subject { described_class.parse(birth_number).to_hash }

      it { is_expected.to be_an Hash }
      it do
        is_expected.to eq({ birth_date: date, personal_number: personal_number })
      end
    end
  end

  context 'instance object' do
    let(:birth_number) { '01017000027' }
    let(:same_birth_number) { birth_number }
    let(:other_birth_number) { '12056647528' }

    subject { described_class.parse(birth_number) }

    it do
      is_expected.to satisfy do |birth_number|
        birth_number == described_class.parse(same_birth_number)
      end
    end
    it do
      is_expected.to_not satisfy do |birth_number|
        birth_number == described_class.parse(other_birth_number)
      end
    end

    it do
      is_expected.to satisfy do |birth_number|
        birth_number === same_birth_number
      end
    end
    it do
      is_expected.to_not satisfy do |birth_number|
        birth_number === other_birth_number
      end
    end

    it do
      is_expected.to satisfy do |birth_number|
        birth_number.eql? described_class.parse(same_birth_number)
      end
    end
    it do
      is_expected.to_not satisfy do |birth_number|
        birth_number.eql? described_class.parse(other_birth_number)
      end
    end
  end

  context 'with invalid birth number' do
    where do
      {
        '(too short)' => { birth_number: '010170' },
        '(too long)'  => { birth_number: '010170000000' },
        '(bad date)'  => { birth_number: '0' * 11 }
      }
    end

    with_them do
      it do
        expect { described_class.parse birth_number }
          .to raise_error ArgumentError
      end
    end
  end
end
