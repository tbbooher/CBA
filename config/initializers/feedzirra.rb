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

    class GovTrackPerson
      include SAXMachine
      include FeedEntryUtilities

      #element :person
      element :person, :value => :id, :as => :govtrack_id
      element :person, :value => :lastname, :as => :last_name
      element :person, :value => :firstname, :as => :first_name
      element :person, :value => :middlename, :as => :middle_name
      element :person, :value => :birthday, :as => :birthday
      element :person, :value => :gender, :as => :gender
      element :person, :value => :religion, :as => :religion
      element :person, :value => :pvsid, :as => :pvs_id
      element :person, :value => :osid, :as => :os_id
      element :person, :value => :bioguideid, :as => :bioguide_id
      element :person, :value => :metavidid, :as => :metavid_id
      element :person, :value => :youtubeid, :as => :youtube_id
      element :person, :value => :icpsrid, :as => :icpsrid
      element :person, :value => :name, :as => :full_name
      element :person, :value => :title, :as => :title
      element :person, :value => :state, :as => :state
      element :person, :value => :district, :as => :district
      elements :role, :value => :type, :as => :role_type
      elements :role, :value => :party, :as => :role_party
      elements :role, :value => :startdate, :as => :role_startdate

      def self.able_to_parse?(xml) #:nodoc:
        1
        # xml =~ /<search-results/
      end

    end

    class GovTrackPeople
      include SAXMachine
      include FeedEntryUtilities

      elements :person, :as => :people, :class => GovTrackPerson

      def self.able_to_parse?(xml) #:nodoc:
        1
        # xml =~ /<search-results/
      end
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


