var apexImageSlider = (function () {
    "use strict";
    var scriptVersion = "2.0.1";
    var util = {
        version: "1.2.9",
        isDefinedAndNotNull: function (pInput) {
            if (typeof pInput !== "undefined" && pInput !== null) {
                return true;
            } else {
                return false;
            }
        },
        isAPEX: function () {
            if (typeof (apex) !== 'undefined') {
                return true;
            } else {
                return false;
            }
        },
        debug: {
            info: function (str) {
                if (util.isAPEX()) {
                    apex.debug.info(str);
                }
            },
            error: function (str) {
                if (util.isAPEX()) {
                    apex.debug.error(str);
                } else {
                    console.error(str);
                }
            }
        },
        loader: {
            start: function (id, setMinHeight) {
                if (setMinHeight) {
                    $(id).css("min-height", "100px");
                }
                if (util.isAPEX()) {
                    apex.util.showSpinner($(id));
                } else {
                    /* define loader */
                    var faLoader = $("<span></span>");
                    faLoader.attr("id", "loader" + id);
                    faLoader.addClass("ct-loader");
                    faLoader.css("text-align", "center");
                    faLoader.css("width", "100%");
                    faLoader.css("display", "block");

                    /* define refresh icon with animation */
                    var faRefresh = $("<i></i>");
                    faRefresh.addClass("fa fa-refresh fa-2x fa-anim-spin");
                    faRefresh.css("background", "rgba(121,121,121,0.6)");
                    faRefresh.css("border-radius", "100%");
                    faRefresh.css("padding", "15px");
                    faRefresh.css("color", "white");

                    /* append loader */
                    faLoader.append(faRefresh);
                    $(id).append(faLoader);
                }
            },
            stop: function (id, removeMinHeight) {
                if (removeMinHeight) {
                    $(id).css("min-height", "");
                }
                $(id + " > .u-Processing").remove();
                $(id + " > .ct-loader").remove();
            }
        },
        link: function (link, tabbed) {
            if (tabbed) {
                window.open(link, "_blank");
            } else {
                return window.location = link;
            }
        },
        noDataMessage: {
            show: function (id, text) {
                var div = $("<div></div>")
                    .css("margin", "12px")
                    .css("text-align", "center")
                    .css("padding", "64px 0")
                    .addClass("nodatafoundmessage");

                var subDiv = $("<div></div>");

                var subDivSpan = $("<span></span>")
                    .addClass("fa")
                    .addClass("fa-search")
                    .addClass("fa-2x")
                    .css("height", "32px")
                    .css("width", "32px")
                    .css("color", "#D0D0D0")
                    .css("margin-bottom", "16px");

                subDiv.append(subDivSpan);

                var span = $("<span></span>")
                    .text(text)
                    .css("display", "block")
                    .css("color", "#707070")
                    .css("font-size", "12px");

                div
                    .append(subDiv)
                    .append(span);

                $(id).append(div);
            },
            hide: function (id) {
                $(id).children('.nodatafoundmessage').remove();
            }
        }
    };

    /***********************************************************************
     **
     ** Used to draw the region
     **
     ***********************************************************************/
    function drawSlideRegion(pData, pConfigJSON) {

        util.debug.info({
            "module": "drawSlideRegion",
            "pData": pData,
            "pConfigJSON": pConfigJSON
        });

        if (pData.row && pData.row.length > 0) {
            var itemData = pData.row;
            var htmlIDX = 0;
            var timeOut;

            var htmlDiv = $("<div></div>");
            htmlDiv.addClass("swiper-item-html-container");
            htmlDiv.attr("id", pConfigJSON.regionID + "-sd");
            htmlDiv.css("background-color", pConfigJSON.backgroundColor || "transparen");

            $(pConfigJSON.parentIDSelector).append(htmlDiv);

            function prepareHTMLRender() {
                htmlDiv.find(".swiper-img-container").remove();

                var imgDiv = $("<div></div>");
                imgDiv.addClass("swiper-img-container");
                imgDiv.css("background-size", pConfigJSON.imageSize);
                imgDiv.hide();

                htmlDiv.prepend(imgDiv);

                if (htmlIDX > (itemData.length - 1)) {
                    htmlIDX = 0;
                } else if (htmlIDX < 0) {
                    htmlIDX = itemData.length - 1;
                }

                if (itemData[htmlIDX]) {
                    var item = itemData[htmlIDX];
                    if (util.isDefinedAndNotNull(item.LINK)) {
                        imgDiv.css("cursor", "pointer");
                        imgDiv.on("click", function () {
                            util.link(item.LINK);
                        });
                    }

                    /*     if (util.isDefinedAndNotNull(item.SRC_TITLE)) {
                             var imgTitle = $("<h3></h3>");
                             imgTitle.addClass("swiper-img-title");
                             if (pConfigJSON.escapeHTMLRequired) {
                                 imgTitle.text(item.SRC_TITLE);
                             } else {
                                 imgTitle.html(item.SRC_TITLE);
                             }
                             imgDiv.append(imgTitle);
                         }*/

                    var imgSRC = item.SRC_VALUE;

                    if (item.SRC_TYPE == 'blob') {
                        var items2Submit = pConfigJSON.item2Submit;
                        imgSRC = apex.server.pluginUrl(pConfigJSON.ajaxID, {
                            x01: "GET_IMAGE",
                            x02: imgSRC,
                            pageItems: items2Submit
                        });
                    }

                    imgDiv.css("background-image", "url(" + imgSRC + ")");

                    $(imgDiv).fadeIn("fast");

                    /* make it auto play when duration is set */
                    var cur = item;
                    var dur = cur.DURATION;
                    if (dur && dur > 0) {
                        function setTimeOut(pPreventSetIDX) {
                            timeOut = setTimeout(function () {
                                htmlIDX++;
                                $(imgDiv).fadeOut("fast", function () {
                                    prepareHTMLRender();
                                });
                            }, dur * 1000);
                        }

                        $(htmlDiv).hover(function () {
                            clearTimeout(timeOut);
                        });

                        $(htmlDiv).mouseleave(function () {
                            setTimeOut();
                        });

                        setTimeOut();
                    }
                }
            }

            /* go to next img */
            function goDown() {
                htmlIDX++;
                clearTimeout(timeOut);
                $(htmlDiv).find(".swiper-img-container").fadeOut("fast", function () {
                    prepareHTMLRender();
                });
            }

            /* go to previous img */
            function goUp() {
                htmlIDX--;
                clearTimeout(timeOut);
                $(htmlDiv).find(".swiper-img-container").fadeOut("fast", function () {
                    prepareHTMLRender();
                });
            }

            /* bind mouswheel */
            if ($.inArray("mousewheel", pConfigJSON.controls) >= 0) {
                $(pConfigJSON.parentIDSelector).bind('mousewheel DOMMouseScroll', function (event) {
                    event.preventDefault();
                    if (event.originalEvent.wheelDelta >= 0) {
                        goUp();
                    } else {
                        goDown()
                    }
                });
            }

            /* bind arrow keys */
            if ($.inArray("keyboard", pConfigJSON.controls) >= 0) {
                $("body").keydown(function (e) {
                    if (e.keyCode == 37) {
                        goUp();
                    } else if (e.keyCode == 39) {
                        goDown();
                    }
                });
            }

            /* add control buttons for slide */
            if ($.inArray("arrows", pConfigJSON.controls) >= 0) {
                var leftControl = $("<div></div>");
                leftControl.addClass("swiper-item-html-slide-lc");
                leftControl.on("click", function () {
                    goUp()
                });

                var leftControlIcon = $("<span></span>");
                leftControlIcon.addClass("fa fa-chevron-left fa-lg");
                leftControlIcon.addClass("swiper-item-html-slide-lc-s");
                leftControl.append(leftControlIcon);

                $(htmlDiv).append(leftControl);

                var rightControl = $("<div></div>");
                rightControl.addClass("swiper-item-html-slide-rc");
                rightControl.on("click", function () {
                    goDown();
                });

                var rightControlIcon = $("<span></span>");
                rightControlIcon.addClass("fa fa-chevron-right fa-lg");
                rightControlIcon.addClass("swiper-item-html-slide-rc-s");
                rightControl.append(rightControlIcon);

                /* append control buttons */
                $(htmlDiv).append(rightControl);
            }

            /* render imgages */
            prepareHTMLRender();

            util.loader.stop(pConfigJSON.parentIDSelector);

        } else {
            util.noDataMessage.show(pConfigJSON.parentIDSelector, pConfigJSON.noDataMessage);
        }
    }

    /***********************************************************************
     **
     ** Used to get data from server
     **
     ***********************************************************************/
    function getData(pConfigJSON) {

        /* cleanup */
        $(pConfigJSON.parentIDSelector).empty();
        var items2Submit = pConfigJSON.item2Submit;

        apex.server.plugin(
            pConfigJSON.ajaxID, {
                x01: "GET_SQL_SOURCE",
                pageItems: items2Submit
            }, {
                success: function (pData) {
                    drawSlideRegion(pData, pConfigJSON);
                },
                error: function (d) {
                    util.noDataMessage.show(pConfigJSON.parentIDSelector, "Error occured!");
                    util.debug.error({
                        "msg": d.responseText,
                        "err": d
                    });
                },
                dataType: "json"
            });
    }

    return {
        /***********************************************************************
         **
         ** Initial function
         **
         ***********************************************************************/
        initialize: function (pRegionID, pAjaxID, pNoDataMessage, pImageHeight, pImageSize, pBackgroundColor, pControls, pItems2Submit, pRequireHTMLEscape) {

            util.debug.info({
                "pRegionID": pRegionID,
                "pAjaxID": pAjaxID,
                "pNoDataMessage": pNoDataMessage,
                "pImageHeight": pImageHeight,
                "pImageSize": pImageSize,
                "pBackgroundColor": pBackgroundColor,
                "pItems2Submit": pItems2Submit,
                "pRequireHTMLEscape": pRequireHTMLEscape,
                "pControls": pControls
            });

            var configJSON = {};

            configJSON.imageHeight = pImageHeight;
            configJSON.imageSize = pImageSize;
            configJSON.backgroundColor = pBackgroundColor;
            configJSON.ajaxID = pAjaxID;
            configJSON.parentIDSelector = "#" + pRegionID + "-is";
            configJSON.regionID = pRegionID;
            configJSON.noDataMessage = pNoDataMessage;
            configJSON.item2Submit = pItems2Submit;
            configJSON.controls = pControls.split(":");
            configJSON.escapeHTMLRequired = true;

            $(configJSON.parentIDSelector).css("height", configJSON.imageHeight);

            util.loader.start(configJSON.parentIDSelector);

            if (pRequireHTMLEscape === false) {
                configJSON.escapeHTMLRequired = false;
            }

            getData(configJSON);

            // bind refresh event
            $("#" + pRegionID).bind("apexrefresh", function () {
                getData(configJSON);
            });
        }
    }
})();
