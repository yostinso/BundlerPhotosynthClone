/**
  * class UploadTracker
  *
  * UploadTracker is a JavaScript library for creating an interface
  * supporting the upload of multiple files using AJAX/IFRAMEs. In addition to
  * providing a standard "please wait while uploading" interface, it allows the
  * user to queue up multiple uploads while previous uploads are ongoing,
  * speeding up the process of (for instance) uploading several images.
  * 
  *    ...
  *    <script type="text/javascript">
  *      Event.observe(window, "load", function() {
  *        var image_base = "/images/ticker/ticker"; // + ".png", "_mask.png", "_f[1-12].png";
  *        var dt = new UploadTracker($$("form#upload").first(), $$("div#widgets").first(), image_base);
  *      });
  *    </script>
  *    
  *    <form action="upload.cgi" enctype="multipart/form-data" target="upload_frame" id="upload">
  *      <input type="file"/> <input type="submit"/>
  *    </form>
  *    <div id="widgets" class="ticker" style="display: none"></div>
  *    <iframe id="upload_frame" name="upload_frame" src="#"></iframe>
  *    ...
  **/
var UploadTracker = Class.create({
  /**
    * new UploadTracker(first_form[, container = "first_form.insert({ after: new Element("div") })"][, ticker_base = "images/ticker/ticker"])
    * - first_form (Form): the Form element that will be used for the first upload (and copied for each additional upload)
    * - container (Element): a container element (preferable a DIV of height 100px) that will hold the progress info. Can be initially display:none.
    * - ticker_base (String): the URL prefix to the ticker images: *ticker_base + (".png" | "_mask.png" | "_f[1-12].png")*
    *
    * Creating a UploadTracker is all that's necessary in your applications
    * JavaScript, assuming you've created the form, iframe, and a DIV to hold
    * widgets.
    *
    * Although default images are provided, if you want to use your own (and
    * your own naming scheme), you can leave ticker_base empty and instead set
    * the following variables after initializes the UploadTracker:
    *    var dt = new UploadTracker(form, widgets, "");
    *    dt.TICKER_START  = "queued_image.png";
    *    dt.TICKER_END    = "final_mask_image.png";
    *    dt.TICKER_IMAGES = [ "1.png", "2.png", "3.png" ];
    *
    * You can also change the animation speed:
    *    dt.TICKER_SPEED  = 0.10; // 1/10th second
    **/
  initialize: function(first_form, container, ticker_base) {
    first_form.observe('submit', this.queueUploading.bind(this));
    if (!container) {
      container = new Element("div");
      first_form.insert({ after: container });
    }
    if (!ticker_base) { ticker_base = "images/ticker/ticker"; }

    this.forms = new UploadTracker.FormWidgets(this, container);
    this.running = false;
    this.callbacks = new Hash();

    this.TICKER_SPEED = 0.10;
    this.TICKER_START = ticker_base + ".png";
    this.TICKER_END = ticker_base + "_mask.png";
    this.TICKER_IMAGES = []; for (i = 1; i <= 12; i++) { this.TICKER_IMAGES.push(ticker_base + "_f" + (i<10 ? ("0"+i) : i) + ".png"); }
  },
  /**
    * UploadTracker#size() -> Integer
    *
    * Return the total number of uploads being handled by this class (queued,
    * uploading, and uploaded).
    */
  size: function() {
    return this.forms.size();
  },
  /**
    * UploadTracker#queued() -> Integer
    *
    * Return the total number of uploads still queued for upload. If this is 0,
    * all uploads are complete.
    */
  queued: function() {
    return this.forms.queued();
  },
  /**
    * UploadTracker#uploaded() -> Integer
    *
    * Return the total number of uploads completed.
    */
  uploaded: function() {
    return this.size() - this.queued();
  },
  /**
    * UploadTracker#observe(event_name, callback) -> undefined
    * - event_name (String): the name of the event to observed
    * - callback (Function): the function to call when the event fires
    *
    * Register a callback function for one of the custom event types. Note that
    * these are not PrototypeJS events, but rather a custom listener/receiver.
    *
    * + __upload__ - Fires on [[UploadTracker#finishUpload]]
    * + __uploading__ - Fires on [[UploadTracker#startUploading]]
    * + __finished__ - Fires on [[UploadTracker#startUploading]] when no uploads remain
    * + __queued__ - Fires on [[UploadTracker#queueUploading]]
    **/
  observe: function(event_name, callback) {
    if (!this.callbacks.get(event_name)) {
      this.callbacks.set(event_name, []);
    }
    this.callbacks.get(event_name).push(callback);
  },
  /**
    * UploadTracker#stopObserving(event_name[, callback]) -> Array
    * - event_name (String): the name of the event being observed
    * - event_name (String): the (optional) function to be removed as a callback for the event
    *
    * Remove a callback function for one of the custom event types. Note that
    * these are not PrototypeJS events, but rather a custom listener/receiver.
    * If *callback* is not specified, then all listeners for that event are
    * removed.
    *
    * Returns an array of any callbacks removed.
    **/
  stopObserving: function(event_name, callback) {
    if (this.callbacks.get(event_name)) {
      if (callback) {
        var callbacks = this.callbacks.get(event_name).findAll(function(cbk) { return cbk == callback });
        this.callbacks.set(event_name, this.callbacks.get(event_name).without(callbacks));
        return [ callbacks ];
      } else {
        var callbacks = this.callbacks.get(event_name);
        this.callbacks.set(event_name, []);
        return callbacks;
      }
    }
    return [];
  },
  /** private
    * UploadTracker#fire(event_name, evt) -> Array
    * - event_name (String): the event being fired
    * - evt (Hash): additional details about the event
    *
    * Call any callbacks for the event named *event_name* and pass them the [[UploadTracker.Event]] object.
    **/
  fire: function(event_name, evt) {
    var callbacks = this.callbacks.get(event_name);
    if (callbacks) {
      callbacks.each(function(callback) { callback(evt); });
    }
  },
  finishUpload: function(identity, success, response) {
    this.running = false;
    this.fire('upload', new UploadTracker.Event('upload', { 'success': success, 'identity': identity, 'response': response }));
    this.startUploading(); // Call the next upload
  },
  startUploading: function() {
    if (this.running) { return; }
    // There is a teensy race condition here that I am too lazy to fix right now
    var to_upload = this.forms.nextInQueue();
    if (to_upload) {
      this.running = true;
      to_upload.stopObserving('submit');
      to_upload.finishUpload = this.finishUpload.bind(this);
      var su_bind = this.forms.showUploading.bind(this.forms);
      su_bind(to_upload);
      to_upload.submit();
      this.fire('uploading', new UploadTracker.Event('uploading', { 'form': a_form }));
    } else {
      this.fire('emptied', new UploadTracker.Event('finished', { 'uploaded': this.forms.size() }));
    }
  },
  queueUploading: function(evt) {
    evt.stop();
    var a_form = evt.findElement("form");
    var duplicate = a_form.outerHTML || new XMLSerializer().serializeToString(a_form);
    a_form.insert(new Element("input", { "name": "identity", "type": "hidden", "value": a_form.identify() }));
    a_form.insert({ after: duplicate });
    a_form.hide();
    a_form.next('form').observe('submit', this.queueUploading.bind(this));
    this.forms.push(a_form);
    this.fire('queued', new UploadTracker.Event('queued', { 'queued': this.forms.queued(), 'form': a_form }));
    this.startUploading();
  }
});
UploadTracker.Event = Class.create(Hash, {
  initialize: function($super, event_name, extras) {
    $super();
    this.name = event_name;
    this.update(extras)
  }
});
UploadTracker.FormWidgets = Class.create({
  initialize: function(owner, container) {
    this.owner = owner;
    this.container = container;
    this.forms = []; // [ a_form, a_widget, bool_done ]
  },
  showUploading: function(a_form) {
    var val = a_form.getInputs('text', 'name').first().getValue();
    var activeForm = this.forms.find(function(frm) { return frm[0] == a_form });
    activeForm[2] = 1;
    activeForm[1].startAnimation();
    var oldFinishUpload = activeForm[0].finishUpload;
    activeForm[0].finishUpload = function(identity, success, response) {
      var frm = $(identity);
      if (frm) { this.showUploaded(frm); }
      oldFinishUpload(identity, success, response);
    }.bind(this);
  },
  showUploaded: function(a_form) {
    var activeForm = this.forms.find(function(frm) { return frm[0] == a_form });
    activeForm[1].finishAnimation("/dwp/images/rails.png");
    activeForm[2] = 2;
  },
  nextInQueue: function() {
    var frm = this.forms.find(function(frm) { return frm[2] == 0; });
    if (frm) { return frm[0]; } else { return frm; }
  },
  queued: function() {
    return this.forms.findAll(function(frm) { return frm[2] == 0; }).size();
  },
  push: function(a_form) {
    var new_widget = new UploadTracker.FormWidgets.Ticker(this.owner.TICKER_START, this.owner.TICKER_IMAGES, this.owner.TICKER_END, this.owner.TICKER_SPEED);
    this.container.show();
    this.container.insert({ bottom: new_widget.element() });
    return this.forms.push([ a_form, new_widget, false ]);
  },
  size: function() {
    return this.forms.size();
  }
});
UploadTracker.FormWidgets.Ticker = Class.create({
  initialize: function(start_image, images, end_image, speed) {
    this.img_element = new Element('img', { 'src': start_image, 'class': 'ticker' });
    this.img_element.setStyle({ 'width': '100px', 'height': '100px' });
    this.speed = speed || 0.10;
    this.images = images.map(function(src) {
      var img = new Element('img', { 'src': src, 'class': 'ticker' });
      img.setStyle({ 'position': 'absolute' });
      img.hide();
      return img;
    });


    var finish_mask_img = new Element('img', { 'src': end_image, 'class': 'ticker' });
    this.uploaded_div = new Element('div', { 'class': 'ticker' });
    this.uploaded_div.insert(finish_mask_img);
    this.uploaded_div.hide();

    this.span_element = new Element('span', { 'class': 'ticker' });
    this.span_element.insert(this.img_element);
  },
  element: function() {
    return this.span_element;
  },
  startAnimation: function() {
    var position = this.img_element.cumulativeOffset();
    this.images.each(function(img) { 
      this.span_element.insert(img);
      img.setStyle({ 'left': position[0]+'px' });
    }, this);
    this.span_element.insert(this.uploaded_div); this.uploaded_div.setStyle({ 'left': position[0]+'px', 'top': position[1]+'px' });
    var img_size = this.img_element.getDimensions();
    this.uploaded_div.setStyle({ 'float': 'left', 'width':img_size.width+'px','height':img_size.height+'px' });
    this.timer = new PeriodicalExecuter(this.updateAnimation.bind(this), this.speed);
  },
  updateAnimation: function() {
    if (!this.timer.increment) { this.timer.increment = 0; }
    var this_image = this.timer.increment % this.images.size();
    var prev_image = this_image == 0 ? this.images.size()-1 : this_image-1;
    this.images[this_image].show();
    this.images[prev_image].hide();
    if (this.timer.increment > 2000) { this.timer.stop(); }
    this.timer.increment++;
  },
  stopAnimation: function() {
    if (this.timer) { this.timer.stop(); this.timer = undefined; }
  },
  finishAnimation: function(uploaded_image) {
    this.uploaded_div.setStyle({ 'background':'url('+ uploaded_image +') no-repeat center center', 'backgroundSize': 'auto 100%' });

    this.stopAnimation();
    this.img_element.remove();
    this.images.each(function(img) { img.remove(); });
    this.uploaded_div.show();
  }
});

