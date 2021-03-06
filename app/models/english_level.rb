class EnglishLevel < ApplicationRecord
  belongs_to :englishable, polymorphic: true

  enum english_level: %i[none basic intermediate advanced fluent],
       _suffix: true

  def to_s
    english_level
  end
end
