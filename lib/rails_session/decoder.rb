module RailsSession
	class Decoder
		attr_reader :data, :hash, :error
		def initialize(content)
			if content.present? && content.size > 42 && content.size <= 4096
				parse(content) unless content.blank?
			else
				@error = "Invalid cookie."
			end
		end

		def valid?
			error.blank?
		end

		private

		def parse(content)
			clean_content = CGI.unescape(content.split("\n").join)
			content_parts = clean_content.split('--')
			if content_parts.size == 2
				@hash = content_parts.last
				begin
					decoded = Base64.decode64(content_parts.first).taint.to_s
					Rails.logger.debug "Decoded from base64: #{decoded.inspect}"
					@data = Marshal.load(decoded).taint
					Rails.logger.debug "Loaded object #{@data.inspect}"
				rescue Exception => e
					@data = nil
					@hash = nil
					@error = e.to_s
				end
			else
				@error = "Invalid format: couldn't split between the data and the HMAC."
			end
		end
	end
end