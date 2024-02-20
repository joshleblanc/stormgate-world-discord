module Utilities 
    class Renderer < ActionView::Base.with_empty_template_cache        
        def self.instance 
           @instance if @instance
           
           @instance = new(@lookup_context, {}, nil)
        end

        def self.config(view_paths)
            @lookup_context = ActionView::LookupContext.new(view_paths)
        end
    end
end