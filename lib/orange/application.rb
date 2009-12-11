module Orange
  class Application
    
    def initialize(core = false)
      @core = core
      @options ||= {}
      orange.register(:stack_loaded) do |s|
        init
      end
    end
    
    # init is called after the full middleware stack is fully loaded
    # (just in case the middleware stack added necessary functionality, etc)
    def init
    end
    
    def set_core(core)
      @core = core
    end
    
    def call(env)
      packet = Orange::Packet.new(@core, env)
      # Set up this application as router if nothing else has
      # assumed routing responsibility (for Sinatra DSL like routing)
      if (!packet['route.router'] && opts[:self_routing, true])
        packet['route.router'] = self
      end
      packet.route
      packet.finish
    end
    
    def orange
      @core
    end
    
    def route(packet)
      packet.session['user.id'] = false
      raise 'default response from Orange::Application.route'
    end
    
    def self.set(key, v = true)
      @options ||= {}
      @options[key] = v
    end
    
    def opts
      self.class
    end
    
    def self.[](key, default = false)
      @options ||= {}
      @options.has_key?(key) ? @options[key] : default
    end
    
    def self.app
      Orange::Stack.new &@app   # turn saved proc into a block arg
    end
    
    def self.stack(&block)
      @app = Proc.new           # pulls in the block and makes it a proc
    end
  end
end