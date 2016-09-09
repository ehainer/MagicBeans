$.fn.value = function(){
	if(arguments.length == 0){
		return $.inArray(this.prop('tagName').toLowerCase(), ['input', 'textarea', 'select']) != -1 ? this.val() : this.html();
	}else{
		var val = arguments[0];
		return this.each(function(){
			$.inArray($(this).prop('tagName').toLowerCase(), ['input', 'textarea', 'select']) != -1 ? $(this).val(val) : $(this).html(val);
		});
	}
}

$.fn.amount = function(){
	var amt = parseFloat(this.value().replace(/[^0-9\.\-]+/g, ''));
	return (!isNaN(amt) ? amt : 0);
}

$.fn.format = function(){
	if(this.attr('data-decimal')){
		val = parseFloat(this.value().replace(/[^0-9\.]/g, '')).toCurrency(10, '.', '').toString();
		val = val.replace(/\.$/, '');
		val = Number(val).toString();
		this.value(val);
	}
	if(this.attr('data-currency')){
		val = parseFloat(this.value().replace(/[^0-9\.\-]/g, '')).toCurrency();
		this.value(val);
	}
	if(this.attr('data-format')){
		val = this.attr('data-format').replace('__', this.value());
		this.value(val);
	}
	return this;
}

$.fn.numeric = function(negative){
	this.on('keypress', function(event){
		var code = event.keyCode || event.which;
		if($.inArray(code, [46, 8, 9, 27, 13]) !== -1 || (code == 65 && event.ctrlKey === true) || (code >= 35 && code <= 39) || (negative === true && code == 45)){
			return;
		}
		if(code < 48 || code > 57){
			event.preventDefault();
		}
	});
	return this;
}

$.fn.blank = function(){
	if(!this.val || $.trim(this.val()) == '' || this.val() == undefined || this.val() == null){
		return true;
	}
	return false;
}

$.fn.wait = function(time){
	var self = this;
	var dfr = $.Deferred();
	setTimeout(function(){
		dfr.resolveWith(self);
	}, time);
	return dfr.promise();
}

// http://stackoverflow.com/questions/1184624/convert-form-data-to-javascript-object-with-jquery
$.fn.serializeForm = function(){
	var o = {};
	var a = this.serializeArray();
	$.each(a, function(){
		if(o[this.name] !== undefined){
			if(!o[this.name].push){
				o[this.name] = [o[this.name]];
			}
			o[this.name].push(this.value || '');
		}else{
			o[this.name] = this.value || '';
		}
	});
	return o;
};

$.fn.outerHtml = function(){
	return $('<div />').append(this.clone(true)).html();
}