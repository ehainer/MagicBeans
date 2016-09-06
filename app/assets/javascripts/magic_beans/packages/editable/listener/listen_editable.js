Listeners.Editable = {
	run: function(){
		Bean.debug('Initializing WYSIWYG Editors', function(){
			$('[data-editable]').each(function(){
				var $this = $(this);

				if($this.attr('id').blank()){
					$this.attr('id', 'editor-' + Bean.Abstract.getId())
				}

				var options = {
					selector: '[data-editable]#' + $this.attr('id'),
					elementpath: false,
					statusbar: false,
					menubar: false,
					resize: false,
					skin_url: '/assets/skins/' + $this.data('editable'),
					toolbar: $this.data('toolbar') || 'bold italic underline',
					plugins: $this.data('plugins'),
					width: '100%',
					height: $this.height(),
					body_class: $this.attr('class'),
					content_css: Bean.Config.get('stylesheet'),
					init_instance_callback: function(editor){
						$(editor.editorContainer).addClass($this.attr('class'));
						var position = $this.data('position') || 'top';
						if(position.toString().toLowerCase() == 'bottom'){
							var toolbar = $(editor.editorContainer).find('.mce-toolbar-grp');
							var editArea = $(editor.editorContainer).find('.mce-edit-area');
							editArea.after(toolbar).css('border', 'none');
						}
					},
					setup: function(editor){
						editor.on('focus blur', function(event){
							$(editor.targetElm).trigger('pseudo:' + event.type);
							$(editor.editorContainer).toggleClass('pseudo-focus', event.type == 'focus');
						});
					}
				};

				tinymce.init(options);

				Bean.debug('Initialized WYSIWYG Editor', function(){
					Bean.debug('Element: %o', $this);
					Bean.debug('Options: %O', options);
				});
			});
		});
	}
};