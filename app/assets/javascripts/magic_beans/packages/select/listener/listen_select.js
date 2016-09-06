Listeners.Select = {
	run: function(){
		$('select:visible').each(function(){
			var placeholder = $(this).attr('placeholder') || $(this).data('placeholder');
			var classes = $(this).clone().get(0).className.split(/\s+/);
			//if($(this).data('behavior') == 'input') $(this).addClass('select-input').attr('tabindex', -1);
			//if(!$(this).find('option[selected]').length) $(this).prepend('<option value selected></option>');
			//if(!$(this).data('placeholder') && placeholder) $(this).attr('data-placeholder', placeholder);

			var select = $(this).select2({
				placeholder: placeholder,
				minimumResultsForSearch: ($(this).data('search') !== true ? Infinity : 20)
			});

			classes = classes.filter(function(c){
				return c.match(/select2.*/i) == null;
			});

			// If multiple select, add a specialty container class
			if($(this).attr('multiple')){
				classes.push('select2-container--multiple');
			}else{
				classes.push('select2-container--single');
			}

			//select.data('select2').$container.addClass(classes.join(' '));
			//select.data('select2').$dropdown.addClass(classes.join(' '));

			//$(this).trigger('chosen:updated');

			//if(placeholder && $(this).data('behavior') == 'input'){
			//	$(this).next('.chosen-container').find('input').attr('placeholder', placeholder);
			//}
		});
		//$('select').trigger('chosen:updated');
	}
};
