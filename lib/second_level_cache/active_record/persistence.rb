# -*- encoding : utf-8 -*-
module SecondLevelCache
  module ActiveRecord
    module Persistence
      extend ActiveSupport::Concern

      included do
        class_eval do
          alias_method_chain :reload, :second_level_cache
          alias_method_chain :touch, :second_level_cache
          alias_method_chain :update_column, :second_level_cache
        end
      end

      def update_column_with_second_level_cache(name, value)
        expire_second_level_cache
        update_column_without_second_level_cache(name, value)
      end

      def reload_with_second_level_cache(options = nil)
        expire_second_level_cache
        reload_without_second_level_cache(options)
      end

      def touch_with_second_level_cache(name = nil)
        expire_second_level_cache
        touch_without_second_level_cache(name)
      end
    end
  end
end
