module MagicBeans
	module Idable

		def encrypted_id
			extend ClassMethods
			include InstanceMethods

			has_one :idable, as: :resource, class_name: "MagicBeans::Id"

			before_create do
				self.build_idable id: find_id
			end
		end

		module ClassMethods
			def find(*args)
				options = args.extract_options!

				return super(*args) if options[:bypass] == true || [:first, :last, :all].include?(args.first)

				ids = [MagicBeans::Id.find(decoded_ids(args))].flatten.map(&:resource_id)
				ids = ids.first if ids.length == 1
				super(ids)
			end

			def exists?(id_or_conditions = {})
				return super(id_or_conditions) if id_or_conditions.is_a?(Array) || id_or_conditions.is_a?(Hash)

				begin
					id = [MagicBeans::Id.find(decoded_ids(id_or_conditions))].flatten.first
					super(id.resource_id)
				rescue ActiveRecord::RecordNotFound => e
					false
				end
			end

			def destroy(id)
				ids = [MagicBeans::Id.find(decoded_ids(id))].flatten.map(&:resource_id)
				super(ids)
			end

			def delete(id)
				ids = [MagicBeans::Id.find(decoded_ids(id))].flatten.map(&:resource_id)
				super(ids)
			end

			private

				def decoded_ids(*ids)
					crypt = MagicBeans::Crypt.new

					ids.flatten!
					ids.map! { |id| crypt.decode(id) }
					ids = ids.first if ids.length == 1
					ids
				end
		end

		module InstanceMethods
			def to_param
				return super if idable.nil?

				crypt = MagicBeans::Crypt.new
				crypt.encode(idable.id)
			end

			private

				def find_id
					amount = MagicBeans::Id.count.to_f
					factor = 64.to_f
					min = (((amount/factor).floor*factor) + 1).to_i
					max = (((amount+1)/factor).ceil*factor).to_i
					candidate = rand(min..max)
					while MagicBeans::Id.exists?(candidate)
						candidate = rand(min..max)
					end
					candidate
				end
		end
	end
end
