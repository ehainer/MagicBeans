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
					html,
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
					html = $('<div />').append($($this.data('confirmation')).show());
				}catch(e){
					// Assume the confirmation is just the text that needs to be shown
					html = $('<p />').html($this.data('confirmation'));
				}

				// Create the dialog body HTML content
				var dialogHtml = $('<div />').html(html.html()).html();
				if($this.data('buttons')){
					selectedButtons = $this.data('buttons').toLowerCase().split(/\s+/);
					dialogHtml += '<div class="dialog-buttons">';
					$.each(selectedButtons, function(index, button){
						if(buttons[button]) dialogHtml += buttons[button];
					});
					dialogHtml += '</div>';
				}

				// Create the dialog
				var dialog = new Bean.Dialog(title, dialogHtml, closeable);

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
					dialog.show(outside, width, height);

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