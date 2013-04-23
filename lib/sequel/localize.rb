require 'sequel/localize/language'
require "sequel/localize/version"

module Sequel
  module Plugins
    module Localize
      def self.configure(model, opts={})
        model._init_translations
        localized_models << model
      end
      def self.localized_models
        @localized_models ||= []
      end
      module ClassMethods
        def _init_translations
          @@_lowercase_name = underscore(demodulize(self.to_s))
          create_translation_class
          create_translated_field_methods
          create_translation_accessors
        end
        def localized_fields
          @@localized_fields ||= translation_class.columns - [translation_class.primary_key, :"#{@@_lowercase_name}_id", :language_id]
        end
        def translation_class
          @@translation_class ||= Object.const_get("#{self}Translation")
        end
        def add_translation_accessors(code)
          create_translation_writer(code)
          create_translation_reader(code)
        end
        
        protected
        
        def create_translation_class
          one_to_many :"#{@@_lowercase_name}_translations"
          alias_method :translations_dataset, :"#{@@_lowercase_name}_translations_dataset"
          alias_method :translations, :"#{@@_lowercase_name}_translations"
          alias_method :add_translation, :"add_#{@@_lowercase_name}_translation"
          self.class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          class ::#{self}Translation < Sequel::Model
            many_to_one :#{@@_lowercase_name}
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
              translation(locale).#{field_name}= value
            end
            RUBY
          end
        end
        def create_translation_accessors
          Language.all.each do |l|
            create_translation_writer(l.code)
            create_translation_reader(l.code)
          end
        end

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
          each_translation do |locale, translation|
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

        def translation(locale)
          l = Language[locale]
          (@_translations ||= {})[locale.to_sym] ||=
            if pk
              translations_dataset.where(:language_id => l.id).first 
            end || self.class.translation_class.new(:language_id => l.id)
        end

        def validate
          super
          each_translation do |locale, translation|
            errors.add(locale, translation.errors) unless translation.valid?
          end
        end

        private

        def each_translation(&block)
          return unless @_translations
          @_translations.each(&block)
        end
      end
    end
  end
end
