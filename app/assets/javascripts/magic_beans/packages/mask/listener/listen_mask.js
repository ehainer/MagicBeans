Listeners.Mask = {
	run: function(){
		$('[data-mask]').each(function(){
			$(this).mask($(this).data('mask'));
		});
	}
};