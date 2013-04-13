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
          create_translated_field_methods
          create_translation_accessors
        end
        def localized_fields
          @localized_fields ||= translation_class.columns - [translation_class.primary_key, :"#{@_lowercase_name}_id", :language_id]
        end
        def translation_class
          @translation_class ||= Object.const_get("#{self}Translation")
        end
        protected
        def create_translation_class
          one_to_many :"#{@_lowercase_name}_translations"
          alias_method :translations_dataset, :"#{@_lowercase_name}_translations_dataset"
          alias_method :translations, :"#{@_lowercase_name}_translations"
          alias_method :add_translation, :"add_#{@_lowercase_name}_translation"
          self.class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          class ::#{self}Translation < Sequel::Model
            many_to_one :#{@_lowercase_name}
            many_to_one :language
          end
          RUBY
        end
        def create_translated_field_methods
          localized_fields.each do |field_name|
            self.class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
            def #{field_name}(locale = I18n.site_locale)
              (translation(locale) || translation(default_locale)).#{field_name}
            end
            def #{field_name}=(value, locale)
              if translation_exists?(locale) || !_is_default(value)
                translation(locale).#{field_name}= value
              end
            end
            RUBY
          end
        end
        # @param [String, Symbol] action The action to create the accessor for. Only works if action is a locale accessor
        #
        # @return [TrueClass, FalseClass] If the accessor has been created
        def create_translation_accessors
          Language.all.each do |l|
            create_translation_writer(l.code)
            create_translation_reader(l.code)
          end
        end

        # @param [String] locale The locale to create the writer for
        def create_translation_writer(locale)
          self.class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          def #{locale}=(attributes = {})
            attributes.each do |method, value|
              modified!
              self.send :"\#{method}=", value, :#{locale}
            end
          end
          RUBY
        end

        # @param [String] locale The locale to create the reader for
        def create_translation_reader(locale)
          self.class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          def #{locale}
            translation :#{locale}
          end
          RUBY
        end
      end
      module InstanceMethods
        def after_save
          @_translations.each_value do |translation|
            if translation.pk
              translation.save
            else
              add_translation(translation)
            end
          end
        end
        def default_locale
          'de'
        end
        def translation_exists?(locale)
          pk && translation(locale)
        end
        def translation(locale)
          l = Language.find(:code => locale.to_s)
          (@_translations ||= {})[locale.to_sym] ||=
            if pk
              translations.where(:language_id => l.id).first
            else
             self.class.translation_class.new(:language_id => l.id)
            end
        end

        private

        def _is_default(value)
          if value.respond_to? :blank?
            value.blank? || value == false
          else
            case value
            when String then value.strip.empty?
            when NilClass then true
            else value.respond_to?(:empty?) && value.empty?
            end
          end
        end
      end
    end
  end
end
