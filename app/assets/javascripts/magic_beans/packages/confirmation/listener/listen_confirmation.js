Listeners.Confirmation = {
	run: function(){
		Bean.debug('Initializing Confirmation Dialogs', function(){
			$('[data-confirmation]').each(function(){
				var $this = $(this),
					$form = $(this).closest('form'),
					width = $(this).data('width') || 500,
					height = $(this).data('height') || 'auto',
					title = $(this).data('title') || 'Please Confirm',
					outside = $(this).data('outside') == undefined ? false : $(this).data('outside'),
					closeable = $(this).data('closeable') !== false,
					footer,
					body,
					selectedButtons,
					buttons = {
						yes: '<button type="button" class="button button-small button-secondary affirmative">Yes</button>',
						no: '<button type="button" class="button button-small button-tertiary negative">No</button>',
						continue: '<button type="button" class="button button-small button-secondary affirmative">Continue</button>',
						cancel: '<button type="button" class="button button-small button-tertiary negative">Cancel</button>',
						ok: '<button type="button" class="button button-small button-secondary negative">OK</button>'
					};

				try
				{
					// See if confirmation is a jQuery selector, if so use that
					body = $($this.data('confirmation')).clone(true).show().outerHtml();
				}catch(e){
					// Assume the confirmation is just the text that needs to be shown
					body = $this.data('confirmation');
				}

				if($this.data('footer')){
					try
					{
						// See if confirmation is a jQuery selector, if so use that
						footer = $($this.data('footer')).clone(true).show().outerHtml();
					}catch(e){
						// Assume the confirmation is just the text that needs to be shown
						footer = $this.data('footer');
					}
				}

				// Add any buttons if provided
				if($this.data('buttons')){
					selectedButtons = $this.data('buttons').toLowerCase().split(/\s+/);
					body += '<div class="dialog-buttons">';
					$.each(selectedButtons, function(index, button){
						if(buttons[button]) body += buttons[button];
					});
					body += '</div>';
				}

				// Create the dialog
				var dialog = new Bean.Dialog(title, body, footer);

				dialog.setTheme($this.data('theme'));

				// When dialog is opened (shown), trigger the event on the containing form
				dialog.onOpen(function(){
					$form.trigger('dialog:open', dialog);
				});

				// When dialog is closed, trigger the event on the containing form
				dialog.onClose(function(){
					$form.trigger('dialog:close', dialog);
				});

				// Add the newly created dialog to the form element's data
				$form.data('dialog', dialog);

				$form.on('submit', function(event, override){

					// Show the dialog with the provided/default options
					dialog.show(outside, closeable, width, height);

					// Observe clicks on links, standard buttons, and input buttons and dispatch to the form when clicked
					dialog.getHtml().find('a, button, input[type="button"], input[type="submit"]').on('click', function(){
						$form.trigger('dialog:click', this);
					});

					// When anything with a "negative" class was clicked, just close the dialog
					dialog.getHtml().find('.negative').on('click', function(){
						dialog.hide();
					});

					// When anything with an "affirmative" class is clicked, close the dialog and continue submitting the form
					dialog.getHtml().find('.affirmative').on('click', function(){
						dialog.hide();
						// Additional argument here is passed in as "override" when the form is submitted, so the form will submit as usual
						$form.trigger('submit', true);
					});

					// If override is not specified, stop the form from submitting
					if(!override) return false;

					return true;
				});

				Bean.debug('Initialized Confirmation Dialog on %O', $this);
			});
		});
	}
};