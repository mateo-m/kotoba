module RGSSI18n
  module PluralRules
    def self.cardinal(locale, value)
      n = value.to_i
      language = locale.to_s.split("-")[0]

      return "other" if language == "ja" || language == "ko" || language == "zh"
      return russian(n) if language == "ru"
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
  end
end
