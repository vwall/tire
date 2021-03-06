module Tire
  module Model

    # Main module containing the infrastructure for automatic updating
    # of the _ElasticSearch_ index on model instance create, update or delete.
    #
    # Include it in your model: `include Tire::Model::Callbacks`
    #
    # The model must respond to `after_save` and `after_destroy` callbacks
    # (ActiveModel and ActiveRecord models do so, by default).
    #
    # By including the model, you will also have the `after_update_elasticsearch_index` and
    # `before_update_elasticsearch_index` callbacks available.
    # 
    module Callbacks

      # A hook triggered by the `include Tire::Model::Callbacks` statement in the model.
      #
      def self.included(base)

        # Update index on model instance change or destroy.
        #
        if base.respond_to?(:after_save) && base.respond_to?(:after_destroy)
          base.send :after_save,    lambda { tire.update_index }
          base.send :after_destroy, lambda { tire.update_index }
        end

        # Add neccessary infrastructure for the model, when missing in
        # some half-baked ActiveModel implementations.
        #
        if base.respond_to?(:before_destroy) && !base.instance_methods.map(&:to_sym).include?(:destroyed?)
          base.class_eval do
            before_destroy  { @destroyed = true }
            def destroyed?; !!@destroyed; end
          end
        end

        # Define _Tire's_ callbacks.
        #
        base.class_eval do
          define_model_callbacks(:update_elasticsearch_index, :only => [:after, :before])
        end if base.respond_to?(:define_model_callbacks)
      end

    end

  end
end
