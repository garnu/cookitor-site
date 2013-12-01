module RailsSession
	class Decoder
		KEY_ITERATIONS = 1000
		ENCRYPTED_COOKIE_SALT = "encrypted cookie"
		ENCRYPTED_SIGNED_COOKIE_SALT = "signed encrypted cookie"

		attr_reader :data, :hash, :error
		def initialize(content, key = nil, opts = {})
			if content.present? && content.size > 42 && content.size <= 4096
				unless content.blank?
					if key.blank?
						parse(content) 
					else
						opts[:iterations] 									||= RailsSession::Decoder::KEY_ITERATIONS
						opts[:encrypted_cookie_salt]				||= RailsSession::Decoder::ENCRYPTED_COOKIE_SALT
						opts[:encrypted_signed_cookie_salt]	||= RailsSession::Decoder::ENCRYPTED_SIGNED_COOKIE_SALT
						decrypt(content, key, opts)
					end
				end
			else
				@error = "Invalid cookie."
			end
		end

		def valid?
			error.blank?
		end

		private

		def decrypt(content, key, opts)
			clean_content = CGI.unescape(content.split("\n").join)
			content_parts = clean_content.split('--')
			key_generator = ActiveSupport::KeyGenerator.new(key, iterations: opts[:iterations])
			secret = key_generator.generate_key(opts[:encrypted_cookie_salt])
			sign_secret = key_generator.generate_key(opts[:encrypted_signed_cookie_salt])
			encryptor = ActiveSupport::MessageEncryptor.new(secret, sign_secret, {serializer: SecureMarshal::Parser})
			@data = encryptor.decrypt_and_verify(clean_content)
			@hash = content_parts.last
		rescue Exception => e
			@data = nil
			@hash = nil
			@error = e.to_s
		end

		def parse(content)
			clean_content = CGI.unescape(content.split("\n").join)
			content_parts = clean_content.split('--')
			if content_parts.size == 2
				@hash = content_parts.last
				begin
					decoded = Base64.decode64(content_parts.first).taint.to_s
					Rails.logger.debug "Decoded from base64: #{decoded.inspect}"
					@data = SecureMarshal::Parser.load(decoded).taint
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