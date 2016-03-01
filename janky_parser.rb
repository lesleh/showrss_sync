module Feedjira
  module Parser
    # It's good practice to namespace your parsers, so we'll put
    # this one in the Versa namespace.
    module Versa

      ### Entry Parser Class ###
      # This first class is for parsing an individual <item> in the feed.
      # We define it first because our top level parser need to be able to call it.
      # By convention, this class name is the same as our top level parser
      # but with "Entry" appended.
      class JankyPublisherEntry
        include SAXMachine
        include FeedEntryUtilities

        # Declare the fields we want to parse out of the XML feed.
        element :title
        element :link, :as => :url
        element :description, :as => :summary
        element :pubDate, :as => :published
        element :guid, :as => :guid

        # We remove the query string from the url by overriding the 'url' method
        # originally defined by including FeedEntryUtilities in our class.
        # (see https://github.com/feedjira/feedjira/blob/master/lib/feedjira/feed_entry_utilities.rb)
        def url
          @url
        end
      end


      ### Feed Parser Class ###
      # This class is for parsing the top level feed fields.
      class JankyPublisher
        include SAXMachine
        include FeedUtilities

        # Define the fields we want to parse using SAX Machine declarations
        element :title
        element :link, :as => :url
        element :description

        # Parse all the <item>s in the feed with the class we just defined above
        elements :item, :as => :entries, :class => Versa::JankyPublisherEntry

        attr_accessor :feed_url

        # This method is required by all Feedjira parsers. To decide which
        # parser to use, Feedjira cycles through each parser it knows about
        # and passes the first 2000 characters of the feed to this method.
        #
        # To make sure your parser is only used when it's supposed to be used,
        # test for something unique in those first 2000 characters. URLs seem
        # to be a good choice.
        #
        # This parser, for example, is looking for an occurrence of
        # '<link>https://www.jankybutlovablepublisher.com' which we should
        # only really find in the feed we are targeting.
        def self.able_to_parse?(xml)
          xml.include? 'http://showrss.info'
        end
      end
    end
  end
end
