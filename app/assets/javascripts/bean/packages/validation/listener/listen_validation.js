Listeners.Validation = {
	run: function(){
		var validateOn = Bean.Config.get('validate_trigger', 'submit');

		if(validateOn == 'blur'){
			$('form input:visible, form select, form textarea').on('blur', Validation.validate);
		}

		$('form').on('submit', function(){
			var proceed = true, inputs = $(this).find('input:visible, select, textarea');

			$.each(inputs, function(index, input){
				if(!Validation.validate(input)) proceed = false;
			});
			return proceed;
		});
	},
};
