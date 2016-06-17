(function($){
    $.fn.dateable = function(options){
        var self = this;

        if(!self.daterangepicker){
            console.error('DateRangePicker JS library not found!');
        }
        
        // Setup options
        self.options = $.extend(self.defaults, options);

        // Start daterangepicker
        self.daterangepicker.call(self.options.startCalendar, self.options.daterangepicker);

        self.defaults = {
            startCalendar: '',
            endCalendar: '',
            labelFormat: 'ddd, MMM Do YYYY',
            daterangepicker: {}
        };

        self.startInput = function(){
            return $(self.options.startCalendar);
        };

        self.endInput = function(){
            return $(self.options.endCalendar);
        };

        self.outsideClick = function(e, input){
            var target = $(e.target);
            if(e.type == 'focusin' || target.closest(input.parent()).length) return;
            self.picker().updateTime();
            input.trigger('dropfocus');
        };

        self.picker = function(){
            return $(self.options.startCalendar).data('daterangepicker');
        };

        self.picking = function(what){
            var pick = self.startInput().is(':focus') || self.startInput().hasClass('pseudo-focus') ? 'start' : 'end';
            if(typeof what == 'string'){
                return pick == what;
            }
            return pick;
        };

        self.pick = function(what){
            self.picker().show();
            self.picker().setPicking(what);
            $('body').trigger('bean:reboot:all');
        };

        self.setStartDate = function(date){
            if(typeof date == 'object'){
                self.picker().setStartDate(date);
            }else{

            }
        };

        self.setEndDate = function(date){
            if(typeof date == 'object'){
                self.picker().setEndDate(date);
            }else{
                
            }
        };

        self.getStartDate = function(format){
            if(typeof format == 'string'){
                return self.picker().startDate.format(format);
            }else{
                return (self.picker().startDate && self.picker().startDate.isValid() ? self.picker().startDate : false);
            }
        };

        self.getEndDate = function(format){
            if(typeof format == 'string'){
                return self.picker().endDate.format(format);
            }else{
                return (self.picker().endDate && self.picker().endDate.isValid() ? self.picker().endDate : false);
            }
        };

        self.startInput().on('focus', function(){
            self.pick('start');
        }).on('keydown', function(event){
            var code = event.keyCode || event.which;
            if(code == 9 && self.options.daterangepicker.singleDatePicker){
                self.picker().hide();
            }
        });

        self.endInput().on('focus', function(){
            self.pick('end');
        }).on('keydown', function(event){
            var code = event.keyCode || event.which;
            if(code == 9 && !event.shiftKey){
                event.preventDefault();
                self.picker().hide();
                $(this).trigger('blur');
            }
        });

        self.startInput().on('picking.daterangepicker.start picking.daterangepicker.end', function(event){
            $(self.options.startCalendar).toggleClass('pseudo-focus', (event.type + '.' + event.namespace) == 'picking.daterangepicker.start');
            $(self.options.endCalendar).toggleClass('pseudo-focus', (event.type + '.' + event.namespace) == 'picking.daterangepicker.end');
        });

        self.startInput().on('update.daterangepicker', function(){
            if(self.getStartDate()) self.startInput().val(self.getStartDate(self.options.daterangepicker.locale.format));
            if(self.getEndDate()) self.endInput().val(self.getEndDate(self.options.daterangepicker.locale.format));
        });

        self.startInput().on('apply.daterangepicker', function(){
            self.startInput().trigger('update.daterangepicker', self.picker());
            if(!self.options.daterangepicker.singleDatePicker && self.picking('start')){
                self.endInput().focus();
            }
        });

        self.startInput().on('hide.daterangepicker', function(){
            self.startInput().removeClass('pseudo-focus');
            self.endInput().removeClass('pseudo-focus');
        });

        if(self.options.daterangepicker.timePicker){
            var oldTime = '';
            var startTimeInput = self.picker().container.find('.calendar.left .daterangepicker-time-input');
            var endTimeInput = self.picker().container.find('.calendar.right .daterangepicker-time-input');

             self.picker().container.find('.calendar .daterangepicker-time-input').on('focus', function(){
                var input = $(this);
                var pos = this.selectionStart;
                var picking = $(this).closest('.calendar.left').length ? 'start' : 'end';
                oldTime = this.value;
                self.pick(picking);
                this.selectionStart = pos; this.selectionEnd = pos;

                var change = self.options.daterangepicker.timePickerIncrement;
                var nearest = change * 60 * 1000;
                var date = (self.picking('start') ? self.getStartDate() : self.getEndDate()).clone();
                var defaultTime = moment(Math.floor((+date) / nearest) * nearest);
                if(self.picking('start')){
                    startTimeInput.next('.daterangepicker-time-options').toggle(self.picking('start'));
                    var option = startTimeInput.next('.daterangepicker-time-options').find('li[data-time="' + defaultTime.format('h:mm A') + '"]');
                    if(option.length) startTimeInput.next('.daterangepicker-time-options').scrollTop(option.first().position().top);
                }else if(self.picking('end')){
                    endTimeInput.next('.daterangepicker-time-options').toggle(self.picking('end'));
                    var option = endTimeInput.next('.daterangepicker-time-options').find('li[data-time="' + defaultTime.format('h:mm A') + '"]');
                    if(option.length) endTimeInput.next('.daterangepicker-time-options').scrollTop(option.first().position().top);
                }
            }).on('dropfocus', function(){
                $(this).next('.daterangepicker-time-options').hide();
                $(this).trigger('blur');
            }).on('keydown', function(event){
                var code = event.keyCode || event.which;
                var date = (self.picking('start') ? self.getStartDate() : self.getEndDate()).clone();
                if(code == 13 || code == 9){
                    self.picker().changeTime($(this).val());
                    $(this).trigger('dropfocus');
                }
                if((code == 38 || code == 40) && (date.diff(self.picker().minDate) > 0 || code == 38)){
                    event.preventDefault();
                    var change = self.options.daterangepicker.timePickerIncrement;
                    var pos = this.selectionStart;
                    if(date && date.isValid() && (date.minute() % change) != 0){
                        var nearest = change * 60 * 1000;
                        // Round to nearest minute increment and set date
                        if(code == 38) self.picker().changeTime(moment(Math.ceil((+date) / nearest) * nearest));
                        var roundDown = moment(Math.floor((+date) / nearest) * nearest);
                        if(code == 40){
                            if(roundDown.isBefore(moment())){
                                self.picker().changeTime(moment());
                            }else{
                                self.picker().changeTime(roundDown);
                            }
                        }
                    }else{
                        // Increase/Decrease time by minute increment
                        if(code == 38) self.picker().changeTime(change);
                        var roundDown = -change;
                        if(code == 40){
                            //console.log(date.subtract(change, 'minutes').isBefore(moment()));
                            if(date.subtract(change, 'minutes').isBefore(moment())){
                                self.picker().changeTime(moment());
                            }else{
                                self.picker().changeTime(roundDown);
                            }
                        }
                    }
                    this.selectionStart = pos; this.selectionEnd = pos;
                }
            });

            $(document).on('mousedown.daterangepicker-time-input', function(e){ self.outsideClick(e, startTimeInput); self.outsideClick(e, endTimeInput); })
                        .on('touchend.daterangepicker-time-input', function(e){ self.outsideClick(e, startTimeInput); self.outsideClick(e, endTimeInput); })
                        .on('focusin.daterangepicker-time-input', function(e){ self.outsideClick(e, startTimeInput); self.outsideClick(e, endTimeInput); });
        }

        self.startInput().trigger('update.daterangepicker', self.picker());

        return this;
    };
})(jQuery);