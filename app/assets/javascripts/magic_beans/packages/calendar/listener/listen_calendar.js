Listeners.Calendar = {
	run: function(){
		$('[data-date]').each(function(){
			var id = Bean.Abstract.getId();
			var self = $(this);
			var startCalendar = self;
			var endCalendar = self.data('end') && $(self.data('end')).length ? $(self.data('end')) : self.nextAll('[data-date="end"]').first();
			var format = self.data('format') || 'dddd, MMM Do YYYY';
			var isSingle = self.data('date') === true;
			var isTimeable = self.data('time') === true;
			var increment = parseInt(self.data('increment')) || 30;
			var startAt = startCalendar.data('iso8601') ? moment(startCalendar.data('iso8601'), 'YYYY-MM-DDTHH:mm:ssZ') : (startCalendar.val() ? moment(startCalendar.val(), format) : moment().startOf('day'));
			var endAt = endCalendar.data('iso8601') ? moment(endCalendar.data('iso8601'), 'YYYY-MM-DDTHH:mm:ssZ') : (endCalendar.val() ? moment(endCalendar.val(), format) : moment());

			if(isSingle){
				if(!$('#date-' + id).length) startCalendar.after('<input type="hidden" name="' + startCalendar.attr('name') + '" value="" id="date-' + id + '" />');
			}else if(startCalendar.data('date') != 'end'){
				if(!$('#date-start-' + id).length) startCalendar.after('<input type="hidden" name="' + startCalendar.attr('name') + '" value="" id="date-start-' + id + '" />');
				if(!$('#date-end-' + id).length) endCalendar.after('<input type="hidden" name="' + endCalendar.attr('name') + '" value="" id="date-end-' + id + '" />');
			}

			self.on('update.daterangepicker', function(event, picker){
				if(isSingle){
					if(picker.startDate && picker.startDate.isValid()) $('#date-' + id).val(picker.startDate.format('YYYY-MM-DDTHH:mm:ssZ'));
				}else{
					if(picker.startDate && picker.startDate.isValid()) $('#date-start-' + id).val(picker.startDate.format('YYYY-MM-DDTHH:mm:ssZ'));
					if(picker.endDate && picker.endDate.isValid()) $('#date-end-' + id).val(picker.endDate.format('YYYY-MM-DDTHH:mm:ssZ'));
				}
			});

			if(Bean.Abstract.isMobile() && Bean.Support.hasInputType('date')){
				$(this).attr('type', 'date').attr('min', moment().format('YYYY-MM-DD'));
			}else{
				var calendar = $('#calendar-' + id);
				$(startCalendar, endCalendar).prop('readonly', true);

				// Don't calendarize end date inputs, that is handled by the start date input logic
				if(startCalendar.data('date') != 'end'){
					self.after($('<div id="calendar-' + id + '" class="calendar-container"></div>').css('position', 'relative'));

					calendar.dateable({
						startCalendar: startCalendar,
						endCalendar: endCalendar,
						daterangepicker: {
							parentEl: calendar,
							singleDatePicker: isSingle,
							timePicker: isTimeable,
							timePickerIncrement: increment,
							autoApply: true,
							autoUpdateInput: false,
							containerClass: '',
							startDate: startAt,
							endDate: endAt,
							minDate: (self.data('min') !== false ? moment() : false),
							locale: {
								format: format
							}
						}
					});

					var classes = startCalendar.attr('class').split(' ').compact();
					if(classes.includes('calendar.*')){
						classes.each(function(klass){
							if(/^calendar.*/.test(klass)){
								startCalendar.removeClass(klass);
								startCalendar.data('daterangepicker').container.addClass(klass);
							}
						});
					}
				}
			}
		});
	}
};