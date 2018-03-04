module DataFaker
  module CustomHeaderParser
    def self.parse (header)
      header_array = []
      header.split(";").each do |element|
        header_element = element.split("=>")
        header_element[1] = '' if header_element[1] == nil
        header_element[0].strip!
        header_element[1].strip!
        header_array.push(header_element)
      end
      custom_header = Hash[header_array.map {|key, value| [key.strip, value]}]
    end
  end
end

