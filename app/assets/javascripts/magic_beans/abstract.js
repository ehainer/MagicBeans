function isNumeric(value){
	return !isNaN(parseInt(value));
};

function isDecimal(value){
	return !isNaN(parseFloat(value));
};

String.prototype.trim = function(){
	return $.trim(this);
};

String.prototype.blank = function(){
	return this.trim() == '';
};

Boolean.prototype.blank = function(){
	return this === false;
};

Array.prototype.compact = function(){
	for(var i=0; i<this.length; i++){
		if(this[i] == undefined || this[i].toString().replace(/^\s+|\s+$/gm, '') == ''){
			this.splice(i, 1);
		}
	}
	return this;
};

Array.prototype.includes = function(what){
	var re = new RegExp(what);
	for(var i=0; i<this.length; i++){
		if(re.test(this[i])){
			return true;
		}
	}
	return false;
};

Array.prototype.contains = function(what){
	for(var i=0; i<this.length; i++){
		if(this[i] == what){
			return true;
		}
	}
	return false;
};

Array.prototype.each = function(callback){
	for(var i=0; i<this.length; i++){
		callback(this[i], i);
	}
	return this;
};

Array.prototype.flatten = function(){
	var b = Array.prototype.concat.apply([], this);
	if(b.length != this.length){
		b = b.flatten();
	};

	return b;
};

Array.prototype.blank = function(){
	return this.compact().length == 0;
};

Number.prototype.blank = function(){
	return this <= 0;
};