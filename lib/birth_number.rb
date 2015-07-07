require 'birth_number/version'
require 'date'

# Class representing a Norwegian "Birth Number" ("Fødselsnummer").
#
# A birth number is a national identificaion number used in Norway,
# is unique for each person, and encodes birth date as well as gender.
# The last two digits are used as a checksum to verify a valid
# birth number.
#
# This implementation is based of the description on the Norwegian
# Wikipedia page.
#
# @see https://en.wikipedia.org/wiki/National_identification_number#Norway Birth Number on Wikipedia
# @see https://no.wikipedia.org/wiki/Fødselsnummer Fødselsnummer on Norwegian Wikipedia
class BirthNumber
  BIRTH_NUMBER_REGEX     = /^([0-2][0-9]|3[0-1])(0[1-9]|1[0-2])(\d{7})$/
  BIRTH_NUMBER_WEIGHTS_1 = [3, 7, 6, 1, 8, 9, 4, 5, 2]
  BIRTH_NUMBER_WEIGHTS_2 = [5, 4, 3, 2, 7, 6, 5, 4, 3, 2]

  # Birth Date
  # @return [Date]
  attr_accessor :birth_date

  # Personal Number
  # @return [String]
  attr_accessor :personal_number

  # Parse a 11-digit Birth Number
  #
  # @param [#to_s] birth_number
  # @return [BirthNumber]
  # @raise [ArgumentError] if passed string is not 11 digits or invalid date
  def self.parse(birth_number)
    birth_number = birth_number.to_s
    unless birth_number =~ /^\d{11}$/
      fail ArgumentError, 'Birth number must be 11 digits'
    end

    birth_date = _parse_birth_date(birth_number)

    new(birth_date, birth_number[6, 5])
  end

  # Check if a given birth number is valid
  # @param [#to_s] birth_number
  def self.valid?(birth_number)
    parse(birth_number).valid?

    rescue ArgumentError
      return false
  end

  # @param [#to_date,#to_s] birth_date
  # @param [#to_i] personal_number
  def initialize(birth_date, personal_number)
    if birth_date.respond_to? :to_date
      self.birth_date = birth_date.to_date
    else
      self.birth_date = Date.parse(birth_date.to_s)
    end

    self.personal_number = format('%05d', personal_number.to_i)
  end

  # Check if this birth number is valid
  def valid?
    digits = to_s.chars.map(&:to_i)

    digits.last(2) == control_digits(digits)
  end

  # Is this birth number assigned to a man
  def male?
    personal_number[2].to_i.odd?
  end

  # Is this birth number assigned to a woman
  def female?
    personal_number[2].to_i.even?
  end

  # Formats this birthnumber in the proper 11-digit form
  # @return [String]
  def to_s
    birth_date.strftime('%d%m%y') + format('%05d', personal_number.to_i)
  end

  def ==(other)
    if other.respond_to?(:birth_date) && other.respond_to?(:personal_number)
      birth_date == other.birth_date && personal_number == other.personal_number
    end
  end

  def ===(other)
    to_s == other.to_s
  end

  def eql?(other)
    self == other
  end

  def hash
    to_s.hash
  end

  def self._parse_birth_date(birth_number)
    day, month, year   = birth_number.chars.take(6)
                         .each_slice(2).map(&:join).map(&:to_i)
    individual_numbers = birth_number[6, 3].to_i

    year += _parse_century(year, individual_numbers)

    Date.new(year, month, day)
  end

  def self._parse_century(year, individual_numbers)
    case
    when individual_numbers < 500 || (individual_numbers >= 900 && year >= 40)
      1900
    when individual_numbers < 750 && year >= 54
      1800
    else
      2000
    end
  end

  private_class_method :_parse_birth_date, :_parse_century

  private

  def control_digits(digits)
    [
      control_digit(digits.take(9), BIRTH_NUMBER_WEIGHTS_1),
      control_digit(digits.take(10), BIRTH_NUMBER_WEIGHTS_2)
    ]
  end

  def control_digit(digits, weights)
    control_digit = digits
                    .zip(weights)
                    .map { |digit, weight| digit * weight }
                    .reduce(:+)
    control_digit = 11 - (control_digit % 11)
    control_digit = 0 if control_digit == 11
    control_digit
  end
end
