/*--------------------------------------*
 * [jQuery] Show thumbnails for any upload files
 *--------------------------------------*/
$.fn.uploadThumbs = function (option) {
	option = $.extend({
		position  : 0,		// 0:before, 1:after, 2:parent.prepend, 3:parent.append,
							// any: arbitrarily jquery selector
		imgbreak  : false,	// append <br> after thumbnail images
		exclusion : true,	// do exclusion image control
		checkbox  : ':checkbox, label, .checked_images',	// selector to find checkbox for exclusion image control
		alternate : '.alt'	// selecter for alternate view input file names
	}, option || {});

	this.change(function () { $.fn.uploadThumbs.run.call(this, option) });

	this.each(function () {
		var $self = $(this);

		// set exclusion event
		$.fn.uploadThumbs.exclusion_event.call($self, option);
	});
	return this;
};

// preview thumbnail images
$.fn.uploadThumbs.run = function (option) {
	var $self = $(this);

	// clear thumbnail images
	$.fn.uploadThumbs.clear.call($self, option);

	// HTML5 ?
	if (window.File && window.FileReader && this.files) {
		var filenames = [];
		for (var i = 0, I = this.files.length; i < I; i++) {
			var file  = this.files[i];
			if (file && (file.type && file.type.match(/^image/)		// image ?
			         || !file.type && file.name.match(/\.(jp[eg]+|png|gif|bmp)$/i) && $.browser.msie)) {
				var reader = new FileReader();
				reader.onload = function (file, i) { return function () {
					var tag = '<img src="'+ this.result +'" alt="'+ file.name +'" title="'+ file.name +' ('+ Math.round( file.size / 1024 ) +'kb)' +'" class="thumb" />';

					// set thumbnail images
					$.fn.uploadThumbs.set.call($self, option, tag);
				}}(file, i);
				reader.readAsDataURL(file);	// read image data

				// add filenames
				filenames.push(file.name);
			}
		}

		// file names
		var alt = (filenames.length) ? filenames.join(', ') : null;

		// exclusion control
		$.fn.uploadThumbs.exclusion.call($self, option, alt);
	}
	// legacy IE
	else {
		var file = this.value;
		if (file && !file.match('fakepath') && file.match(/\.(jp[eg]+|png|gif|bmp)$/i)) {
			var img = new Image();
			img.src = file;
			img.onload = function () {
				var filename = this.src.match(/([^\\\/]+)$/) ? RegExp.$1 : '';
				var tag = '<img src="'+ this.src +'" alt="'+ filename +'" title="'+ this.src +'" class="legacy thumb" />';

				// set thumbnail images
				$.fn.uploadThumbs.set.call($self, option, tag);
			};
			if (img.complete) img.onload();
		}

		// file names
		var alt = (!file) ? null : file.match(/([^\\\/]+)$/) ? RegExp.$1 : file;

		// exclusion control
		$.fn.uploadThumbs.exclusion.call($self, option, alt);
	}
};

// clear thumbnail images
$.fn.uploadThumbs.clear = function (option) {
	// clear file names
	typeof  this.data('alternate').attr('value') == 'undefined' ?
			this.data('alternate').hide().text('') :
			this.data('alternate')       . val('');

	// find images
	var $images = (typeof option.position == 'number')
				?  this.siblings('img.thumb')
				:  $( option.position ).find('img.thumb');

	// remove images
	if ($images.length) {
		$images.not('img.uploaded').next('br').remove()
										.end().remove();
	}
};

// set thumbnail images
$.fn.uploadThumbs.set = function (option, tag) {
	var in_label = this.parent('label').length;
	var tag_br = (option.imgbreak) ? "<br />\n" : "\n";
	var $tag = (option.position == 1 || option.position == 3) ? $(tag_br + tag) :
																$(tag + tag_br);
	// append
	(option.position == 0) ? this.before($tag) :
	(option.position == 1) ? this. after($tag) :
	(option.position == 2) ? this.parent().prepend($tag) :
	(option.position == 3) ? this.parent(). append($tag) :
	                         $(option.position).append($tag).show();

	// as trigger in label ?
	if (in_label) {
		var $self = $(this);
		$tag.click(function (e) {
			$self.click();
			return false;
		});
	}
};

// exclusion control
$.fn.uploadThumbs.exclusion = function (option, filenames) {
	// no exclusion
	typeof  this.data('alternate').attr('value') == 'undefined' ?
			this.data('alternate').show().text( filenames || '' ) :
			this.data('alternate').show(). val( filenames || '' );

	// hide previous image
	if (option.exclusion) {
		if (filenames) {
			this.data('checkbox').attr('checked', false);	// not inherit
			this.siblings('img.uploaded').slideUp();
			this.data('checkbox').siblings('img.uploaded').slideUp();
		} else {
			this.siblings('img.uploaded').slideDown();
			this.data('checkbox').siblings('img.uploaded').slideDown();
		}
	}
};

// set exclusion event
$.fn.uploadThumbs.exclusion_event = function (option) {
	var $self = this;

	// alternate view input file names
	if (!this.data('alternate')) {
		var $alt_filenames = this.siblings( option.alternate );	// is in siblings ?
		if ($alt_filenames.length == 0)		// is in parent siblings ?
			$alt_filenames = this.parent('label').siblings( option.alternate );
		this.data('alternate', $alt_filenames);
		typeof $alt_filenames.attr('value') == 'undefined' ?
				$alt_filenames.hide().text('') : $alt_filenames.val('')
	}

	if (!option.exclusion) return;

	// checkbox for exclusion images ?
	if (!this.data('checkbox')) {
		var $checked_images = this.siblings( option.checkbox );	// is in siblings ?
		if ($checked_images.length == 0)		// is in parent siblings ?
			$checked_images = this.parent('label').siblings( option.checkbox );
		if ($checked_images.find(':checkbox').length)		// is in cousin ?
			$checked_images = $checked_images.find(':checkbox');
		this.data('checkbox', $checked_images);
	}

	// show/hide image with checkbox on/off
	this.data('checkbox').change(function () {
		var $this = $(this);
		if ($this.is(':checked')) {
			// cleanup
			$.fn.uploadThumbs.clear.call($self, option);

			// reset form
			$self.siblings('img.uploaded').slideDown();
			$this.siblings('img.uploaded').slideDown();

			// reset <input:file>
			var $clone = $self.clone();
			$self.replaceWith( $clone );
			$clone.uploadThumbs(option);
		} else {
			$self.siblings('img.uploaded').slideUp();
			$this.siblings('img.uploaded').slideUp();
		}
	});
};

