# -*- encoding : utf-8 -*-
module SecondLevelCache
  module ActiveRecord
    module Associations
      module HasOneAssociation
        extend ActiveSupport::Concern
        included do
          class_eval do
            alias_method_chain :find_target, :second_level_cache
          end
        end

        def find_target_with_second_level_cache
          return find_target_without_second_level_cache unless klass.second_level_cache_enabled?
          return find_target_without_second_level_cache if reflection.options[:through] || reflection.scope
          # TODO: implement cache with has_one through, scope
          if reflection.options[:as]
            cache_record = klass.fetch_by_uniq_keys({reflection.foreign_key => owner[reflection.active_record_primary_key], reflection.type => owner.class.base_class.name})
          else
            cache_record = klass.fetch_by_uniq_key(owner[reflection.active_record_primary_key], reflection.foreign_key)
          end
          return cache_record.tap{|record| set_inverse_instance(record)} if cache_record

          record = find_target_without_second_level_cache

          record.tap do |r|
            set_inverse_instance(r)
            r.write_second_level_cache
          end if record
        end
      end
    end
  end
end
