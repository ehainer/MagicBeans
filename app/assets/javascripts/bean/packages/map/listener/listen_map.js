Listeners.Map = {
	run: function(){
		$('[data-address]').each(function(){
			try
			{
				var address = $(this).data('address');
				var zoom = $(this).data('zoom');
				var scroll = $(this).data('scroll');
				var move = $(this).data('move');
				var mapArea = $(this);
				var map = $('<input />').geocomplete({
					map: mapArea,
					location: address,
					mapOptions: {
						zoom: zoom,
						scrollwheel: scroll,
						draggable: move
					}
				}).one('geocode:result', function(){
					map.geocomplete('map').setZoom(zoom);
				}).on('geocode:result geocode:error geocode:multiple', function(event, result){
					mapArea.trigger(event.type, [event, result, map.geocomplete('map')]);
				});

				if($.trim(address) == '') map.trigger('geocode:error');
			}catch(e){
				console.warn('[MagicBeans] Unable to initialize element with [data-address], perhaps the google class could not be loaded.');
			}
		});

		$('[data-location]').each(function(){
			try
			{
				var input = $(this);
				var location = $($(this).data('location'));
				var zoom = $(this).data('zoom') || 'auto';
				var scroll = $(this).data('scroll');
				var move = $(this).data('move');
				var drag = $(this).data('drag');
				var prefix = $(this).data('prefix') || input.attr('name').replace(/\[[A-Z0-9_]+\]/i, '');

				if(drag){
					var lat = input.nextAll('.' + prefix + '-latitude');
					var lng = input.nextAll('.' + prefix + '-longitude');
					if(!lat.length) input.after('<input type="hidden" name="' + prefix + '[latitude]" value="" class="' + prefix + '-latitude" />');
					if(!lng.length) input.after('<input type="hidden" name="' + prefix + '[longitude]" value="" class="' + prefix + '-longitude" />');
				}

				var map = input.geocomplete({
					map: location,
					blur: true,
					autoselect: true,
					geocodeAfterResult: true,
					location: input.val(),
					mapOptions: {
						zoom: (isNaN(zoom) ? 14 : zoom),
						scrollwheel: scroll,
						draggable: move
					},
					markerOptions: {
						draggable: drag
					}
				}).on('geocode:result', function(event, result){
					if(zoom != 'auto') map.geocomplete('map').setZoom(zoom);
					input.trigger('geocode:dragged', result.geometry.location)
					location.removeClass('grayscale');
				}).on('geocode:dragged', function(event, location){
					if(drag){
						console.log(location.lat(), location.lng());
						input.nextAll('.' + prefix + '-latitude').val(location.lat());
						input.nextAll('.' + prefix + '-longitude').val(location.lng());

						var geocoder = new google.maps.Geocoder();
						var latlng = new google.maps.LatLng(location.lat(), location.lng());
						geocoder.geocode({ location: latlng }, function(results, status){
							if(status == google.maps.GeocoderStatus.OK){
								if(results[0]){
									input.val(results[0].formatted_address);
								}
							}
							console.log(status, results);
						});
					}
				}).on('geocode:error', function(event, result){
					map.geocomplete('map').setZoom(1);
					map.geocomplete('map').setCenter({ lat: 0, lng: 0 })
					location.addClass('grayscale');
				});

				if($.trim(input.val() == '')) map.trigger('geocode:error', 'Blank Location');
			}catch(e){
				console.warn('[MagicBeans] Unable to initialize element with [data-location], perhaps the google class could not be loaded.');
			}
		});

		$('[data-location]').trigger('geocode');
	}
};