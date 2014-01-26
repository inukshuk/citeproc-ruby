module CiteProc
  module Ruby
    class Renderer

      def citation_mode?
        state.mode == 'citation'
      end

      def bibliography_mode?
        state.mode == 'bibliography'
      end

      def sort_mode?
        state.mode == 'key'
      end

      def substitution_mode?
        !state.substitute.nil?
      end


      class State
        include Observable

        attr_reader :node, :item, :history, :substitute

        def initialize
          @history = History.new(self, 3)
        end

        def store!(item, node)
          @item, @node = item, node
        ensure
          changed
          notify_observers :store!, mode, :item => item, :node => node
        end

        def clear!(result = nil)
          old_mode, @item, @node, @substitute = mode, nil, nil, nil
        ensure
          changed
          notify_observers :clear!, old_mode, :result => result
        end

        def mode
          node && node.nodename
        end

        def substitute!(names)
          @substitute = names
        end

        def clear_substitute!(backup = nil)
          @substitute = backup
        end
      end

    end
  end
end
