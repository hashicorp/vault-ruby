module Vault
  module EncodePath
    def encode_path(path)
      path.b.gsub(%r!([^a-zA-Z0-9_.-/]+)!) { |m|
        '%' + m.unpack('H2' * m.bytesize).join('%').upcase
      }
    end

    module_function :encode_path
  end
end
