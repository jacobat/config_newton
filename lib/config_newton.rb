module ConfigNewton
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      @configuration = ConfigNewton::Configuration.new
    end
  end
  
  module ClassMethods
    # Configure the class either with a hash
    # or by providing a block. See the documentation
    # for Configuration#set.
    def configure(options = {}, &block)
      config.set(options, &block)
    end
    
    # A list of configurable properties.
    def configurables
      configuration.properties
    end
    
    # The configuration object.
    def configuration
      @configuration
    end
    alias :config :configuration
    
    protected
    
    # Add either a single configurable property to
    # the class/module or provide a block that will
    # allow you to set multiple at once.
    #
    # <b>Example:</b>
    #
    #     
    def configurable(property = nil, options = {}, &block)
      if block_given?
        @configuration.instance_eval(&block)
      else
        @configuration.add(property, options)
      end
    end
  end
  
  class Configuration
    def initialize
      @hash = {}
      @properties = []
      @defaults = {}
    end
    
    attr_reader :properties
    
    # Add a new property that can be set and read
    # on this configuration.
    #
    # <b>Options:</b>
    #
    # <tt>:default</tt> :: Specify a default value.
    def add(name, options = {})
      raise ArgumentError, "Property name cannot be blank." unless name && name != ""
      @properties << name.to_sym
      @defaults[name.to_sym] = options[:default] if options[:default]
      self.class.class_eval <<-RUBY
        def #{name}
          self[:#{name}]
        end
        
        def #{name}=(value)
          self[:#{name}] = value
        end
      RUBY
    end
    alias :property :add
    
    # Read an individual property on the configuration.
    def [](property)
      @hash[property.to_sym] || @defaults[property.to_sym]
    end
    
    # Set an individual property on the configuration.
    def []=(property, value)
      @hash[property.to_sym] = value
    end
    
    # Converts the configuration into a symbol-keyed
    # hash.
    def to_hash
      @defaults.merge(@hash)
    end
    
    # Set the properties of the configuration
    # either by providing a hash or by providing
    # a block. The block will yield a configuration
    # object that has method setters and getters.
    #
    # Example:
    # 
    #     MyClass.config.set do |config|
    #       config.property = 123
    #     end
    def set(properties = {}, &block)
      if block_given?
        yield self
      else
        @hash.merge!(properties.inject({}){|h,(k,v)| h[k.to_sym] = v; h})
      end
      self
    end
    
    # Load configuration from a YAML string. Provide
    # a root node if you want something other than
    # the entire yaml document to be utilized. For
    # example, in Rails, you might provide the 
    # Rails environment as a root node.
    def load(yaml_string, root_node = nil)
      hash = YAML::load(yaml_string)
      set(root_node ? hash[root_node] : hash)
    end
    
    # Load configuration from a YAML file specified
    # by the path given (or a file pointer). Provide
    # a root node if you want something other than
    # the entire yaml document to be utilized. For
    # example, in Rails, you might provide the 
    # Rails environment as a root node.
    def load_from(file_or_path, root_node = 'configuration')
      hash = YAML::load_file(file_or_path)
      set(root_node ? hash[root_node] : hash)
    end
  end
end