Listeners.Placeholder = {
	run: function(){
		$('input[placeholder], input[data-placeholder]').each(function(){
			var placeholder = $(this).attr('placeholder') || $(this).data('placeholder');
			if(Bean.Support.hasPlaceholder()){
				$(this).attr('placeholder', placeholder);
			}else{
				var $this = $(this);
				$(this).on('focus', function(){
					if($this.hasClass('placeholding') && $this.val() == placeholder){
						$this.val('').removeClass('placeholding');
					}
				}).on('blur', function(){
					if($.trim($this.val()) == ''){
						$this.addClass('placeholding').val(placeholder);
					}
				});
				$this.trigger('blur');
			}
		});
	}
};