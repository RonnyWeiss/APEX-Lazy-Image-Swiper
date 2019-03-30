var apexImageSlider = (function () {
    "use strict";
    var scriptVersion = "1.1.1";
    var util = {
        version: "1.0.5",
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
        jsonSaveExtend: function (srcConfig, targetConfig) {
            var finalConfig = {};
            /* try to parse config json when string or just set */
            if (typeof targetConfig === 'string') {
                try {
                    targetConfig = JSON.parse(targetConfig);
                } catch (e) {
                    console.error("Error while try to parse targetConfig. Please check your Config JSON. Standard Config will be used.");
                    console.error(e);
                    console.error(targetConfig);
                }
            } else {
                finalConfig = targetConfig;
            }
            /* try to merge with standard if any attribute is missing */
            try {
                finalConfig = $.extend(true, srcConfig, targetConfig);
            } catch (e) {
                console.error('Error while try to merge 2 JSONs into standard JSON if any attribute is missing. Please check your Config JSON. Standard Config will be used.');
                console.error(e);
                finalConfig = srcConfig;
                console.error(finalConfig);
            }
            return finalConfig;
        },
        loader: {
            start: function (id) {
                if (util.isAPEX()) {
                    apex.util.showSpinner($(id));
                } else {
                    /* define loader */
                    var faLoader = $("<span></span>");
                    faLoader.attr("id", "loader" + id);
                    faLoader.addClass("ct-loader");

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
            stop: function (id) {
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
        try {
            var topParentDiv = $(pConfigJSON.parentIDSelector);

            topParentDiv.empty();
            util.noDataMessage.hide(pConfigJSON.parentIDSelector);

            if (pData.row && pData.row.length > 0) {
                var parentDiv = $("<div></div>");
                parentDiv.addClass("swiper-container");
                parentDiv.attr("id", pConfigJSON.regionID + "-sd");
                parentDiv.css("min-height", pConfigJSON.regionMinHeight);

                topParentDiv.append(parentDiv);

                var wrapperDiv = $("<div></div>");
                wrapperDiv.addClass("swiper-wrapper");
                wrapperDiv.css("height", "maxHeight");

                $.each(pData.row, function (idx, item) {
                    var slideDiv = $("<div></div>");
                    slideDiv.addClass("swiper-slide");

                    var img = $("<img>");

                    img.css("max-width", pConfigJSON.imgMaxWidth);
                    img.css("max-height", pConfigJSON.imgMaxHeight);
                    img.css("display", "block");
                    img.css("margin", "0 auto");
                    img.addClass("swiper-lazy");
                    if (item.ACTION_TYPE) {
                        img.dblclick(function () {
                            if (item.ACTION_TYPE === "javascript") {
                                if (item.ACTION) {
                                    try {
                                        eval(item.ACTION);
                                    } catch (e) {
                                        util.debug.error("Error while try to execute javascript from SQL");
                                        util.debug.error(e);
                                    }
                                }
                            } else if (item.ACTION_TYPE === "link") {
                                if (item.ACTION) {
                                    util.link(item.ACTION);
                                }
                            } else if (item.ACTION_TYPE === "like") {
                                $("#" + pConfigJSON.regionID).trigger("like", [item, this]);
                                eval(item.ACTION);
                                var heartDiv = $("<div></div>");
                                heartDiv.addClass("swiper-like-heart");
                                var heart = $("<span></span>");
                                heart.addClass("fa fa-heart fa-lg");
                                heart.css("font-size", "70px");
                                heartDiv.append(heart);
                                var par = img.parent();
                                par.append(heartDiv);
                                heartDiv.animate({
                                    opacity: 1
                                }, 500);
                                setTimeout(function () {
                                    heartDiv.animate({
                                        opacity: 0
                                    }, 500);
                                    heart.remove();
                                }, 2000);
                            } else {
                                if (item.ACTION) {
                                    util.link(item.ACTION, true);
                                }
                            }
                        });
                    }

                    if (item.SRC_TYPE == 'blob') {
                        var items2Submit = pConfigJSON.item2Submit;
                        var imgSRC = apex.server.pluginUrl(pConfigJSON.ajaxID, {
                            x01: "GET_IMAGE",
                            x02: item.SRC_VALUE,
                            pageItems: items2Submit
                        });

                        //slideDiv.css("background-image", "url(" + imgSRC + ")");
                        img.attr("data-src", imgSRC);
                    } else {
                        //slideDiv.css("background-image", "url(" + item.VALUE + ")");
                        img.attr("data-src", item.SRC_VALUE);
                    }

                    slideDiv.append(img);

                    if (item.SRC_TITLE && item.SRC_TITLE.length > 0) {
                        var imgTitle = $("<h3></h3>");
                        imgTitle.addClass("swiper-img-title");
                        if (pConfigJSON.escapeHTMLRequired) {
                            imgTitle.text(item.SRC_TITLE);
                        } else {
                            imgTitle.html(item.SRC_TITLE);
                        }
                        imgTitle.hide();
                        slideDiv.append(imgTitle);
                    }

                    wrapperDiv.append(slideDiv);

                });

                parentDiv.append(wrapperDiv);

                if (pConfigJSON.pagination) {
                    var paginationDiv = $("<div></div>");
                    paginationDiv.addClass("swiper-pagination swiper-pagination-" + pConfigJSON.buttonColor);

                    parentDiv.append(paginationDiv);
                }

                if (pConfigJSON.controlButtons) {
                    var prevButton = $("<div></div>");
                    prevButton.addClass("swiper-button-prev swiper-button-" + pConfigJSON.buttonColor);
                    parentDiv.append(prevButton);

                    var nextButton = $("<div></div>");
                    nextButton.addClass("swiper-button-next swiper-button-" + pConfigJSON.buttonColor);
                    parentDiv.append(nextButton);
                }

                if (pConfigJSON.scrollBar) {
                    var scrollBarDiv = $("<div></div>");
                    scrollBarDiv.addClass("swiper-scrollbar");

                    parentDiv.append(scrollBarDiv);
                }

                var swiperJSON = {
                    navigation: {
                        nextEl: '.swiper-button-next',
                        prevEl: '.swiper-button-prev',
                    },
                    keyboard: {
                        enabled: pConfigJSON.keyboardControl,
                    },
                    pagination: {
                        el: '.swiper-pagination',
                        clickable: true,
                    },
                    scrollbar: {
                        el: '.swiper-scrollbar',
                    },
                    loop: pConfigJSON.loop,
                    grabCursor: true,
                    effect: pConfigJSON.effect,
                    centeredSlides: true,
                    slidesPerView: 2,
                    autoHeight: true,
                    preloadImages: false,
                    zoom: false,
                    coverflowEffect: pConfigJSON.coverflowEffectSettings,
                    lazy: {
                        loadPrevNext: true,
                        loadPrevNextAmount: 2,
                        loadOnTransitionStart: true
                    },
                    on: {
                        lazyImageLoad: function () {
                            util.loader.stop(pConfigJSON.parentIDSelector);
                            util.loader.start(pConfigJSON.parentIDSelector);
                        },
                        lazyImageReady: function () {
                            util.loader.stop(pConfigJSON.parentIDSelector);
                        },
                        slideChange: function () {
                            var _self = this;
                            $.each(_self.slides, function (idx, slide) {
                                $(slide).find(".swiper-img-title").hide();
                                if (idx === _self.activeIndex) {
                                    $(slide).find(".swiper-img-title").show();
                                }
                            });
                        }
                    },
                    mousewheel: pConfigJSON.mousewheelControl,
                };

                if (pConfigJSON.autoplay.enabled) {
                    swiperJSON.autoplay = pConfigJSON.autoplay;
                }
                var id = "#" + pConfigJSON.regionID + "-sd";
                var mySwiper = new Swiper(id, swiperJSON);
            } else {
                util.noDataMessage.show(pConfigJSON.parentIDSelector, pConfigJSON.noDataMessage);
            }
        } catch (e) {
            util.debug.error("Error while try to drive image slider");
            util.debug.error(e);
        }
    }

    /***********************************************************************
     **
     ** Used to get data from server
     **
     ***********************************************************************/
    function getData(pConfigJSON) {
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
                    util.debug.error(d.responseText);
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
        initialize: function (pRegionID, pAjaxID, pNoDataMessage, pConfigJSON, pItems2Submit, pRequireHTMLEscape) {
            var stdConfigJSON = {
                "autoplay": {
                    "delay": 2500,
                    "disableOnInteraction": false,
                    "enabled": false
                },
                "buttonColor": "white",
                "controlButtons": true,
                "effect": "coverflow",
                "imgMaxHeight": "600px",
                "imgMaxWidth": "100%",
                "keyboardControl": true,
                "loop": true,
                "mousewheelControl": true,
                "pagination": false,
                "regionMinHeight": "600px",
                "scrollBar": false,
                "coverflowEffectSettings": {
                    "rotate": 90,
                    "stretch": 0,
                    "depth": 100,
                    "modifier": 1,
                    "slideShadows": true
                }
            };
            var configJSON = {};

            // merge jsons
            configJSON = util.jsonSaveExtend(stdConfigJSON, pConfigJSON);

            configJSON.ajaxID = pAjaxID;
            configJSON.parentIDSelector = "#" + pRegionID + "-is";
            configJSON.regionID = pRegionID;
            configJSON.noDataMessage = pNoDataMessage;
            configJSON.item2Submit = pItems2Submit;

            configJSON.escapeHTMLRequired = true;

            if (pRequireHTMLEscape === false) {
                configJSON.escapeHTMLRequired = false;
            }

            if (configJSON.buttonColor === 'white') {
                configJSON.buttonColor = "white"
            } else {
                configJSON.buttonColor = "black";
            }

            if (configJSON.effect === 'coverflow') {
                configJSON.effect = "coverflow"
            } else {
                configJSON.effect = "fade";
            }

            getData(configJSON);


            // bind refresh event
            $("#" + pRegionID).bind("apexrefresh", function () {
                getData(configJSON);
            });
        }
    }
})();
