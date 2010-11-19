var PhotosetManager = Class.create({});
Object.extend(PhotosetManager, {
    onloadHandler: function(image_helper, delete_img_path, ticker_base, delete_img, processed_img, processing_img, done_imgs) {
        var ut = new UploadTracker($$("form").first(), $$("div#widgets").first(), ticker_base);
        var deleteImage = function(id, element) {
            var aj = new Ajax.Request(delete_img_path + id, {
                onSuccess: function() { element.remove(); },
                onFailure: function() { alert("Failed to remove picture " + id); }
            });
        }
        var deleteImageObserver = new ImageHelper.Observer(
                'click', function(evt, widget) {
                    deleteImage(ut.formForWidget(widget).extra, widget);
                }
                );

        ut.observe('checkForm', function(evt) {
            var file_elem = evt.get("form").getInputs("file").first();
            var filename = file_elem.getValue();
            if (filename.blank()) {
                file_elem.focus();
                evt.stop();
            }
        });
        ut.observe('upload', function(evt) {
            if (evt.get("success")) {
                var widget = ut.widgetForForm(evt.get('form')).down("DIV.ticker.imagebox");
                image_helper.attachControls(widget, delete_img, deleteImageObserver, function(widget) { return widget.up("span.ticker"); } );
                image_helper.attachControls(widget, processing_img, false, function(widget) { return widget.up("span.ticker"); } );
                image_helper.apply();
            } else {
                alert("Failed: " + evt.get("response"));
            }
        });
        // Add widgets for already uploaded ones
        var widgets = [];
        done_imgs.each(function(img_info) {
            var widget = ut.createDoneWidget(img_info.url, img_info.id);
            image_helper.attachControls(widget.down("DIV.ticker.imagebox"), delete_img, deleteImageObserver, function(widget) { return widget.up("span.ticker"); } );
            if (img_info.processing) {
                image_helper.attachControls(widget.down("DIV.ticker.imagebox"), processing_img, false, function(widget) { return widget.up("span.ticker"); } );
            } else {
                image_helper.attachControls(widget.down("DIV.ticker.imagebox"), processed_img, false, function(widget) { return widget.up("span.ticker"); } );
            }
        });

        //image_helper.attachControls("DIV.ticker.imagebox", delete_img, deleteImageObserver, function(widget) { return widget.up("span.ticker"); } );
        image_helper.apply();
    }
});
