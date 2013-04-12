module Sequel
  module Plugins
    module Localization
      def self.configure(model, opts={})
        model._init_translations
      end
      module ClassMethods
        def _init_translations
          @_lowercase_name = underscore(demodulize(self.to_s))
          create_translation_class
          localized_fields.each do |field_name|
            self.class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
            def #{field_name}(locale = I18n.site_locale)
              (translation(locale) || translation(default_locale)).#{field_name}
            end
            def #{field_name}=(value, locale)
              if translation_exists?(locale) || !value.blank? || value == false
                translation(locale).#{field_name}= value
              end
            end
            RUBY
          end
        end
        def create_translation_class
          one_to_many :"#{@_lowercase_name}_translations"
          alias_method :translations, :"#{@_lowercase_name}_translations_dataset"
          self.class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          class ::#{self}Translation < Sequel::Model
            many_to_one :#{@_lowercase_name}
            many_to_one :language
          end
          RUBY
        end
        def localized_fields
          @localized_fields ||= translation_class.columns - [translation_class.primary_key, :"#{@_lowercase_name}_id", :language_id]
        end
        def translation_class
          @translation_class ||= Object.const_get("#{self}Translation")
        end
        # @param [String, Symbol] action The action to create the accessor for. Only works if action is a locale accessor
        #
        # @return [TrueClass, FalseClass] If the accessor has been created
        def create_translation_accessor(action)
          match = action.to_s.match(/^([a-z]{2})=?$/)
          return false unless match
          lang = match[1]
          if lang && Language[lang]
            create_translation_writer(lang)
            create_translation_reader(lang)
            return true
          end
        end

        # @param [String] locale The locale to create the writer for
        def create_translation_writer(locale)
          self.class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          def #{locale}=(attributes = {})
            attributes.each{|method, value| self.send("\#{method}=", value, :#{locale}) }
          end
          RUBY
                                                  end

      # @param [String] locale The locale to create the reader for
      def create_translation_reader(locale)
        self.class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          def #{locale}
            translation(:#{locale})
                      end
        RUBY
      end

      end
      module InstanceMethods
        # Creates a new translation accessor if necessary
        # @see #create_translation_accessor
        def method_missing(action,*args)
          if self.class.create_translation_accessor(action)
            self.send(action, *args)
          else
            super
          end
        end
        def default_locale
          'de'
        end
        def translation(locale)
          translations.where(:language_id => Language.find(:code => locale.to_s).id).first
        end
      end
    end
  end
end
