Listeners.Select = {
	run: function(){
		$('select:visible').each(function(){
			var placeholder = $(this).attr('placeholder') || $(this).data('placeholder');
			if($(this).data('behavior') == 'input') $(this).addClass('select-input').attr('tabindex', -1);
			if(!$(this).find('option[selected]').length) $(this).prepend('<option value selected></option>');
			if(!$(this).data('placeholder') && placeholder) $(this).attr('data-placeholder', placeholder);

			$(this).chosen({
				width: '',
				disable_search: $(this).data('search') !== true,
				inherit_select_classes: true,
				search_contains: true,
				include_group_label_in_selected: true
			});

			$(this).trigger('chosen:updated');

			if(placeholder && $(this).data('behavior') == 'input'){
				$(this).next('.chosen-container').find('input').attr('placeholder', placeholder);
			}
		});
		$('select').trigger('chosen:updated');
	}
};