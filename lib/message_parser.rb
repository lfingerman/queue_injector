module DataFaker
  module MessageParser
    def self.parse_json (json_message)
      begin
        data = JSON.parse json_message
      rescue Exception => e
        raise DataFaker::Exceptions::InvalidJsonError, "Malformed JSON with #{e.message}"
      end
     # status 201
    end

    def self.parse_xml (xml_message)
      data = Nokogiri::XML.parse xml_message
      raise DataFaker::Exceptions::InvalidXMLError, "Malformed XML with #{xml_message}" if data.children.empty?
      #status 201
    end
  end

end
