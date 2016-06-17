Listeners.Tooltip = {
	run: function(){
		$('[data-tooltip]').hover(function(){
			$(this).css('position', 'relative');
			if(!$(this).find('.tooltip').length){
				var klass = ['tooltip'];
				if($(this).data('theme')) klass.push('tooltip-' + $(this).data('theme'));
				$(this).append('<div class="' + klass.join(' ') + '">' + $(this).data('tooltip') + '</div>');
			}
			if(isNumeric($(this).data('multiline'))) $(this).find('.tooltip').css({ maxWidth: $(this).data('multiline'), whiteSpace: 'normal' });
			$(this).find('.tooltip').show();
		}, function(){
			$(this).find('.tooltip').hide();
		});
	}
};