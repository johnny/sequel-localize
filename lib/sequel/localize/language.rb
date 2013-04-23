class Language < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:code, :name]
    validates_unique :code
    # locale string like 'en'
    validates_format /^[a-z]{2}$/, :code
  end

  def after_create
    Sequel::Plugins::Localize.localized_models.each do |m|
      m.add_translation_accessors code
    end
  end

  class << self
    def [](code)
      if code.respond_to? :to_sym
        code = code.to_sym
        (@cache ||= {})[code] ||= super(:code => code.to_s) || create(:code => code, :name => code)
      else
        super
      end
    end
  end
end
