module CiteProc
  module Ruby

    class Renderer

      class ItemObserver
        attr_accessor :history, :item

        def initialize(item, history = {})
          @item, @history = item, history
        end

        def start
          item.add_observer(self)
          self
        end

        def stop
          item.delete_observer(self)
          self
        end

        # A variable read more than once counts as non-empty
        # if any of the reads was non-empty
        def update(method, key, value)
          history[key] = value if method == :read && empty?(history[key])
        end

        def skip?
          !history.empty? && history.values.all? { |v| empty?(v) }
        end

        def accessed
          history.select { |key, value| !value.nil? }.keys
        end

        def clear!
          history.clear
          self
        end

        private

        def empty?(value)
          value.nil? || value.respond_to?(:empty?) && value.empty?
        end
      end

    end

  end
end
