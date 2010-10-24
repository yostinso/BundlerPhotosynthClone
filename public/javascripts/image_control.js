var ImageHelper = Class.create({
  initialize: function(offsetLeft, offsetTop) {
    this.control_images = $H();
    this.attachments = [];
    this.applied = false;
    this.offsetLeft = (offsetLeft == undefined) ? ImageHelper.OFFSET_LEFT : offsetLeft;
    this.offsetTop = (offsetTop == undefined) ? ImageHelper.OFFSET_TOP : offsetTop;
  },
  _waitForImage: function(image) {
    if (!this.control_images.get(image)) {
      var iw = new ImageHelper.ImageWaiter(image, this._tryToRun.bind(this));
      this.control_images.set(image, iw);
    }
  },
  _enqueue: function(attachment) {
    this.attachments.push(attachment);
  },
  apply: function() {
    this.applied = true;
    this._tryToRun();
  },
  _tryToRun: function() {
    if (this.applied && this.control_images.values().reject(function(img) { return img.isLoaded() }).size() == 0) {
      this.attachments.each(function(attachment) { attachment(); });
      // Reset so we can add more things later
      this.attachments = [];
      this.applied = false;
    }
  },
  attachControls: function(selector, image, observer, widget_selector) {
    this._waitForImage(image);
    this._enqueue(this._attachControls.bind(this, selector, image, observer, widget_selector));
  },
  _attachControls: function(selector, image, observer, widget_selector) {
    var widgets = selector;
    if (typeof selector == "string") {
      var widgets = $$(selector);
    }

    var cachedImage = this.control_images.get(image);
    widgets.each(function(widget) {
      var img = new Element('img', { 'src': image });
      img.setStyle({ 'width': cachedImage.width() + 'px', 'height': cachedImage.height() + 'px' });
      var dims = widget.getDimensions();
      var pos = widget.positionedOffset();

      var realOffsetLeft = (dims.width * this.offsetLeft) - cachedImage.width();
      var realOffsetTop = dims.height * this.offsetTop - cachedImage.height();
      // Offset by any existing widgets plus spacing
      widget.select(".imageControl").each(function(existing_widget) {
        realOffsetLeft -= ImageHelper.SPACING + existing_widget.getDimensions().width + cachedImage.width();
      });

      var rightOfParent = 0;
      var belowParent = -1*dims.height;
      img.setStyle({
        'position': 'relative',
        'left': (realOffsetLeft+rightOfParent) + "px",
        'top': (realOffsetTop+belowParent) + "px"
      });
      img.addClassName('imageControl');
      widget.insert(img);
      if (widget_selector) { widget = widget_selector(widget); }
      observer.apply(img, widget);
    }, this);
  }
});
Object.extend(ImageHelper, {
  OFFSET_TOP: 0.10,
  OFFSET_LEFT: 0.90,
  SPACING: 1,
  Observer: Class.create({
    initialize: function(event_name, callback) {
      this.event_name = event_name;
      this.callback = callback;
    },
    apply: function(element, widget) {
      element.observe(this.event_name, this.callback.bindAsEventListener(element, widget));
    },
    remove: function(element) {
      element.stopObserving(this.event_name, this.callback);
    }
  }),
  ImageWaiter: Class.create({
    initialize: function(image, callback) {
      this.img = new Element('img');
      this.loaded = false;
      this.callback = callback;
      this.img.observe('load', this.setLoaded.bind(this));
      this.img.src = image;
    },
    setLoaded: function() { 
      this.loaded = true;
      if (this.callback) {
        this.callback();
      }
    },
    isLoaded: function() { return this.loaded; },
    width: function() { return this.img.width; },
    height: function() { return this.img.height; }
  })
});
