module MagicBeans
	class Crypt

		def encode(input)
			radix = digits.length
			i = input.to_i + MagicBeans.config.crypt.offset.to_i # Increase the number just so we don't end up with id's like "E" or "d3" on low number ids

			raise ArgumentError.new("Value #{val} cannot be less than zero") if i < 0

			out = []
			begin
				rem = i % radix
				i /= radix
				out << digits[rem]
			end until i == 0

			out.reverse.join
		end

		def decode(input)
			inp = input.to_s.split("")
			out = 0

			begin
				chr = inp.shift
				out += (digits.length**inp.length)*digits.index(chr)
			end until inp.empty?

			out - MagicBeans.config.crypt.offset.to_i # Decrease the number by the same offset amount
		end

		private

			def digits
				rnd = Random.new(MagicBeans.config.secrets.secret_key_base.to_i(24))
				"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_".split("").shuffle(random: rnd)
			end
	end
end