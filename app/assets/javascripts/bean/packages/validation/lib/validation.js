var Validation = (function($){
    "use strict";
    return {
        validate: function(element){
            // If element is passed, use that, otherwise assume that the value of "this"
            // is the element, e.g. - Validation.validate.call(element)
            element = element && !element.target ? $(element) : $(this);

            var match,
                result,
                message,
                errors = [],
                regexp = /\{\{([a-z0-9_]+)\}\}/gi,
                classes = Bean.Abstract.unique(element.get(0).className.split(/\s+/));

            $.each(classes, function(index, klass){
                if($.isArray(Validation.rules[klass])){
                    result = Validation.rules[klass][0](element.val(), element.get(0), element.data());
                    if(!result){
                        message = (typeof Validation.rules[klass][1] == 'function' ? Validation.rules[klass][1](element.data()) : Validation.rules[klass][1]) || 'Invalid';

                        message = message.replace(/{{([^}]*)}}/g, function(match, sub){
                            return element.data($.camelCase(sub));
                        });

                        errors.push(message);

                        // If set to progressively validate (show one error at most at a time), break out
                        if(Bean.Config.get('validate_style', 'global') == 'progressive') return false;
                    }
                }
            });

            if(errors.length){
                element.addClass('has-error');

                var actionElement = element.next('.chosen-container').length ? element.next('.chosen-container') : element;

                if(!actionElement.next('.input-errors').length){
                    actionElement.after('<div class="input-errors"></div>');
                    actionElement.next('.input-errors').hide();
                }

                var inputErrors = actionElement.next('.input-errors');

                var errorLines = $.map(errors, function(error){
                    return $('<p class="error-line">' + error + '</p>')
                });

                inputErrors.html('').append(errorLines);

                if(!inputErrors.is(':visible')) inputErrors.slideDown(300);

                element.one('focus pseudo:focus', function(){
                    actionElement.removeClass('has-error');
                    inputErrors.slideUp(300, function(){
                        $(this).remove();
                    });
                });
            }

            return errors.length == 0;
        },

        rules: {
            "validate-max-words": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    if(isNaN(data.max)){
                        return false;
                    }

                    return Bean.Abstract.stripHtml(value).match(/\b\w+\b/g).length <= data.max;
                },
                'Please enter {{max}} words or less.'
            ],
            "validate-min-words": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    if(isNaN(data.max)){
                        return false;
                    }

                    return Bean.Abstract.stripHtml(value).match(/\b\w+\b/g).length >= data.min;
                },
                'Please enter at least {{min}} words.'
            ],
            "validate-range-words": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    if(isNaN(data.min) || isNaN(data.max)){
                        return false;
                    }

                    return Bean.Abstract.stripHtml(value).match(/\b\w+\b/g).length >= data.min && value.match(/bw+b/g).length <= data.max;
                },
                'Please enter between {{min}} and {{max}} words.'
            ],
            "validate-letters-with-basic-punc": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    return /^[a-z\-.,()'\"\s]+$/i.test(value);
                },
                'Letters or punctuation only please'
            ],
            "validate-alphanumeric": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    return /^\w+$/i.test(value);
                },
                'Letters, numbers, spaces or underscores only please'
            ],
            "validate-letters-only": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    return /^[a-z]+$/i.test(value);
                },
                'Letters only please'
            ],
            "validate-no-whitespace": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    return /^\S+$/i.test(value);
                },
                'No white space please'
            ],
            "validate-zip-range": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    return /^90[2-5]-\d{2}-\d{4}$/.test(value);
                },
                'Your ZIP-code must be in the range 902xx-xxxx to 905-xx-xxxx'
            ],
            "validate-integer": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    return /^-?\d+$/.test(value);
                },
                'A positive or negative non-decimal number please'
            ],
            "validate-vin-us": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    if (value.length !== 17) {
                        return false;
                    }
                    var i, n, d, f, cd, cdv;
                    var LL = ["A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
                    var VL = [1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 7, 9, 2, 3, 4, 5, 6, 7, 8, 9];
                    var FL = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2];
                    var rs = 0;
                    for (i = 0; i < 17; i++) {
                        f = FL[i];
                        d = value.slice(i, i + 1);
                        if (i === 8) {
                            cdv = d;
                        }
                        if (!isNaN(d)) {
                            d *= f;
                        } else {
                            for (n = 0; n < LL.length; n++) {
                                if (d.toUpperCase() === LL[n]) {
                                    d = VL[n];
                                    d *= f;
                                    if (isNaN(cdv) && n === 8) {
                                        cdv = LL[n];
                                    }
                                    break;
                                }
                            }
                        }
                        rs += d;
                    }
                    cd = rs % 11;
                    if (cd === 10) {
                        cd = "X";
                    }
                    if (cd === cdv) {
                        return true;
                    }
                    return false;
                },
                'The specified vehicle identification number (VIN) is invalid.'
            ],
            "validate-date-ita": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    var check = false;
                    var re = /^\d{1,2}\/\d{1,2}\/\d{4}$/;
                    if (re.test(value)) {
                        var adata = value.split('/');
                        var gg = parseInt(adata[0], 10);
                        var mm = parseInt(adata[1], 10);
                        var aaaa = parseInt(adata[2], 10);
                        var xdata = new Date(aaaa, mm - 1, gg);
                        if ((xdata.getFullYear() === aaaa) &&
                            (xdata.getMonth() === mm - 1) && (xdata.getDate() === gg )) {
                            check = true;
                        } else {
                            check = false;
                        }
                    } else {
                        check = false;
                    }
                    return check;
                },
                'Please enter a correct date'
            ],
            "validate-time": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    return /^([01]\d|2[0-3])(:[0-5]\d){0,2}$/.test(value);
                },
                'Please enter a valid time, between 00:00 and 23:59'
            ],
            "validate-time-12h": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    return /^((0?[1-9]|1[012])(:[0-5]\d){0,2}(\ [AP]M))$/i.test(value);
                },
                'Please enter a valid time, between 00:00 am and 12:00 pm'
            ],
            "validate-phone-us": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    value = value.replace(/\s+/g, "");
                    return value.length > 9 && value.match(/^(1-?)?(\([2-9]\d{2}\)|[2-9]\d{2})-?[2-9]\d{2}-?\d{4}$/);
                },
                'Please specify a valid phone number'
            ],
            "validate-phone-uk": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    return value.length > 9 && value.match(/^(\(?(0|\+44)[1-9]{1}\d{1,4}?\)?\s?\d{3,4}\s?\d{3,4})$/);
                },
                'Please specify a valid phone number'
            ],
            "validate-mobile-uk": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    return value.length > 9 && value.match(/^((0|\+44)7(5|6|7|8|9){1}\d{2}\s?\d{6})$/);
                },
                'Please specify a valid mobile number'
            ],
            "validate-stripped-min-length": [
                function(value, element, data){
                    if(isNaN(data.min)){
                        return false;
                    }

                    return $(value).text().length >= data.min;
                },
                'Please enter at least {{min}} characters'
            ],
            "validate-email2": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    return /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)*(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i.test(value);
                },
                'Please enter a valid email'
            ],
            "validate-url2": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    return /^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)*(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(value);
                },
                'Please enter a valid URL'
            ],
            "validate-credit-card-types": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    if(/[^0-9-]+/.test(value)){
                        return false;
                    }

                    value = value.replace(/\D/g, "");

                    var types = (data.type || 'unknown').split(/\s+/);
                    var validTypes = 0x0000;

                    if($.inArray('mastercard', types) !== false){
                        validTypes |= 0x0001;
                    }
                    if($.inArray('visa', types) !== false){
                        validTypes |= 0x0002;
                    }
                    if($.inArray('amex', types) !== false){
                        validTypes |= 0x0004;
                    }
                    if($.inArray('dinersclub', types) !== false){
                        validTypes |= 0x0008;
                    }
                    if($.inArray('enroute', types) !== false){
                        validTypes |= 0x0010;
                    }
                    if($.inArray('discover', types) !== false){
                        validTypes |= 0x0020;
                    }
                    if($.inArray('jcb', types) !== false){
                        validTypes |= 0x0040;
                    }
                    if($.inArray('unknown', types) !== false){
                        validTypes |= 0x0080;
                    }
                    if($.inArray('all', types) !== false){
                        validTypes = 0x0001 | 0x0002 | 0x0004 | 0x0008 | 0x0010 | 0x0020 | 0x0040 | 0x0080;
                    }

                    if(validTypes & 0x0001) { //mastercard
                        return value.length === 16 && /^(51|52|53|54|55)/.test(value);
                    }
                    if(validTypes & 0x0002) { //visa
                        return value.length === 16 && /^(4)/.test(value);
                    }
                    if(validTypes & 0x0004) { //amex
                        return value.length === 15 && /^(34|37)/.test(value);
                    }
                    if(validTypes & 0x0008) { //dinersclub
                        return value.length === 14 && /^(300|301|302|303|304|305|36|38)/.test(value);
                    }
                    if(validTypes & 0x0010) { //enroute
                        return value.length === 15 && /^(2014|2149)/.test(value);
                    }
                    if(validTypes & 0x0020) { //discover
                        return value.length === 16 && /^(6011)/.test(value);
                    }
                    if(validTypes & 0x0040) { //jcb
                        return value.length === 16 && /^(3)/.test(value);
                    }
                    if(validTypes & 0x0040) { //jcb
                        return value.length === 15 && /^(2131|1800)/.test(value);
                    }
                    if(validTypes & 0x0080) { //unknown
                        return true;
                    }
                    return false;
                },
                'Please enter a valid credit card number.'
            ],
            "validate-ipv4": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    return /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/i.test(value);
                },
                'Please enter a valid IP v4 address.'
            ],
            "validate-ipv6": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    return /^((([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}:[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){5}:([0-9A-Fa-f]{1,4}:)?[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){4}:([0-9A-Fa-f]{1,4}:){0,2}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){3}:([0-9A-Fa-f]{1,4}:){0,3}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){2}:([0-9A-Fa-f]{1,4}:){0,4}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|(([0-9A-Fa-f]{1,4}:){0,5}:((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|(::([0-9A-Fa-f]{1,4}:){0,5}((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|([0-9A-Fa-f]{1,4}::([0-9A-Fa-f]{1,4}:){0,5}[0-9A-Fa-f]{1,4})|(::([0-9A-Fa-f]{1,4}:){0,6}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){1,7}:))$/i.test(value);
                },
                'Please enter a valid IP v6 address.'
            ],
            "validate-pattern": [
                function(value, element, data){
                    if(Bean.Abstract.isEmptyNoTrim(value)){
                        return true;
                    }

                    if(!data.pattern){
                        return false;
                    }

                    var pattern = $.trim(data.pattern).replace(/^\//, '').replace(/\/[gim]+$/, '');
                    var modifiers = $.trim(data.pattern).substr(data.pattern.lastIndexOf('/') + 1);
                    var regex = new RegExp(pattern, modifiers);

                    return regex.test(value);
                },
                'Invalid format.'
            ],
            "validate-no-html-tags": [
                function(value, element, data){
                    return !/<(\/)?\w+/.test(value);
                },
                'HTML tags are not allowed.'
            ],
            "validate-select": [
                function(value, element, data){
                    return ((value !== "none") && (value != null) && (value.length !== 0));
                },
                'Please select an option.'
            ],
            "validate-not-empty": [
                function(value, element, data){
                    return !Bean.Abstract.isEmpty(value);
                },
                'Empty Value.'
            ],
            "validate-alphanum-with-spaces": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /^[a-zA-Z0-9 ]+$/.test(value);
                },
                'Please use only letters (a-z or A-Z), numbers (0-9) or spaces only in this field.'
            ],
            "validate-data": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /^[A-Za-z]+[A-Za-z0-9_]+$/.test(value);
                },
                'Please use only letters (a-z or A-Z), numbers (0-9) or underscore (_) in this field, and the first character should be a letter.'
            ],
            "validate-street": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /^[ \w]{3,}([A-Za-z]\.)?([ \w]*\#\d+)?(\r\n| )[ \w]{3,}/.test(value);
                },
                'Please use only letters (a-z or A-Z), numbers (0-9), spaces and "#" in this field.'
            ],
            "validate-phone-strict": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /^(\()?\d{3}(\))?(-|\s)?\d{3}(-|\s)\d{4}$/.test(value);
                },
                'Please enter a valid phone number. For example (123) 456-7890 or 123-456-7890.'
            ],
            "validate-phone-lax": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /^((\d[\-. ]?)?((\(\d{3}\))|\d{3}))?[\-. ]?\d{3}[\-. ]?\d{4}$/.test(value);
                },
                'Please enter a valid phone number. For example (123) 456-7890 or 123-456-7890.'
            ],
            "validate-fax": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /^(\()?\d{3}(\))?(-|\s)?\d{3}(-|\s)\d{4}$/.test(value);
                },
                'Please enter a valid fax number (Ex: 123-456-7890).'
            ],
            "validate-email": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /^([a-z0-9,!\#\$%&'\*\+\/=\?\^_`\{\|\}~-]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z0-9,!\#\$%&'\*\+\/=\?\^_`\{\|\}~-]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*@([a-z0-9-]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z0-9-]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*\.(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]){2,})$/i.test(value);
                },
                'Please enter a valid email address (Ex: johndoe@domain.com).'
            ],
            "validate-email-sender": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /^[\S ]+$/.test(value);
                },
                'Please enter a valid email address (Ex: johndoe@domain.com).'
            ],
            "validate-password": [
                function(value, element, data){
                    if (v == null) {
                        return false;
                    }
                    var pass = $.trim(value);
                    if (!pass.length) {
                        return true;
                    }
                    return !(pass.length > 0 && pass.length < 6);
                },
                'Please enter 6 or more characters. Leading and trailing spaces will be ignored.'
            ],
            "validate-admin-password": [
                function(value, element, data){
                    if (v == null) {
                        return false;
                    }
                    var pass = $.trim(value);
                    /*strip leading and trailing spaces*/
                    if (0 === pass.length) {
                        return true;
                    }
                    if (!(/[a-z]/i.test(value)) || !(/[0-9]/.test(value))) {
                        return false;
                    }
                    if (pass.length < 7) {
                        return false;
                    }
                    return true;
                },
                'Please enter 7 or more characters, using both numeric and alphabetic.'
            ],
            "validate-customer-password": [
                function(value, element, data){
                    var validator = this,
                        length = 0,
                        counter = 0;
                    var passwordMinLength = $(elm).data('password-min-length');
                    var passwordMinCharacterSets = $(elm).data('password-min-character-sets');
                    var pass = $.trim(value);
                    var result = pass.length >= passwordMinLength;
                    if (result == false) {
                        validator.passwordErrorMessage = (
                            "Minimum length of this field must be equal or greater than %1 symbols." +
                            " Leading and trailing spaces will be ignored."
                        ).replace('%1', passwordMinLength);
                        return result;
                    }
                    if (pass.match(/\d+/)) {
                        counter ++;
                    }
                    if (pass.match(/[a-z]+/)) {
                        counter ++;
                    }
                    if (pass.match(/[A-Z]+/)) {
                        counter ++;
                    }
                    if (pass.match(/[^a-zA-Z0-9]+/)) {
                        counter ++;
                    }
                    if (counter < passwordMinCharacterSets) {
                        result = false;
                        validator.passwordErrorMessage = (
                            "Minimum of different classes of characters in password is %1." +
                            " Classes of characters: Lower Case, Upper Case, Digits, Special Characters."
                        ).replace('%1', passwordMinCharacterSets);
                    }
                    return result;
                }, function () {
                    return this.passwordErrorMessage;
                }
            ],
            "validate-url": [
                function(value, element, data){
                    if (Bean.Abstract.isEmptyNoTrim(value)) {
                        return true;
                    }
                    v = (v || '').replace(/^\s+/, '').replace(/\s+$/, '');
                    return (/^(http|https|ftp):\/\/(([A-Z0-9]([A-Z0-9_-]*[A-Z0-9]|))(\.[A-Z0-9]([A-Z0-9_-]*[A-Z0-9]|))*)(:(\d+))?(\/[A-Z0-9~](([A-Z0-9_~-]|\.)*[A-Z0-9~]|))*\/?(.*)?$/i).test(value);

                },
                'Please enter a valid URL. Protocol is required (http://, https:// or ftp://).'
            ],
            "validate-clean-url": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /^(http|https|ftp):\/\/(([A-Z0-9][A-Z0-9_-]*)(\.[A-Z0-9][A-Z0-9_-]*)+.(com|org|net|dk|at|us|tv|info|uk|co.uk|biz|se)$)(:(\d+))?\/?/i.test(value) || /^(www)((\.[A-Z0-9][A-Z0-9_-]*)+.(com|org|net|dk|at|us|tv|info|uk|co.uk|biz|se)$)(:(\d+))?\/?/i.test(value);
                },
                'Please enter a valid URL. For example http://www.example.com or www.example.com.'
            ],
            "validate-xml-identifier": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /^[A-Z][A-Z0-9_\/-]*$/i.test(value);
                },
                'Please enter a valid XML-identifier (Ex: something_1, block5, id-4).'
            ],
            "validate-ssn": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /^\d{3}-?\d{2}-?\d{4}$/.test(value);

                },
                'Please enter a valid social security number (Ex: 123-45-6789).'
            ],
            "validate-zip-us": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /(^\d{5}$)|(^\d{5}-\d{4}$)/.test(value);

                },
                'Please enter a valid zip code (Ex: 90602 or 90602-1234).'
            ],
            "validate-date-au": [
                function(value, element, data){
                    if (Bean.Abstract.isEmptyNoTrim(value)) {
                        return true;
                    }
                    var regex = /^(\d{2})\/(\d{2})\/(\d{4})$/;
                    if (Bean.Abstract.isEmpty(value) || !regex.test(value)) {
                        return false;
                    }
                    var d = new Date(value.replace(regex, '$2/$1/$3'));
                    return parseInt(RegExp.$2, 10) === (1 + d.getMonth()) &&
                        parseInt(RegExp.$1, 10) === d.getDate() &&
                        parseInt(RegExp.$3, 10) === d.getFullYear();

                },
                'Please use this date format: dd/mm/yyyy. For example 17/03/2006 for the 17th of March, 2006.'
            ],
            "validate-currency-dollar": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /^\$?\-?([1-9]{1}[0-9]{0,2}(\,[0-9]{3})*(\.[0-9]{0,2})?|[1-9]{1}\d*(\.[0-9]{0,2})?|0(\.[0-9]{0,2})?|(\.[0-9]{1,2})?)$/.test(value);
                },
                'Please enter a valid $ amount. For example $100.00.'
            ],
            "validate-not-negative-number": [
                function(value, element, data){
                    if (Bean.Abstract.isEmptyNoTrim(value)) {
                        return true;
                    }
                    v = Bean.Abstract.parseNumber(value);
                    return !isNaN(value) && v >= 0;
                },
                'Please enter a number 0 or greater in this field.'
            ],
            // validate-not-negative-number should be replaced in all places with this one and then removed
            "validate-zero-or-greater": [
                function(value, element, data){
                    if (Bean.Abstract.isEmptyNoTrim(value)) {
                        return true;
                    }
                    v = Bean.Abstract.parseNumber(value);
                    return !isNaN(value) && v >= 0;
                },
                'Please enter a number 0 or greater in this field.'
            ],
            "validate-greater-than-zero": [
                function(value, element, data){
                    if (Bean.Abstract.isEmptyNoTrim(value)) {
                        return true;
                    }
                    v = Bean.Abstract.parseNumber(value);
                    return !isNaN(value) && v > 0;
                },
                'Please enter a number greater than 0 in this field.'
            ],
            "validate-css-length": [
                function(value, element, data){
                    if (Bean.Abstract.isEmptyNoTrim(value)) {
                        return true;
                    }

                    if (v !== '') {
                        return (/^[0-9]*\.*[0-9]+(px|pc|pt|ex|em|mm|cm|in|%)?$/).test(value);
                    }
                    return true;
                },
                'Please input a valid CSS-length (Ex: 100px, 77pt, 20em, .5ex or 50%).'
            ],
            "validate-number": [
                function(value, element, data){
                    if (Bean.Abstract.isEmptyNoTrim(value)) {
                        return true;
                    }

                    return !isNaN(Bean.Abstract.parseNumber(value)) && /^\s*-?\d*(\.\d*)?\s*$/.test(value);
                },
                'Please enter a valid number in this field.'
            ],
            "required-number": [
                function(value, element, data){
                    return !!value.length;
                },
                'Please enter a valid number in this field.'
            ],
            "validate-number-range": [
                function(value, element, data){
                    if (Bean.Abstract.isEmptyNoTrim(value)) {
                        return true;
                    }

                    var numValue = Bean.Abstract.parseNumber(value);

                    if(isNaN(numValue) || isNaN(data.min) || isNaN(data.max)){
                        return false;
                    }

                    return Bean.Abstract.isBetween(numValue, data.min, data.max);
                },
                'The value is not within the specified range. ({{min}} - {{max}})'
            ],
            "validate-digits": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || !/[^\d]/.test(value);
                },
                'Please enter a valid number in this field.'
            ],
            "validate-digits-range": [
                function(value, element, data){
                    if (Bean.Abstract.isEmptyNoTrim(value)) {
                        return true;
                    }

                    var numValue = Bean.Abstract.parseNumber(value);
                    if (isNaN(numValue)) {
                        return false;
                    }

                    var dataAttrRange = /^(-?\d+)?-(-?\d+)?$/,
                        classNameRange = /^digits-range-(-?\d+)?-(-?\d+)?$/,
                        result = true,
                        range, m, classes, ii;
                    range = param;

                    if (typeof range === 'object') {
                        m = dataAttrRange.exec(range);
                        if (m) {
                            result = result && Bean.Abstract.isBetween(numValue, m[1], m[2]);
                        }
                    } else if (elm && elm.className) {
                        classes = elm.className.split(" ");
                        ii = classes.length;

                        while (ii--) {
                            range = classes[ii];
                            m = classNameRange.exec(range);
                            if (m) {
                                result = result && Bean.Abstract.isBetween(numValue, m[1], m[2]);
                                break;
                            }
                        }
                    }
                    return result;
                },
                'The value is not within the specified range.',
                true
            ],
            'validate-range': [
                function(value, element, data){
                    if (Bean.Abstract.isEmptyNoTrim(value)) {
                        return true;
                    }

                    if(isNaN(data.min) || isNaN(data.max)){
                        return false;
                    }

                    return Bean.Abstract.parseNumber(value) >= Bean.Abstract.parseNumber(data.min) && Bean.Abstract.parseNumber(value) <= Bean.Abstract.parseNumber(data.max)
                },
                'Please enter a value between {{min}} and {{max}}'
            ],
            "validate-alpha": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /^[a-zA-Z]+$/.test(value);
                },
                'Please use letters only (a-z or A-Z) in this field.'
            ],
            "validate-code": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /^[a-z]+[a-z0-9_]+$/.test(value);
                },
                'Please use only letters (a-z), numbers (0-9) or underscore (_) in this field, and the first character should be a letter.'
            ],
            "validate-alphanum": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /^[a-zA-Z0-9]+$/.test(value);
                },
                'Please use only letters (a-z or A-Z) or numbers (0-9) in this field. No spaces or other characters are allowed.'
            ],
            "validate-date": [
                function(value, element, data){
                    var test = new Date(value);
                    return Bean.Abstract.isEmptyNoTrim(value) || !isNaN(test);
                }, 'Please enter a valid date.'
            ],
            "validate-date-range": [
                function(value, element, data){
                    var m = /\bdate-range-(\w+)-(\w+)\b/.exec(elm.className);
                    if (!m || m[2] === 'to' || Bean.Abstract.isEmptyNoTrim(value)) {
                        return true;
                    }

                    var currentYear = new Date().getFullYear() + '';
                    var normalizedTime = function(value, element, data){
                        v = value.split(/[.\/]/);
                        if (v[2] && v[2].length < 4) {
                            v[2] = currentYear.substr(0, v[2].length) + v[2];
                        }
                        return new Date(value.join('/')).getTime();
                    };

                    var dependentElements = $(elm.form).find('.validate-date-range.date-range-' + m[1] + '-to');
                    return !dependentElements.length || Bean.Abstract.isEmptyNoTrim(dependentElements[0].value) ||
                        normalizedTime(value) <= normalizedTime(dependentElements[0].value);
                },
                'Make sure the To Date is later than or the same as the From Date.'
            ],
            "validate-cpassword": [
                function () {
                    var conf = $('#confirmation').length > 0 ? $('#confirmation') : $($('.validate-cpassword')[0]);
                    var pass = false;
                    if ($('#password')) {
                        pass = $('#password');
                    }
                    var passwordElements = $('.validate-password');
                    for (var i = 0; i < passwordElements.length; i++) {
                        var passwordElement = $(passwordElements[i]);
                        if (passwordElement.closest('form').attr('id') === conf.closest('form').attr('id')) {
                            pass = passwordElement;
                        }
                    }
                    if ($('.validate-admin-password').length) {
                        pass = $($('.validate-admin-password')[0]);
                    }
                    return (pass.val() === conf.val());
                },
                'Please make sure your passwords match.'
            ],
            "validate-identifier": [
                function(value, element, data){
                    return Bean.Abstract.isEmptyNoTrim(value) || /^[a-z0-9][a-z0-9_\/-]+(\.[a-z0-9_-]+)?$/.test(value);
                },
                'Please enter a valid URL Key (Ex: "example-page", "example-page.html" or "anotherlevel/example-page").'
            ],
            "validate-zip-international": [
                /*function(value) {
                 // @TODO: Cleanup
                 return Validation.get('IsEmpty').test(value) || /(^[A-z0-9]{2,10}([\s]{0,1}|[\-]{0,1})[A-z0-9]{2,10}$)/.test(value);
                 }*/
                function () {
                    return true;
                },
                'Please enter a valid zip code.'
            ],
            "validate-one-required": [
                function(value, element, data){
                    var p = $(elm).parent();
                    var options = p.find('input');
                    return options.map(function (elm) {
                            return $(elm).val();
                        }).length > 0;
                },
                'Please select one of the options above.'
            ],
            "validate-state": [
                function(value, element, data){
                    return (v !== 0 || v === '');
                },
                'Please select State/Province.'
            ],
            "required-file": [
                function(value, element, data){
                    var result = !Bean.Abstract.isEmptyNoTrim(value);
                    if (!result) {
                        var ovId = $(elm).attr('id') + '_value';
                        if ($(ovId)) {
                            result = !Bean.Abstract.isEmptyNoTrim($(ovId).val());
                        }
                    }
                    return result;
                },
                'Please select a file.'
            ],
            "validate-ajax-error": [
                function (v, element) {
                    element = $(element);
                    element.on('change.ajaxError', function () {
                        element.removeClass('validate-ajax-error');
                        element.off('change.ajaxError');
                    });
                    return !element.hasClass('validate-ajax-error');
                },
                ''
            ],
            "validate-optional-datetime": [
                function (v, elm, param) {
                    var dateTimeParts = $('.datetime-picker[id^="options_' + param + '"]'),
                        hasWithValue = false, hasWithNoValue = false,
                        pattern = /day_part$/i;
                    for (var i = 0; i < dateTimeParts.length; i++) {
                        if (!pattern.test($(dateTimeParts[i]).attr('id'))) {
                            if ($(dateTimeParts[i]).val() === "") {
                                hasWithValue = true;
                            } else {
                                hasWithNoValue = true;
                            }
                        }
                    }
                    return hasWithValue ^ hasWithNoValue;
                },
                'The field isn\'t complete.'
            ],
            "validate-required-datetime": [
                function (v, elm, param) {
                    var dateTimeParts = $('.datetime-picker[id^="options_' + param + '"]');
                    for (var i = 0; i < dateTimeParts.length; i++) {
                        if (dateTimeParts[i].value === "") {
                            return false;
                        }
                    }
                    return true;
                },
                'This is a required field.'
            ],
            "validate-one-required-by-name": [
                function (v, elm, selector) {
                    var name = elm.name.replace(/([\\"])/g, '\\$1'),
                        container = this.currentForm,
                        selector = selector === true ? 'input[name="' + name + '"]:checked' : selector;

                    return !!container.querySelectorAll(selector).length;
                },
                'Please select one of the options.'
            ],
            "validate-less-than-equals-to": [
                function(value, element, data){
                    if($.isNumeric(data.max) && $.isNumeric(value)){
                        return parseFloat(value) <= parseFloat(data.max);
                    }
                    return true;
                },
                'Please enter a value less than or equal to {{max}}.'
            ],
            "validate-greater-than-equals-to": [
                function(value, element, data){
                    if($.isNumeric(data.min) && $.isNumeric(value)){
                        return parseFloat(value) >= parseFloat(data.min);
                    }
                    return true;
                },
                'Please enter a value greater than or equal to {{min}}.'
            ],
            "validate-emails": [
                function(value, element, data){
                    if (Bean.Abstract.isEmpty(value)) {
                        return true;
                    }
                    var valid_regexp = /^[a-z0-9\._-]{1,30}@([a-z0-9_-]{1,30}\.){1,5}[a-z]{2,4}$/i,
                        emails = value.split(/[\s\n\,]+/g);
                    for (var i = 0; i < emails.length; i++) {
                        if (!valid_regexp.test(emails[i].trim())) {
                            return false;
                        }
                    }
                    return true;
                }, "Please enter valid email addresses, separated by commas. For example, johndoe@domain.com, johnsmith@domain.com."
            ],
            "validate-cc-type-select": [
                /**
                 * Validate credit card type matches credit card number
                 * @param value - select credit card type
                 * @param element - element contains the select box for credit card types
                 * @param data - object containing "cc" -- jQuery selector for credit card number field
                 * @return {boolean}
                 */
                function(value, element, data){
                    if(value && data.cc && Bean.Abstract.creditCardTypes[value]){
                        return Bean.Abstract.creditCardTypes[value][0].test($(data.cc).val().replace(/\s+/g, ''));
                    }
                    return false;
                }, 'Card type does not match credit card number.'
            ],
            "validate-cc-number": [
                /**
                 * Validate credit card number based on mod 10
                 * @param value - credit card number
                 * @return {boolean}
                 */
                function(value, element, data){
                    return Bean.Abstract.validateCreditCard(value);
                }, 'Please enter a valid credit card number.'
            ],
            "validate-cc-type": [
                /**
                 * Validate credit card number is for the correct credit card type
                 * @param value - credit card number
                 * @param element - element contains credit card number
                 * @param params - selector for credit card type
                 * @return {boolean}
                 */
                function(value, element, data){
                    if (value && data.cc) {
                        var ccType = $(data.cc).val();
                        value = value.replace(/\s/g, '').replace(/\-/g, '');
                        if (Bean.Abstract.creditCardTypes[ccType] && Bean.Abstract.creditCardTypes[ccType][0]) {
                            return Bean.Abstract.creditCardTypes[ccType][0].test(value);
                        } else if (Bean.Abstract.creditCardTypes[ccType] && !Bean.Abstract.creditCardTypes[ccType][0]) {
                            return true;
                        }
                    }
                    return false;
                }, 'Credit card number does not match credit card type.'
            ],
            "validate-cc-exp": [
                /**
                 * Validate credit card expiration date, make sure it's within the year and not before current month
                 * @param value - month
                 * @param element - element contains month
                 * @param params - year selector
                 * @return {Boolean}
                 */
                function(value, element, data){
                    var isValid = false;
                    if(value && data.year){
                        var month = value,
                            year = $(data.year).val(),
                            currentTime = new Date(),
                            currentMonth = currentTime.getMonth() + 1,
                            currentYear = currentTime.getFullYear();
                        isValid = !year || year > currentYear || (year == currentYear && month >= currentMonth);
                    }
                    return isValid;
                }, 'Incorrect credit card expiration date.'
            ],
            "validate-cc-cvn": [
                /**
                 * Validate credit card cvn based on credit card type
                 * @param value - credit card cvn
                 * @param element - element contains credit card cvn
                 * @param params - credit card type selector
                 * @return {*}
                 */
                function(value, element, data){
                    if (value && data.type) {
                        var ccType = $(data.type).val();
                        if (Bean.Abstract.creditCardTypes[ccType] && Bean.Abstract.creditCardTypes[ccType][0]) {
                            return Bean.Abstract.creditCardTypes[ccType][1].test(value);
                        }
                    }
                    return false;
                }, 'Please enter a valid credit card verification number.'
            ],
            "validate-length": [
                function(value, element, data){
                    if($.isNumeric(data.min) && $.isNumeric(data.max)){
                        return value.length >= parseFloat(data.min) && value.length <= parseFloat(data.max);
                    }else if($.isNumeric(data.min)){
                        return value.length >= parseFloat(data.min);
                    }else if($.isNumeric(data.max)){
                        return value.length <= parseFloat(data.max);
                    }
                }, function(data){
                    if(data.min && data.max){
                        return 'Length of this field must be between {{min}} and {{max}} characters.';
                    }else if(data.min){
                        return 'Length of this field must be greater than {{min}} characters.';
                    }else if(data.max){
                        return 'Length of this field must be less than {{max}} characters.';
                    }
                    return '';
                }
            ],
            'validate-required': [
                function(value, element, data){
                    return !Bean.Abstract.isEmpty(value);
                }, ('This is a required field.')
            ],
            'validate-not-negative-amount': [
                function(value, element, data){
                    if (value.length)
                        return (/^\s*\d+([,.]\d+)*\s*%?\s*$/).test(value);
                    else
                        return true;
                },
                'Please enter positive number in this field.'
            ],
            'validate-per-page-value-list': [
                function(value, element, data){
                    var isValid = !Bean.Abstract.isEmpty(value);
                    var values = value.split(',');
                    for (var i = 0; i < values.length; i++) {
                        if (!/^[0-9]+$/.test(values[i])) {
                            isValid = false;
                        }
                    }
                    return isValid;
                },
                'Please enter a valid value, ex: 10,20,30'
            ],
            'validate-per-page-value': [
                function(value, element, data){
                    if (Bean.Abstract.isEmpty(value)) {
                        return false;
                    }
                    var values = $('#' + elm.id + '_values').val().split(',');
                    return values.indexOf(value) != -1;
                },
                'Please enter a valid value from list'
            ],
            'validate-new-password': [
                function(value, element, data){
                    if ($.validator.methods['validate-password'] && !$.validator.methods['validate-password'](value)) {
                        return false;
                    }
                    if (Bean.Abstract.isEmpty(value) && v !== '') {
                        return false;
                    }
                    return true;
                },
                'Please enter 6 or more characters. Leading and trailing spaces will be ignored.'
            ],
            'required-if-not-specified': [
                function(value, element, data){
                    var valid = false;

                    // if there is an alternate, determine its validity
                    var alternate = $(params);
                    if (alternate.length > 0) {
                        valid = this.check(alternate);
                        // if valid, it may be blank, so check for that
                        if (valid) {
                            var alternateValue = alternate.val();
                            if (typeof alternateValue == 'undefined' || alternateValue.length === 0) {
                                valid = false;
                            }
                        }
                    }

                    if (!valid)
                        valid = !this.optional(element);

                    return valid;
                },
                'This is a required field.'
            ],
            'required-if-all-sku-empty-and-file-not-loaded': [
                function(value, element, data){
                    var valid = false;
                    var alternate = $(params.specifiedId);

                    if (alternate.length > 0) {
                        valid = this.check(alternate);
                        // if valid, it may be blank, so check for that
                        if (valid) {
                            var alternateValue = alternate.val();
                            if (typeof alternateValue == 'undefined' || alternateValue.length === 0) {
                                valid = false;
                            }
                        }
                    }

                    if (!valid)
                        valid = !this.optional(element);

                    $('input[' + params.dataSku + '=true]').each(function () {
                        if ($(this).val() !== '') {
                            valid = true;
                        }
                    });

                    return valid;
                }, 'Please enter valid SKU key.'
            ],
            'required-if-specified': [
                function(value, element, data){
                    var valid = true;

                    // if there is an dependent, determine its validity
                    var dependent = $(params);
                    if (dependent.length > 0) {
                        valid = this.check(dependent);
                        // if valid, it may be blank, so check for that
                        if (valid) {
                            var dependentValue = dependent.val();
                            valid = typeof dependentValue != 'undefined' && dependentValue.length > 0;
                        }
                    }

                    if (valid) {
                        valid = !this.optional(element);
                    } else {
                        valid = true; // dependent was not valid, so don't even check
                    }

                    return valid;
                },
                'This is a required field.'
            ],
            'required-number-if-specified': [
                function(value, element, data){
                    var valid = true,
                        dependent = $(params),
                        depeValue;

                    if (dependent.length) {
                        valid = this.check(dependent);

                        if (valid) {
                            depeValue = dependent[0].value;
                            valid = !!(depeValue && depeValue.length);
                        }
                    }

                    return valid ? !!value.length : true;
                },
                'Please enter a valid number.'
            ],
            'datetime-validation': [
                function(value, element, data){
                    var isValid = true;

                    if ($(element).val().length === 0) {
                        isValid = false;
                        $(element).addClass('mage-error');
                    }

                    return isValid;
                },
                'This is required field'
            ],
            'validate-item-quantity': [
                function(value, element, data){
                    // obtain values for validation
                    var qty = Bean.Abstract.parseNumber(value);

                    // validate quantity
                    var isMinAllowedValid = typeof params.minAllowed === 'undefined' || (qty >= Bean.Abstract.parseNumber(params.minAllowed));
                    var isMaxAllowedValid = typeof params.maxAllowed === 'undefined' || (qty <= Bean.Abstract.parseNumber(params.maxAllowed));
                    var isQtyIncrementsValid = typeof params.qtyIncrements === 'undefined' || (qty % Bean.Abstract.parseNumber(params.qtyIncrements) === 0);

                    return isMaxAllowedValid && isMinAllowedValid && isQtyIncrementsValid && qty > 0;
                },
                ''
            ]
        }
    };
})(jQuery);