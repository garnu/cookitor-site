module RailsSession
	class Decoder
		attr_reader :data, :hash, :error
		def initialize(content)
			unless content.blank?
				clean_content = CGI.unescape(content.split("\n").join)
				content_parts = clean_content.split('--')
				if content_parts.size == 2
					@hash = content_parts.last
					begin
						@data = Marshal.load(Base64.decode64(content_parts.first))
					rescue Exception => e
						@error = e.to_s
					end
				else
					@error = "Invalid format: couldn't split between the data and the HMAC."
				end
			else
				@error = "No Rails session to decode."
			end
		end

		def valid?
			error.blank?
		end
	end
end