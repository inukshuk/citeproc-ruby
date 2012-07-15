module CiteProc
  module Ruby

    class Engine < CiteProc::Engine

      @name = 'citeproc-ruby'.freeze
      @type = 'CSL'.freeze
      @version = CSL::Schema.version
      @priority = 1


      def process
        raise NotImplementedByEngine
      end

      def append
        raise NotImplementedByEngine
      end

      def bibliography
        raise NotImplementedByEngine
      end

      def update_items
        raise NotImplementedByEngine
      end

      def update_uncited_items
        raise NotImplementedByEngine
      end

    end
  end
end