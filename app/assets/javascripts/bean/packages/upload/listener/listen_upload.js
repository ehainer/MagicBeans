Listeners.Upload = {
	run: function(){
		Dropzone.autoDiscover = false;

		$('[data-upload]').each(function(){
			var field = $(this);
			var form = field.closest('form');

			if(!field.closest('.fallback').length) field.wrap('<div class="fallback"></div>');
			if(!field.closest('.dropzone').length) field.closest('.fallback').wrap('<div class="dropzone"></div>');

			var uploadName = field.attr('name').replace(/\[\]$/, '').match(/\[([A-Z0-9_]+)\]/i)[1];
			var multiple = field.is('[multiple]');
			var dropzone = field.closest('.dropzone');
			var preserve = field.data('preserve');
			var uploadUrl = field.data('upload');
			var removeUrl = field.data('remove');
			var preview = field.data('preview') ? $('<div />').html($(field.data('preview')).show()).html() : Dropzone.prototype.defaultOptions.previewTemplate;
			var method = (form.find('input[name="_method"]').val() || form.attr('method')).toLowerCase();

			Bean.debug('Initializing Uploader With Options: %O', field.data(), 'info');

			dropzone.addClass(field.attr('class'));

			dropzone.dropzone({
				url: uploadUrl,
				maxFiles: field.data('max') || null,
				previewTemplate: preview,
				uploadMultiple: multiple,
				parallelUploads: (multiple ? (field.data('parallel') || 10) : 1),
				addRemoveLinks: true,
				acceptFiles: field.data('accept'),
				paramName: function(n){
					// Very important, if multiple uploads is set, the param name must end in "[]", not "[n]", otherwise
					// rails sees it as a hash param rather than an array. Bad news bears
					return field.attr('name').replace(/\[\]$/, '') + (field.is('[multiple]') ? '[]' : '');
				},
				sending: function(file, xhr, data){
					// Parse form action attribute for the id of the record, add the id to the ajax data if found
					if((matches = form.attr('action').match(/\/([0-9]+)/)) !== null) data.append('id', matches[1]);

					// Add each hidden input field to the ajax request data
					form.find('input').each(function(){
						if($(this).attr('name') != '_method') data.append($(this).attr('name'), $(this).val());
					});
				},
				success: function(file, response){
					// Upon successful upload, iterate through the associated uploads and fetch the id of the upload
					// and set the id on the file preview element data-id attribute
					$.each(response.uploads[uploadName], function(index, upload){
						if(upload.name == file.name){
							$(file.previewElement).attr('data-id', upload.id);
						}
					});

					// Set all provided html attributes
					$.each(response.html, function(key, value){
						form.attr(key, value);
					});

					// If method input field is not found, create it
					if(!form.find('input[name="_method"]').length){
						form.prepend('<input type="hidden" name="_method" value="" />');
					}
					// Set the form input method depending on the state of the resource object
					form.find('input[name="_method"]').val(response.method);
				},
				init: function(){
					var dz = this;

					// When a file is removed from the dropzone, append a hidden file input with the id
					// of the upload, so it will actually be removed when the form is submitted
					dz.on('removedfile', function(file){
						var id   = $(file.previewElement).data('id'),
							name = field.attr('name').replace(/\[\]$/, '') + '[remove][]';

						form.prepend('<input type="hidden" name="' + name + '" value="' + id + '" />');
					});

					// If set to preserve file uploads, iterate through each uploaded file associated with
					// the model and add to the file upload box upon initialization
					if(preserve){
						$.each(field.data('files'), function(index, file){
							Listeners.Upload.utility.getFileObject(file, index, function(fileObject, id){
								dz.files.push(fileObject);
								dz.options.addedfile.call(dz, fileObject);
								$(fileObject.previewElement).attr('data-id', id);
								dz._enqueueThumbnail(fileObject);
								dz.options.complete.call(dz, fileObject);
								dz._updateMaxFilesReachedClass();
							});
						});

						// Add class indicating the upload box has files
						if(!$.isEmptyObject(field.data('files'))) dropzone.addClass('dz-has-files');
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
