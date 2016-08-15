Listeners.Dialog = {
	run: function(){
		Bean.debug('Initializing Dialogs', function(){
			$('[data-dialog]').each(function(){
				var $this = $(this),
					$form = $(this).closest('form'),
					width = $(this).data('width') || 500,
					height = $(this).data('height') || 'auto',
					outside = $(this).data('outside') == undefined ? false : $(this).data('outside'),
					closeable = $(this).data('closeable') !== false,
					header = $(this).data('header'),
					footer = $(this).data('footer'),
					body = $(this).data('dialog'),
					theme = $(this).data('theme'),
					selectedButtons = ($(this).data('buttons') || '').toLowerCase().split(/\s+/),
					animation = $(this).data('animation') || 'shake',
					buttons = {
						yes: '<button type="button" class="button button-small button-secondary affirmative">Yes</button>',
						no: '<button type="button" class="button button-small button-tertiary negative">No</button>',
						continue: '<button type="button" class="button button-small button-secondary affirmative">Continue</button>',
						cancel: '<button type="button" class="button button-small button-tertiary negative">Cancel</button>',
						ok: '<button type="button" class="button button-small button-secondary negative">OK</button>'
					};

				var dialog = $this.dialog({
					header: header,
					body: body,
					footer: footer,
					theme: theme,
					width: width,
					height: height,
					allowClose: closeable,
					allowOutsideClose: outside,
					errorAnimation: animation
				});

				// Add any buttons if provided
				if(!selectedButtons.blank()){
					var buttonHtml = $('<div />', { class: 'dialog-buttons' });
					$.each(selectedButtons, function(index, button){
						if(buttons[button]) buttonHtml.append(buttons[button]);
					});
					dialog.getBody().append(buttonHtml);
				}

				// When dialog is opened (shown), trigger the event on the containing form
				dialog.onShow(function(){
					$form.trigger('dialog:show', this);
					$this.trigger('dialog:show', this);
				});

				// When dialog is closed, trigger the event on the containing form
				dialog.onHide(function(){
					$form.trigger('dialog:hide', this);
					$this.trigger('dialog:hide', this);
				});

				dialog.onClick(function(button){
					$form.trigger('dialog:click', [this, button]);
					$this.trigger('dialog:click', [this, button]);
				});

				$form.on('submit', function(event, override){
					// If override is not specified, stop the form from submitting
					if(!override) return false;
					return true;
				});

				$this.on('click', function(event){
					event.stopImmediatePropagation();

					// Show the dialog with the provided/default options
					dialog.show();

					// When anything with a "negative" class was clicked, just close the dialog
					dialog.getBody().find('.negative').on('click', function(){
						dialog.hide();
					});

					// When anything with an "affirmative" class is clicked, close the dialog and continue submitting the form
					dialog.getBody().find('.affirmative').on('click', function(){
						dialog.hide();
						// Additional argument here is passed in as "override" when the form is submitted, so the form will submit as usual
						$form.trigger('submit', true);
					});
				});

				Bean.debug('Initialized Dialog on %O', $this);
			});
		});
	}
};