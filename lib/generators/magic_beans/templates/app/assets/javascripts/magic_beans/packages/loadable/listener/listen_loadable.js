Listeners.Loadable = {
	run: function(){
		$('[data-loadable]').each(function(){
			$(this).on('loader:toggle', function(){
				Listeners.Loadable.utility.toggle.call(this, !$(this).hasClass('thinking'));
			});

			$(this).on('click loader:toggle:on', function(){
				Listeners.Loadable.utility.toggle.call(this, true);
			});

			$(this).on('loader:toggle:off', function(){
				Listeners.Loadable.utility.toggle.call(this, false);
			});
		});
	},

	utility: {
		toggle: function(onoff){
			if(onoff === undefined) onoff = true;

			if(onoff){
				var tag = $(this).get(0).tagName.toUpperCase();
				switch(tag){
					case 'A' :
					case 'BUTTON' :
						$(this).css({
							position: 'relative',
							verticalAlign: 'top'
						});
						if(!$(this).find('.loader-text').length) $(this).html('<span class="loader-text">' + $(this).text() + '</span>');
						if(!$(this).find('.spinner').length) $(this).append('<span class="spinner"><span class="bounce1"></span><span class="bounce2"></span><span class="bounce3"></span></span>');
						$(this).addClass('thinking').prop('disabled', true).trigger('blur');
						break;
				}
			}else{
				$(this).removeClass('thinking').prop('disabled', false);
			}
		}
	}
};