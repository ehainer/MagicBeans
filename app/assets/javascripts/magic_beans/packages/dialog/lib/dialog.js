(function($){
	$.fn.dialog = function(options){
		var $this = this;
		var $form = this.closest('form');

		var settings = $.extend({
			header: '',
			body: this,
			footer: '',
			theme: 'default',
			width: '50%',
			height: 'auto',
			allowClose: true,
			allowOutsideClose: true,
			errorAnimation: 'shake'
		}, options);

		var dialog = {
			show: function(){
				var self = this;
				this.dispatcher().dispatch('dialog:show:before', this);
				this.backgroundToggle(true);
				this.getContent().removeClass('outside-window').fadeIn(300, function(){
					self.center();
					self.dispatcher().dispatch('dialog:show:after', this);
				});
				this.dispatcher().dispatch('dialog:show', this);
				this.center();
				this.initListeners();
				return this;
			},

			hide: function(){
				var self = this;
				// If there is an error, and it's not set to ignore, don't close the dialog and exit immediately
				if(this.hasError()){
					this.getDialog().removeClass(settings.errorAnimation);
					this.getDialog().get(0).offsetWidth = this.getDialog().get(0).offsetWidth;
					this.getDialog().addClass(settings.errorAnimation);
					return;
				}

				this.dispatcher().dispatch('dialog:hide:before', this);
				this.backgroundToggle(false);
				this.getContent().fadeOut(200, function(){
					$(this).addClass('outside-window');
					self.dispatcher().dispatch('dialog:hide:after', this);
				});
				this.dispatcher().dispatch('dialog:hide', this);
				return this;
			},

			center: function(animate){
				var windowW = $(window).width();
				var windowH = $(window).height();
				var dialogW = this.getDialog().outerWidth();
				var dialogH = this.getDialog().outerHeight();

				var top = (windowH/2)-(dialogH/2);
				var left = (windowW/2)-(dialogW/2);

				if(top < 0) top = 0;

				if(animate){
					this.getDialog().animate({ top: top, left: left, marginLeft: 0 }, 200);
				}else{
					this.getDialog().css({ top: top, left: left, marginLeft: 0 });
				}
				return this;
			},

			resize: function(){
				var paddingH = this.getBody().innerWidth() - this.getBody().width();
				this.getDialog().width(this.getBody().contents().outerWidth(true) + paddingH);
			},

			dispatcher: function(){
				if(!this._dispatcher){
					this._dispatcher = new Bean.Dispatcher();
				}
				return this._dispatcher;
			},

			onBeforeShow: function(callback){
				this.dispatcher().add('dialog:show:before', callback);
				return this;
			},

			onShow: function(callback){
				this.dispatcher().add('dialog:show', callback);
				return this;
			},

			onAfterShow: function(callback){
				this.dispatcher().add('dialog:show:after', callback);
				return this;
			},

			onBeforeHide: function(callback){
				this.dispatcher().add('dialog:hide:before', callback);
				return this;
			},

			onHide: function(callback){
				this.dispatcher().add('dialog:hide', callback);
				return this;
			},

			onAfterHide: function(callback){
				this.dispatcher().add('dialog:hide:after', callback);
				return this;
			},

			onClick: function(callback){
				this.dispatcher().add('dialog:click', callback);
				return this;
			},

			onError: function(callback){
				this.dispatcher().add('dialog:error', callback);
				return this;
			},

			onErrorAdd: function(){
				this.dispatcher().add('dialog:error:add', callback);
				return this;
			},

			onErrorRemove: function(){
				this.dispatcher().add('dialog:error:remove', callback);
				return this;
			},

			onErrorClear: function(){
				this.dispatcher().add('dialog:error:clear', callback);
				return this;
			},

			backgroundToggle: function(status){
				if(status){
					$('body').children(':visible').not(this.getOverlay()).addClass('blurry');
				}else{
					$('body').children(':visible').not(this.getOverlay()).removeClass('blurry');
				}
			},

			initListeners: function(){
				var self = this;

				if(settings.allowOutsideClose || !this.hasHeader()){
					this.getOverlay().addClass('clickable').click(function(event){
						if($(event.target).hasClass('overlay')) self.hide();
					});
				}else if(!settings.allowOutsideClose){
					this.getOverlay().removeClass('clickable').off();
				}

				this.getDialog().find('.close').on('click', function(){
					self.hide();
				});

				this.getBody().find('a, button, input[type="button"], input[type="submit"]').on('click', function(){
					self.dispatcher().dispatch('dialog:click', self, [this]);
				});

				$(window).on('resize', function(){
					// Wait until resize is finished, 200 ms after last resize event dispatched
					clearTimeout(self._resizeTimer);
					self._resizeTimer = setTimeout(function(){
						self.center(true);
					}, 200);
				});
			},

			addError: function(message, ignore){
				var self = this;
				var errorId = Bean.Abstract.getId();
				this.getDialog().addClass('dialog-important');

				// Get contents of current errors
				var currentErrors = $.map(this.getErrors().find('.dialog-error'), function(error){
					return $(error).html();
				});

				if(ignore !== true) ignore = false; 

				// If error message provided does not already exist, add it
				if(!currentErrors.contains(message)){
					var error = $('<div />', { id: 'error-' + errorId, class: ['dialog-error', (ignore ? 'ignore' : '')].join(' ') }).html(message);
					this.getErrors().append(error);
					this.dispatcher().dispatch('dialog:error', this, [message, ignore]);
					this.dispatcher().dispatch('dialog:error:add', this, [message, ignore]);
					this.getErrors().find('.dialog-error').last().hide().slideDown(200, function(){
						self.center(true);
					});
				}
				return errorId;
			},

			removeError: function(id){
				var self = this;
				if(this.getErrors().find('#error-' + id).length){
					this.dispatcher().dispatch('dialog:error:remove', this, [id]);
					this.getErrors().find('#error-' + id).slideUp(200, function(){
						// Remove the error container
						$(this).remove();

						// If no more errors, remove the important class from the dialog
						if(self.getErrors().find('.dialog-error').length == 0){
							self.getDialog().removeClass('dialog-important');
						}

						// Re-center the dialog as it's height changed
						self.center(true);
					});
				}
				return this;
			},

			clearErrors: function(){
				this.getDialog().removeClass('dialog-important');
				this.getErrors().find('.dialog-error').slideUp(200, function(){
					$(this).remove();
				});
				this.dispatcher().dispatch('dialog:error:clear', this);
				return this;
			},

			getHeader: function(){
				return this.getDialog().find('.dialog-header');
			},

			getBody: function(){
				return this.getDialog().find('.dialog-body');
			},

			getFooter: function(){
				return this.getDialog().find('.dialog-footer');
			},

			getErrors: function(){
				if(!this.getBody().find('.dialog-errors').length){
					this.getBody().prepend($('<div />', { class: 'dialog-errors' }));
				}
				return this.getBody().find('.dialog-errors');
			},

			getContent: function(){
				if(!this._content){
					this._content = this.getOverlay().hide();
				}
				this._content.html(this.getDialog());
				return this._content;
			},

			getDialog: function(){
				if(!this._dialog){
					var html = $('<div />', { class: this.getDialogClass() });

					// Add the header, if one
					if(this.hasHeader()){
						if(settings.header.blank()) settings.header = '&nbsp;';
						var header = $('<header />', { class: 'dialog-header' });
						header.append(Bean.Abstract.getContent(settings.header));
						if(settings.allowClose){
							header.append($('<button />', { class: 'close icon-close' }));
						}
						header.find(':not(:visible)').show();
						html.append(header);
					}

					// Always add the body
					var body = $('<div />', { class: 'dialog-body' });
					body.append(Bean.Abstract.getContent(settings.body));
					body.find(':not(:visible)').show();
					html.append(body);

					// Add the footer, if one
					if(this.hasFooter()){
						var footer = $('<footer />', { class: 'dialog-footer' });
						footer.append(Bean.Abstract.getContent(settings.footer));
						footer.find(':not(:visible)').show();
						html.append(footer);
					}

					// Add the content to the page so we can get it's dimensions below
					this.getOverlay().html(html);

					// Reset the size to whatever was defined
					console.log(body.innerWidth());
					html.css({
						width: settings.width,
						height: settings.height + (html.innerHeight() - html.height())
					});

					// Reset the body height to be equal to the defined height minus the header/footer, if specified
					body.css({
						height: settings.height - (
							(this.hasHeader() ? header.outerHeight() : 0) +
							(this.hasFooter() ? footer.outerHeight() : 0)
						)
					});

					this._dialog = html;
				}

				return this._dialog;
			},

			getOverlay: function(){
				if(!$('.overlay').length){
					$('body').append($('<div />', { class: 'overlay outside-window' }));
				}
				return $('.overlay');
			},

			getDialogClass: function(){
				return ['dialog', 'dialog-' + settings.theme].join(' ');
			},

			hasHeader: function(){
				return settings.header !== false;
			},

			hasFooter: function(){
				return !settings.footer.blank();
			},

			hasError: function(){
				return this.getBody().find('.dialog-error:not(.ignore)').length > 0;
			}
		};

		if(!$this.data('_dialog')){
			$this.data('_dialog', dialog);
		}

		if(!$form.data('_dialog')){
			$form.data('_dialog', dialog);
		}

		return $this.data('_dialog');
	};
}(jQuery));
