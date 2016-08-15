var Listeners = {
	all: {
		once: function(observer){
			$('.form-list').on('cocoon:after-insert', observer.reboot);

			$('body').on('bean:reboot', function(){
				var obs = new Bean.Observer(Bean.getPageName());
				obs.reboot();
			});

			$('body').on('bean:reboot:all', function(){
				var obs = new Bean.Observer('all');
				obs.reboot();
			});

			$('.field_with_errors').on('keydown change', function(){
				$(this).removeClass('field_with_errors').off();
			});

			$('input').on('focus', function(){
				$('.pseudo-focus').removeClass('pseudo-focus');
			}).on('blur', function(){
				$(this).removeClass('pseudo-focus');
			});

			// Iterate over each enabled package, and initalize it's listener if available
			Bean.debug('[Listeners.all.once] Initializing Packages', function(){
				Bean.Listener.init(Bean.Config.get('packages'));
			});
		},

		always: function(observer){
			$('[data-remote]').off('ajax:success').on('ajax:success', function(e, data, status, xhr){
				var callback = $(this).data('callback') || $(this).find('[data-callback]').data('callback');
				if(Callbacks[callback]) Callbacks[callback].call(this, data, status, xhr);
			});

			$('[data-href]').off('click').on('click', function(event){
				if(!$(event.target).hasClass('no-propagate') && $(event.target).closest('.no-propagate').length == 0){
					var self = $(this);
					var method = $(this).data('method') || 'GET';
					var remote = $(this).data('remote');
					remote = (remote == 'true' || remote == true ? true : false);
					if(remote){
						$.ajax({
							url: $(this).data('href'),
							method: method
						}).done(function(response){
							self.trigger('ajax:success', [response, 200, this.xhr]);
						});
					}else{
						window.location = $(this).data('href') || $(this).attr('data-href');
					}
				}
			});

			if(Bean.Config.get('packages', []).contains('select')){
				Bean.debug('[Listeners.all.always] Initializing Package', function(){
					Bean.Listener.init('select');
				});
			}
		}
	},

	/**
	 * Use
	 *
	 * Each key can be a hash specifying two additional keys [once, always]
	 * The values of each are a function with one argument for the observer object (Bean::Observer)
	 * The value of "once" is called upon page load, and never after that
	 * The value of "always" is called upon page load, but also whenever the observer is rebooted (called via $('body').trigger())
	 * If a string is supplied as the value instead of a hash, it is assumed to be the name of another key that contains
	 * a hash with [once, always], an easy way to "clone" listeners on pages, useful for new/show pages
	 */

	/*
	controllerAction: {
		once: function(observer){
		},

		always: function(observer){
		}
	},

	homeIndex: 'controllerAction'
	*/

	beansIndex: {
		once: function(observer){
			$('.beans-form').on('dialog:show', function(){
				$('body').trigger('bean:reboot');
			});

			$('.beans-form').on('dialog:click', function(event, dialog, btn){
				console.log(dialog, btn);
				///event.stopImmediatePropagation();
				if($(btn).hasClass('prompt')){
					var error1 = dialog.addError('Oh snap you\'re not done doing whatever weird thing we asked you to do', true);
					dialog.getBody().one('mousedown', function(){
						dialog.removeError(error1);
						var error2 = dialog.addError('But wait, theres more...');
						console.log(error2);
						//dialog.removeError();
					});
				}
			});

			$('img[data-crop]').on('crop:success', function(event, response, cropper){
				console.log(response);
				cropper.getDialog().hide();
				$(this).attr('src', response.thumb);
			}).on('crop:failure', function(event, response, cropper){
				alert('Crop failed! ' + response.responseText);
			});

			$('#loading-image-dialog').on('dialog:show', function(event, dialog){
				dialog.getBody().html('<div class="loading"><span class="loader loader-circle"></span></div>');
				$(dialog).wait(2000).then(function(){
					var loader = new Bean.Loader();
					loader.load('https://images.unsplash.com/photo-1467634764965-325ecb804113?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&s=3cee706463b4b03a2a4614fa582e439c').done(function(image){
						dialog.getBody().html(image);
						dialog.center();
					});
				});
			});
		},

		always: function(observer){
			Bean.Listener.init('validation', 'select');
		}
	},

	beansShow: 'beansIndex'
};