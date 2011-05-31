require 'sax-machine'

module Feedzirra
  module Parser
    class GovtrackResult
      include SAXMachine
      include FeedEntryUtilities

      element :congress
      element :"bill-type", :as => :bill_type
      element :"bill-number", :as => :bill_number
      element :title
      element :link
      element :"bill-status", :as => :status
    end

    class Govtrack
      include SAXMachine
      include FeedUtilities
      elements :result, :as => :search_results, :class => GovtrackResult

      def self.able_to_parse?(xml) #:nodoc:
        1
        # xml =~ /<search-results/
      end
    end
  end
end
