module Cucumber
  module StepSupport

    class Context
      attr_accessor :current_context_object
      def initialize alternative_step_prefixes
        @alternative_step_prefixes = alternative_step_prefixes
        @registered_regexps = []
      end

      def register_alternatives regexp, symbol_or_proc, options
        truncated_regexp = regexp.source.gsub(/^[\^]*#{current_context_object}\s*/, '')
        alternative_regexps = @alternative_step_prefixes.collect{|alternative| /^#{alternative} #{truncated_regexp}/}

        alternative_regexps.each do |alternative|
          unless @registered_regexps.include?(alternative)
            Cucumber::RbSupport::RbDsl.register_rb_step_definition(alternative, symbol_or_proc, options)
            @registered_regexps << alternative
          end
        end
      end
    end

    class << self

      def for clazz, *alternatives
        clazz.extend(self)

        clazz.step_support_for alternatives

        mod = add_helper_method(clazz)

        clazz.instance_eval do

          extend mod

          class << self

            alias_method :each_backup, :each

            def each &block

              each_backup do |item|
                self.step_context.current_context_object = item
                @caller_binding = block.binding
                item.class.instance_eval &block
                self.step_context.current_context_object = item
              end
            end
          end

        end
      end

      def add_helper_method(clazz)
        mod = Module.new do
          define_method clazz.name.downcase do
            clazz.step_context.current_context_object
          end
        end

        Cucumber::RbSupport::RbDsl.build_rb_world_factory [mod], nil
        mod
      end
    end


    def step_support_for *alternatives
      @context = Context.new *alternatives
    end

    def step_context
      @context
    end


    def step regexp, symbol = nil, options = {}, &proc
      register_step_to_proxy(options, proc, regexp)
      step_context.register_alternatives regexp, (symbol || proc), options
    end

    def register_step_to_proxy(options, proc, regexp)
      handle_to_step_context, handle_to_context_object = step_context, step_context.current_context_object

      proxy = Proc.new do |*args|
        handle_to_step_context.current_context_object = handle_to_context_object
        instance_exec(*args, &proc)
      end

      Cucumber::RbSupport::RbDsl.register_rb_step_definition(regexp, proxy, options)
    end


    alias When step
    alias Given step
    alias Then step
    alias And step
    alias But step

    def method_missing *args
      if @caller_binding
        @caller_binding.send(*args)
      else
        super *args
      end
    end
  end

end

class Persona
  class << self

    def add persona
      (@personas ||= []) << persona
    end

    def each &block
      @personas.each &block
    end

  end

  def initialize name
    @name = name
    self.class.add self
  end

  def to_s
    @name
  end
end

Cucumber::StepSupport.for(Persona, :he, :she, :his, :her)

Persona.new('Leon')
Persona.new('Joel')

Personas = Persona



