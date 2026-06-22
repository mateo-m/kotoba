module Kotoba
  module PluralRules
    def self.cardinal(locale, value)
      n = value.to_i
      language = locale.to_s.split("-")[0]

      return "other" if language == "ja" || language == "ko" || language == "zh"
      return russian(n) if language == "ru"
      return arabic(n) if language == "ar"
      return czech(n) if language == "cs" || language == "sk"
      return slovenian(n) if language == "sl"
      return lithuanian(n) if language == "lt"
      return latvian(n) if language == "lv"
      return polish(n) if language == "pl"
      return "one" if language == "fr" && (n == 0 || n == 1)
      return "one" if n == 1
      "other"
    end

    def self.russian(n)
      mod10 = n % 10
      mod100 = n % 100
      return "one" if mod10 == 1 && mod100 != 11
      return "few" if mod10 >= 2 && mod10 <= 4 && !(mod100 >= 12 && mod100 <= 14)
      return "many" if mod10 == 0 || (mod10 >= 5 && mod10 <= 9) || (mod100 >= 11 && mod100 <= 14)
      "other"
    end

    def self.polish(n)
      mod10 = n % 10
      mod100 = n % 100
      return "one" if n == 1
      return "few" if mod10 >= 2 && mod10 <= 4 && !(mod100 >= 12 && mod100 <= 14)
      return "many" if mod10 == 0 || mod10 == 1 || (mod10 >= 5 && mod10 <= 9) || (mod100 >= 12 && mod100 <= 14)
      "other"
    end

    def self.arabic(n)
      mod100 = n % 100
      return "zero" if n == 0
      return "one" if n == 1
      return "two" if n == 2
      return "few" if mod100 >= 3 && mod100 <= 10
      return "many" if mod100 >= 11 && mod100 <= 99
      "other"
    end

    def self.czech(n)
      return "one" if n == 1
      return "few" if n >= 2 && n <= 4
      "other"
    end

    def self.slovenian(n)
      mod100 = n % 100
      return "one" if mod100 == 1
      return "two" if mod100 == 2
      return "few" if mod100 == 3 || mod100 == 4
      "other"
    end

    def self.lithuanian(n)
      mod10 = n % 10
      mod100 = n % 100
      return "one" if mod10 == 1 && mod100 != 11
      return "few" if mod10 >= 2 && mod10 <= 9 && !(mod100 >= 11 && mod100 <= 19)
      "other"
    end

    def self.latvian(n)
      mod10 = n % 10
      mod100 = n % 100
      return "zero" if n == 0
      return "one" if mod10 == 1 && mod100 != 11
      "other"
    end
  end
end
