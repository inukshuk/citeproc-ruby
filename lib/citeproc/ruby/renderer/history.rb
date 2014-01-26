module CiteProc
  module Ruby
    class Renderer

      class History
        attr_reader :maxsize, :memory

        def initialize(state, maxsize = 10)
          @state, @maxsize, = state, maxsize
          @state.add_observer(self)

          @memory = Hash.new do |hash, key|
            hash[key] = []
          end
        end

        def update(action, mode, memories = {})
          history = memory[mode]

          case action
          when :store!
            history << memories
          when :clear!, :merge!
            history[-1].merge! memories
          end

        ensure
          history.shift if history.length > maxsize
        end

        def recall(mode)
          memory[mode][-1]
        end

        def citation
          memory['citation']
        end

        def bibliography
          memory['bibliography']
        end
      end

    end
  end
end
