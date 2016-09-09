Listeners.Numeric = {
	run: function(){
		$('[data-numeric]').each(function(){
			var negative = $(this).data('negative');
			var decimal = $(this).data('decimal');
			if(Bean.Support.hasInputType('number') && Bean.Abstract.isMobile()){
				$(this).attr('type', 'number');
			}
			$(this).on('keypress', function(event){
				var code = event.keyCode || event.which;
				if($.inArray(code, [8, 9, 27, 13]) !== -1 || (code == 65 && event.ctrlKey === true) || (code >= 35 && code <= 39) || (negative === true && code == 45) || (decimal === true && code == 46)){
					return;
				}
				if(code < 48 || code > 57){
					event.preventDefault();
				}
			});
		});
	}
};