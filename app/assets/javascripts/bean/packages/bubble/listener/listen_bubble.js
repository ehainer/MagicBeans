Listeners.Bubble = {
    run: function(){
        $('[data-bubble]').each(function(){
            if($('<div />').html($(this).data('bubble')).find('img').length && !$(this).data('loaded_images') && !Bean.Abstract.isMobile()){
                var loader = new Bean.Loader();
                var self = $(this);
                loader.preload($('<div />').html($(this).data('bubble')).find('img')).done(function(){
                    self.data('loaded_images', true);
                    //self.trigger('mouseenter');
                });
            }
        });

        $('[data-bubble]').hover(function(){
            var container = $(this).closest($(this).data('group')).length ? $(this).closest($(this).data('group')).first() : $(this).parent();
            var content = $('<div />').html($(this).html());
            var contentWidth = Bean.Abstract.getWidth(content);
            var contentHeight = Bean.Abstract.getHeight(content);
            if (!container.find('.bubble-container').length) {
                container.addClass('bubble').prepend('<div class="bubble-container"><div class="bubble-inner"><div class="bubble-title">' + $(this).data('bubble') + '</div></div></div>');
                var bubbleContainer = container.find('.bubble-container');
                var endWidth = Bean.Abstract.getWidth('<div class="bubble"><div class="bubble-container"><div class="bubble-inner"><div class="bubble-title">' + $(this).data('bubble') + '</div></div></div></div>');
                var endHeight = Bean.Abstract.getHeight('<div class="bubble"><div class="bubble-container"><div class="bubble-inner"><div class="bubble-title">' + $(this).data('bubble') + '</div></div></div></div>');
                bubbleContainer.css({
                    marginLeft: (-((endWidth / 2) - 6)) + $(this).position().left + (contentWidth / 2),
                    top: $(this).position().top - endHeight,
                    width: endWidth
                });
                bubbleContainer.stop().animate({
                    marginLeft: (-((endWidth / 2) - 6)) + $(this).position().left + (contentWidth / 2),
                    top: $(this).position().top - endHeight,
                    width: endWidth
                }, 400);
            } else {
                var bubbleContainer = container.find('.bubble-container');
                var endWidth = Bean.Abstract.getWidth('<div class="bubble"><div class="bubble-container"><div class="bubble-inner"><div class="bubble-title">' + $(this).data('bubble') + '</div></div></div></div>');
                var endHeight = Bean.Abstract.getHeight('<div class="bubble"><div class="bubble-container"><div class="bubble-inner"><div class="bubble-title">' + $(this).data('bubble') + '</div></div></div></div>');
                bubbleContainer.stop().animate({
                    marginLeft: (-((endWidth / 2) - 6)) + $(this).position().left + (contentWidth / 2),
                    top: $(this).position().top - endHeight,
                    width: endWidth
                }, 400);
                bubbleContainer.find('.bubble-title').html($(this).data('bubble'));
                bubbleContainer.find('.bubble-inner').css('border-color', $(this).find('.list-circle').css('border-color'));
            }
            container.on('mouseleave', function() {
                container.removeClass('bubble').find('.bubble-container').remove();
            });
        }, function() {});
    }
};