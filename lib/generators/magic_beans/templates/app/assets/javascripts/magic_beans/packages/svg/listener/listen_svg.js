Listeners.Svg = {
	run: function(){
		var injectOptions = {
			each: function(svg){
				if($(svg).data('size')){
					var size = $(svg).data('size').toString().toLowerCase().split('x');
					if(size.length == 1){
						$(svg).attr('width', parseFloat(size[0]));
						$(svg).attr('height', parseFloat(size[0]));
					}else{
						$(svg).attr('width', parseFloat(size[0]));
						$(svg).attr('height', parseFloat(size[1]));
					}
				}
			}
		};

		SVGInjector($('[data-svg]').toArray(), injectOptions);
	}
};