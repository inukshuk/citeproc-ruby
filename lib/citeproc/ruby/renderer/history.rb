module CiteProc
  module Ruby
    class Renderer

      History = Struct.new(:citation, :bibliography, :names) do

        attr_reader :limit

        def initialize(renderer = nil, limit = 10)
          @renderer, @limit = renderer, limit
          super(*self.class.members.map { [] })
        end

        def remember!(name, *arguments)
          return unless self.class.members.include?(name)

          history = self[name]

          history.unshift arguments
          history.pop if history.length > limit

          self
        end

        def inspect
          "#<Renderer::History #{ map { |k,v| [k, v.length].join('|') }.join(', ') }>"
        end
      end

    end
  end
end
