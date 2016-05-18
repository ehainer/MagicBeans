function isNumeric(value){
	return !isNaN(parseInt(value));
};

function isDecimal(value){
	return !isNaN(parseFloat(value));
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