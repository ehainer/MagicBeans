Listeners.Confirmation = {
	run: function(){
		$('[data-confirmation]').each(function(){
			var $form = $(this).closest('form');
			var $this = $(this);
			var width = $this.data('width') || 500;
			var height = $this.data('height') || 'auto';
			var title = $this.data('title') || 'Please Confirm';
			var close = $this.data('close') == undefined ? false : $this.data('close');
			var yesno = '<button type="button" class="button button-small button-tertiary confirm-no">No</button><button type="button" class="button button-small button-secondary confirm-yes">Yes</button>';
			$form.on('submit', function(event, override){
				var dialog = new Bean.Dialog(title, '<div class="dialog-content">' + $this.data('confirmation') + '</div><div class="confirm-buttons">' + yesno + '</div>', true);
				dialog.show(close, width, height);
				dialog.getDialog().find('.confirm-no').on('click', function(){
					dialog.hide();
				});
				dialog.getDialog().find('.confirm-yes').on('click', function(){
					dialog.hide();
					$form.trigger('submit', true);
				});
				if(!override){
					return false;
				}
				return true;
			});
		});
	}
};