Listeners.Upload = {
	run: function(){
		Dropzone.autoDiscover = false;
		//return;

		$('[data-upload]').each(function(){
			var field = $(this);
			var form = field.closest('form');

			if(!field.closest('.fallback').length) field.wrap('<div class="fallback"></div>');
			if(!field.closest('.dropzone').length) field.closest('.fallback').wrap('<div class="dropzone"></div>');

			var uploadName = field.attr('name').replace(/\[\]$/, '').match(/\[([A-Z0-9_]+)\]/i)[1];
			var multiple = field.is('[multiple]');
			var dropzone = field.closest('.dropzone');
			var resource = field.data('resource');
			var uploadType = field.data('type');
			var accept = field.data('accept');
			var uploadMax = field.data('max') || null;
			var uploadUrl = field.data('upload');
			var preview = field.data('preview') ? $('<div />').html($(field.data('preview')).show()).html() : Dropzone.prototype.defaultOptions.previewTemplate;

			Bean.debug('Initializing Uploader With Options: %O', field.data(), 'info');

			dropzone.addClass(field.attr('class'));

			dropzone.dropzone({
				url: uploadUrl,
				maxFiles: uploadMax,
				previewTemplate: preview,
				uploadMultiple: multiple,
				parallelUploads: (multiple ? (field.data('parallel') || 10) : 1),
				addRemoveLinks: true,
				acceptFiles: accept,
				paramName: function(n){
					// Very important, if multiple uploads is set, the param name must end in "[]", not "[n]", otherwise
					// rails sees it as a hash param rather than an array. Bad news bears
					return field.attr('name').replace(/\[\]$/, '') + (multiple ? '[]' : '');
				},
				sending: function(file, xhr, data){
					// Add the authenticity token to the request
					data.append('authenticity_token', Bean.Abstract.getAuthenticityToken());

					// Add each hidden input field to the ajax request data
					form.find('input').each(function(){
						if($(this).attr('name') != '_method') data.append($(this).attr('name'), $(this).val());
					});
				},
				success: function(file, response){
					// For every upload, add the upload id to the commit list
					$.each(response.uploads, function(key, uploads){
						// Add the id to the file element, used when the removedfile action occurs (see init below)
						$(file.previewElement).attr('data-id', uploads[0]);

						$.each(uploads, function(index, id){
							if(!form.find('input[value="' + id + '"]').length) form.prepend('<input type="hidden" name="' + key + '[commit][]" value="' + id + '" />');
						});
					});

					// Since success is also dispatched for each file in successmultiple,
					// exit here, we deal with the same logic below this line in the successmultiple event
					if($.isArray(file)) return;

					// Dispatch that an upload occurred
					form.trigger('upload:success', [file, response]);
				},
				successmultiple: function(files, response){
					$.each(files, function(index, file){
						// Dispatch that an upload occurred
						form.trigger('upload:success', [file, response]);

						$.each(response.uploads, function(key, uploads){
							// Add the id to the file element, used when the removedfile action occurs (see init below)
							$(file.previewElement).attr('data-id', uploads[index]);
						});
					});
				},
				error: function(file, message, xhr){
					console.log(message);
					form.trigger('upload:failure', [message, xhr]);
				},
				init: function(){
					var dz = this;

					// When a file is removed from the dropzone, append a hidden file input with the id
					// of the upload, so it will actually be removed when the form is submitted
					dz.on('removedfile', function(file){
						var id   = $(file.previewElement).data('id'),
							name = field.attr('name').replace(/\[.*$/i, ''),
							file = $(file.previewElement).data('file') === true;

						// Remove the commit input
						form.find('input[name="' + name + '[commit][]"][value="' + id + '"]').remove();

						// Add the remove input
						form.prepend('<input type="hidden" name="' + name + '[remove][' + (file ? 'file' : 'temp') + '][]" value="' + id + '" />');
					});

					// If set to preserve file uploads, iterate through each uploaded file associated with
					// the model and add to the file upload box upon initialization
					if(!$.isEmptyObject(field.data('files'))){
						$.each(field.data('files'), function(index, file){
							Listeners.Upload.utility.getFileObject(file, index, function(fileObject, id){
								dz.files.push(fileObject);
								dz.options.addedfile.call(dz, fileObject);
								$(fileObject.previewElement).attr('data-id', id);
								$(fileObject.previewElement).attr('data-file', 'true');
								dz._enqueueThumbnail(fileObject);
								dz.options.complete.call(dz, fileObject);
								dz._updateMaxFilesReachedClass();
							});
						});

						// Add class indicating the upload box has files
						dropzone.addClass('dz-has-files');
					}

					dz.on('addedfile', function(file){
						// Add class indicating the upload box has files
						dropzone.addClass('dz-has-files');

						// If single file upload, upon each upload, remove any previously uploaded files
						if(!multiple){
							$(file.previewElement).closest('.dropzone').find('.dz-preview').each(function(){
								if($(this).get(0) != $(file.previewElement).get(0)){
									$(this).slideUp(300, function(){
										$(this).remove();
									});
								}
							});
						}
					});
				}
			}).on('dragstart dragover dragenter', function(){
				$(this).addClass('over dz-drag-hover');
			}).on('dragend dragleave drop', function(){
				$(this).removeClass('over');
			});
		});
	},

	utility: {
		getFileBlob: function(url, cb){
			var xhr = new XMLHttpRequest();
			xhr.open("GET", url);
			xhr.responseType = "blob";
			xhr.addEventListener('load', function(){
				cb(xhr.response);
			});
			xhr.send();
		},

		blobToFile: function(blob, name){
			blob.lastModifiedDate = new Date();
			blob.name = name;
			blob.status = "added";
			blob.accepted = true;
			return blob;
		},

		getFileObject: function(file, id, cb){
			Listeners.Upload.utility.getFileBlob(file.url, function(blob){
				cb(Listeners.Upload.utility.blobToFile(blob, file.name), id);
			});
		}
	}
};
