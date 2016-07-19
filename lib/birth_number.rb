# frozen-string-literal: true
require 'birth_number/version'
require 'date'
require 'dry-equalizer'

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
# @see https://en.wikipedia.org/wiki/National_identification_number#Norway
#   Birth Number on Wikipedia
# @see https://no.wikipedia.org/wiki/Fødselsnummer
#   Fødselsnummer on Norwegian Wikipedia
#
# @author Jo-Herman Haugholt <jo-herman@sonans.no>
class BirthNumber
  include Dry::Equalizer(:birth_date, :personal_number)

  # Birth Date
  # @return [Date]
  attr_reader :birth_date

  # Personal Number
  # @return [String]
  attr_reader :personal_number

  # Parse a 11-digit Birth Number
  #
  # @param [#to_s] birth_number
  # @return [BirthNumber]
  # @raise [ArgumentError] if passed string is not 11 digits or invalid date
  def self.parse(birth_number)
    birth_number = birth_number.to_s
    unless birth_number =~ /^\d{11}$/
      raise ArgumentError, 'Birth number must be 11 digits'
    end

    birth_date = parse_birth_date(birth_number)

    new(birth_date, birth_number[6, 5])
  end

  # Check if a given birth number is valid
  # @param [#to_s] birth_number
  def self.valid?(birth_number)
    digits = birth_number.to_s.chars.map(&:to_i)

    digits.last(2) == control_digits(digits)

  rescue ArgumentError
    return false
  end

  # @param [#to_date,#to_s] birth_date
  # @param [#to_i] personal_number
  def initialize(birth_date, personal_number)
    @birth_date = if birth_date.respond_to? :to_date
                    birth_date.to_date
                  else
                    Date.parse(birth_date.to_s)
                  end

    @personal_number = format('%05d', personal_number.to_i)
  end

  # Check if this birth number is valid
  def valid?
    BirthNumber.valid?(self)
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

  def to_hash
    {
      birth_date: birth_date,
      personal_number: personal_number
    }
  end
  alias_method :to_h, :to_hash

  def ===(other)
    to_s == other.to_s
  end

  # @!group Private Class Methods
  BIRTH_NUMBER_REGEX     = /^([0-2][0-9]|3[0-1])(0[1-9]|1[0-2])(\d{7})$/
  BIRTH_NUMBER_WEIGHTS_1 = [3, 7, 6, 1, 8, 9, 4, 5, 2].freeze
  BIRTH_NUMBER_WEIGHTS_2 = [5, 4, 3, 2, 7, 6, 5, 4, 3, 2].freeze

  # Parses the date part of a birth number
  # @param [String] birth_number
  # @return [Date]
  def self.parse_birth_date(birth_number)
    day, month, year   = birth_number.chars.take(6).each_slice(2)
                                     .map(&:join).map(&:to_i)
    individual_numbers = birth_number[6, 3].to_i

    year += parse_century(year, individual_numbers)

    Date.new(year, month, day)
  end

  # Calculates the century of a year based on the individual numbers
  # @param [Integer] year
  # @param [Integer] individual_numbers
  # @return [Integer]
  def self.parse_century(year, individual_numbers)
    if individual_numbers < 500 || (individual_numbers >= 900 && year >= 40)
      1900
    elsif individual_numbers < 750 && year >= 54
      1800
    else
      2000
    end
  end

  # Calculates the two control digits given an array of digits
  # @param [Array<Integer>] digits
  # @return [(Integer, Integer)]
  def self.control_digits(digits)
    [
      control_digit(digits.take(9), BIRTH_NUMBER_WEIGHTS_1),
      control_digit(digits.take(10), BIRTH_NUMBER_WEIGHTS_2)
    ]
  end

  # Calculates the control digit, given an array of digits and weights.
  # @param [Array<Integer>] digits
  # @param [Array<Integer>] weights
  # @return [Integer]
  def self.control_digit(digits, weights)
    control_digit = digits
                    .zip(weights)
                    .map { |digit, weight| digit * weight }
                    .reduce(:+)
    control_digit = 11 - (control_digit % 11)
    control_digit = 0 if control_digit == 11
    control_digit
  end

  private_constant :BIRTH_NUMBER_REGEX,
                   :BIRTH_NUMBER_WEIGHTS_1,
                   :BIRTH_NUMBER_WEIGHTS_2
  private_class_method :parse_birth_date,
                       :parse_century,
                       :control_digits,
                       :control_digit
end
