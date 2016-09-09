Listeners.Crop = {
	run: function(){
		Bean.debug('Initializing Crop Dialogs', function(){
			$('[data-crop]').on('click', function(event){
				event.preventDefault();
				var self = this,
					form = $(this).closest('form'),
					type = $(this).data('type'),
					action = $(this).data('crop'),
					remote = $(this).data('remote') || false;

				$.ajax({
					url: action.replace('/crop', '/image'),
					data: { type: type }
				}).done(function(response){
					// Create cropper instance
					var cropper = new Bean.Crop();

					// Show the cropper with the image specified
					cropper.show(response.url, type);

					// Upon cropping (save/submit button clicked within the dialog), perform any actions
					// necessary to crop the image. The single argument passed contains the data required
					// to crop the image, x/y coordinates and width/height of the image to be created
					cropper.onCrop(function(data){
						var formHtml = '<form action="' + action + '" method="POST">';
						formHtml += '<input type="hidden" name="authenticity_token" value="' + Bean.Abstract.getAuthenticityToken() + '" />';
						formHtml += '<input type="hidden" name="_method" value="patch" />';
						formHtml += '<input type="hidden" name="crop[ajax]" value="' + remote + '" />';
						formHtml += '<input type="hidden" name="crop[type]" value="' + type + '" />';
						formHtml += '<input type="hidden" name="crop[x]" value="' + data.x + '" />';
						formHtml += '<input type="hidden" name="crop[y]" value="' + data.y + '" />';
						formHtml += '<input type="hidden" name="crop[width]" value="' + data.width + '" />';
						formHtml += '<input type="hidden" name="crop[height]" value="' + data.height + '" />';
						formHtml += '</form>';

						var form = $(formHtml);

						if(remote){
							$.ajax({
								url: action + '.json',
								method: 'POST',
								data: form.serializeForm(),
								dataType: 'json'
							}).done(function(response){
								$(self).trigger('crop:success', [response, cropper]);
							}).fail(function(response){
								$(self).trigger('crop:failure', [response, cropper]);
							});
						}else{
							form.submit();
						}
					});
				});
			});
		});
	}
}
