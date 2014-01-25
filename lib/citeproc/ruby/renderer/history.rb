module CiteProc
  module Ruby
    class Renderer

      RenderHistory = Struct.new(:citation, :bibliography) do

        attr_reader :limit

        def initialize(renderer = nil, limit = 10)
          @renderer, @limit = renderer, limit
          super(*self.class.members.map { [] })
        end

        def remember!(node, *arguments)
          node = node.nodename if node.respond_to?(:nodename)

          return unless self.class.members.include?(node)

          history = self[node]

          history.unshift arguments
          history.pop if history.length > limit

          self
        end

        def inspect
          "#<RenderHistory #{ map { |k,v| [k, v.length].join('|') }.join(', ') }>"
        end
      end

    end
  end
end
