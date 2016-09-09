Listeners.Clamp = {
	run: function(){
		$('[data-clamp]').each(function(){
			$clamp($(this).get(0), { clamp: $(this).data('clamp') });
		});
	}
};