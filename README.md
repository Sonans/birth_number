# BirthNumber

This is a simple Ruby gem for parsing and validating Birth Numbers, the national identification number used in Norway. It has been extracted from one of our internal projects for reuse, and released as open-source as it might be useful for others as well.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'birth_number'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install birth_number

## Usage

```rb
birth_number = BirthNumber.parse('01017000027')
birth_number.birth_date #=> #<Date: 1970-01-01 ((2440588j,0s,0n),+0s,2299161j)>
birth_number.personal_number # => "00027
birth_number.to_s #=> "01017000027"

birth_number = BirthNumber.new('1970-01-01', '00027')
birth_number.to_s #=> "01017000027"

birth_number.valid? #=> true
birth_number.male? #=> false
birth_number.female? #=> true

birth_number.to_s #=> "01017000027"

birth_number == '01017000027' #=> false
birth_number === '01017000027' #=> true
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Sonans/birth_number.

