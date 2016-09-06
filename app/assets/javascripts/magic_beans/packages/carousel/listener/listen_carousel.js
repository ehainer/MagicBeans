Listeners.Carousel = {
	run: function(){
		Bean.debug('Initializing Carousels', function(){
			$('[data-carousel]').each(function(){
				var $this = $(this);

				var options = {
					slidesToShow: $this.data('slides') || 1,
					slidesToScroll: $this.data('scroll') || 1,
					dots: $this.data('dots') || false,
					centerMode: $this.data('center') || false
				};

				$(this).slick(options);

				Bean.debug('Initialized Carousel', function(){
					Bean.debug('Element: %o', $this);
					Bean.debug('Options: %O', options);
				});
			});
		});
	}
};
