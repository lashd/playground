require 'cucumber'

module CucumberStepSupport

  class << self

    def extended clazz

      mod = Module.new do
        define_method clazz.name.downcase do
          clazz.current_subject
        end
      end

      Cucumber::RbSupport::RbDsl.build_rb_world_factory [mod], nil

      clazz.instance_eval do

        extend mod

        class << self

          alias_method :each_backup, :each


          def each &block

            each_backup do |item|
              self.current_subject = item
              @caller_binding = block.binding
              item.class.instance_eval &block
              self.current_subject = item
            end
          end
        end

      end
    end
  end

  def regexps
    @regexps ||= {}
  end

  attr_accessor :current_subject

  def step regexp, symbol = nil, options = {}, &proc
    truncated_regexp = regexp.source.gsub(/^[\^]*#{current_subject}\s*/, '')
    he_regexp, she_regexp = /^he #{truncated_regexp}/, /^she #{truncated_regexp}/
    proc_or_sym = symbol || proc

    handle_to_extending_class, handle_to_current_subject = self, current_subject
    da_proc = Proc.new do |*args|
      handle_to_extending_class.current_subject = handle_to_current_subject
      instance_exec(*args, &proc)
    end

    Cucumber::RbSupport::RbDsl.register_rb_step_definition(regexp, da_proc, options)
    unless regexps[he_regexp]
      [he_regexp, she_regexp].each { |regex| Cucumber::RbSupport::RbDsl.register_rb_step_definition(regex, proc_or_sym, options) }
      regexps[he_regexp] = he_regexp
    end
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

Persona.extend(CucumberStepSupport)

Persona.new('Leon')
Persona.new('Joel')

Personas = Persona



