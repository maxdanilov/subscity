$(function() {

	var PRICE_MIN = 100;
	var PRICE_MAX = 600;
	var PRICE_STEP = 50;
	
	var buttonFilterPressed;
	var priceSliderValue;
	var priceSlider = "#price-slider";

	var buttonSortPressed;
	var buttonTrailerPressed;

	function format_price(val)
	{
		if ( val == PRICE_MAX)
			return "любая";
		else
			return val + " <span class='fa fa-rub price-rub-sign-big'></span>";//" руб."
	}
	
	function hide(obj, speed)
	{
		if(typeof(speed)==='undefined') speed = 1000;
		//obj.fadeOut(speed);
		obj.addClass("hidden");
	}
	
	function show(obj, speed)
	{
		if(typeof(speed)==='undefined') speed = 1000;
		//obj.fadeIn(speed);
		obj.removeClass("hidden");
	}
	
	function toggle(obj, speed)
	{
		if(typeof(speed)==='undefined') speed = 1000;
		//obj.fadeIn(speed);
		obj.toggleClass("hidden");
	}
	
	/* FIlter screenings by price and time of day */
	
	function filter_screenings()
	{	
		$("td.cell-screenings").each(function() {
			if (filter_by_price($(this)) || filter_by_time($(this)))
				hide($(this));
			else
				show($(this));
		});
		
		$("tr.row-entity").each (function(){ 
			if ( $(this).find("td.cell-screenings").not('.hidden').size() == 0)
				hide($(this));
			else
				show($(this));
		});
		
		$(".header-day").each (function(){ 
			if ( $(this).next("table").find("tr.row-entity").not('.hidden').size() == 0)
			{
				hide($(this));
				hide($(this).next("table"));
			}
			else
			{
				show($(this));
				show($(this).next("table"));
			}			
		});
		
		if ($(".header-day").not(".hidden").size() == 0)
			show($("#nothing-found"));
		else
			hide($("#nothing-found"));
	}
	
	function filter_by_price(obj)
	{	
		price = obj.attr("attr-price");
		return ((price > priceSliderValue || typeof(price) == "undefined") && priceSliderValue < PRICE_MAX)
	}
	
	function filter_by_time(obj)
	{
		time = obj.attr("attr-time-of-day");
		return !(buttonFilterPressed == "all-day" || time == buttonFilterPressed);
	}
	
	/* Ticket price slider */
	
	$( priceSlider ).slider({
		value: PRICE_MAX,
		min: PRICE_MIN,
		max: PRICE_MAX,
		step: PRICE_STEP,
		slide: function( event, ui ) {
			$("#ticket-price").html(format_price( ui.value));
		},
		change: function( event, ui ) {
			$("#ticket-price").html(format_price( ui.value));
			priceSliderValuePrev = priceSliderValue;
			priceSliderValue = ui.value;
			if (priceSliderValuePrev != priceSliderValue)
				filter_screenings();
		}
	});
	
	/* Trailers switch button */
	
	function activateTrailerButton(button){
		var buttons = ["#button-trailer-original", "#button-trailer-dubbed"];
		buttons.forEach(function(b) {
			$(b).removeClass("active");
		});	
		$(button).addClass("active");
	}
	
	function clickTrailerButton(button, name)
	{
		activateTrailerButton(button);
		buttonTrailerPressedPrev = buttonTrailerPressed;
		buttonTrailerPressed = name;
		if (buttonTrailerPressed != buttonTrailerPressedPrev) 
			;//$('#movie-plates .movie-plate').sort(compareBy).appendTo('#movie-plates');
	}
	
	$("#button-trailer-original").click(function(){
		$("#trailer-original").show();
		$("#trailer-dubbed").hide();
		$("#button-trailer-original").addClass("active");
		$("#button-trailer-dubbed").removeClass("active");

		loadFrameVideo($("#trailer-dubbed"));
	});
	
	$("#button-trailer-dubbed").click(function(){
		$("#trailer-dubbed").show();
		$("#trailer-original").hide();
		$("#button-trailer-dubbed").addClass("active");
		$("#button-trailer-original").removeClass("active");
		
		loadFrameVideo($("#trailer-dubbed"));
	});
	
	function loadFrameVideo(container)
	{
		$(container).find('iframe[src="about:blank"]').prop("src", function()
			{	
				return $(this).data("src");
			});		
	}
	
	/* Movie sorting button */
	
	function activateSortButton(button){
		var buttons = ["#button-sort-title", "#button-sort-date", "#button-sort-imdb", "#button-sort-kinopoisk", "#button-sort-screenings", "#button-sort-next-screening", "#button-sort-language"];
		buttons.forEach(function(b) {
			$(b).removeClass("active");
		});	
		$(button).addClass("active");
	}
	
	function clickSortButton(button, name, compareBy)
	{
		activateSortButton(button);
		buttonSortPressedPrev = buttonSortPressed;
		buttonSortPressed = name;
		if (buttonSortPressed != buttonSortPressedPrev) 
		{
			$('#movie-plates .movie-plate').sort(compareBy).appendTo('#movie-plates');
			/*
			var plates = $('#movie-plates .movie-plate');
			var keys = [];
			var map = {};
			if (compareBy == movieCompareByTitle)
				getAttr = getAttrTitle;
			else
				getAttr = getAttrIMDB;
			plates.each(function(){
				var attr = getAttr($(this));
				keys.push(attr);
				map[attr] = $(this);
			});
			keys.sort();
			var platesInOrder = [];
			for (var j = 0, key; key = keys[j]; ++j)
    			platesInOrder.push(keys[key]);
    		$('#movie-plates').empty().append(plates);
    		*/
		}
		invokeScroll();
	}
	
	function getAttrTitle(a){
		return ( $(a).attr("attr_title").toLowerCase());
	}

	function getAttrIMDB(a){
		return ( $(a).attr("attr-imdb").toLowerCase());
	}

	$("#button-sort-title").click(function(){
		clickSortButton(this, "sort-title", movieCompareByTitle);
	});
	
	$("#button-sort-date").click(function(){
		clickSortButton(this, "sort-date", movieCompareByDate);
	});
	
	$("#button-sort-imdb").click(function(){
		clickSortButton(this, "sort-imdb", movieCompareByIMDB);
	});
	
	$("#button-sort-kinopoisk").click(function(){
		clickSortButton(this, "sort-kinopoisk", movieCompareByKinopoisk);
	});
	
	$("#button-sort-next-screening").click(function(){
		clickSortButton(this, "sort-next-screening", movieCompareByNextScreening);
	});

	$("#button-sort-screenings").click(function(){
		clickSortButton(this, "sort-screenings", movieCompareByScreenings);
	});

	$("#button-sort-language").click(function(){
		clickSortButton(this, "sort-language", movieCompareByLanguage);
	});
	
	/* Time of day selection */
	
	function activateFilterButton(button){
		var buttons = ["#button-morning", "#button-day", "#button-evening", "#button-all-day"];
		buttons.forEach(function(b) {
			$(b).removeClass("active");
		});	
		$(button).addClass("active");
	}
	
	function clickFilterButton(button, name)
	{
		activateFilterButton(button);
		buttonFilterPressedPrev = buttonFilterPressed;
		buttonFilterPressed = name;
		if (buttonFilterPressed != buttonFilterPressedPrev) 
			filter_screenings();
	}
	
	$("#button-morning").click(function(){
		clickFilterButton(this, "morning");
	});
	
	$("#button-day").click(function(){
		clickFilterButton(this, "day");
	});
	
	$("#button-evening").click(function(){
		clickFilterButton(this, "evening");
	});
	
	$("#button-all-day").click(function(){
		clickFilterButton(this, "all-day");
	});
	
	$("button.show-button").click(function(){
		var table = $(this).closest(".movie-plate-table").next("div").find("table");		
		//table.toggle();
		toggle(table);		
		table.find("img:first").unveil(0);
		
		var chevron = $(this).children(":first");
		chevron.toggleClass("fa-plus");
		chevron.toggleClass("fa-minus");
	});
	
	$("#button-movies").click(function(){
		$("#tab-movies").show();
		$("#tab-screenings").hide();
		$("#button-movies").addClass("active");
		$("#button-screenings").removeClass("active");
	});
	
	$("#button-screenings").click(function(){
		$("#tab-screenings").show();
		$("#tab-movies").hide();
		$("#button-screenings").addClass("active");
		$("#button-movies").removeClass("active");
	});
	
	function movieCompareByIMDB(a,b){
		var fields = ["attr-imdb", "attr-kinopoisk"];

		var contentA = parseFloat( $(a).attr(fields[0]));
		var contentB = parseFloat( $(b).attr(fields[0]));
		if (contentA == contentB)
		{
			contentA = parseFloat( $(a).attr(fields[1]));
			contentB = parseFloat( $(b).attr(fields[1]));
		}
		return (contentA > contentB) ? -1 : 1;//: (contentA > contentB) ? 1 : 0;
	}
	
	function movieCompareByKinopoisk(a,b){
		var fields = ["attr-kinopoisk", "attr-imdb"];
		
		var contentA = parseFloat( $(a).attr(fields[0]));
		var contentB = parseFloat( $(b).attr(fields[0]));
		if (contentA == contentB)
		{
			contentA = parseFloat( $(a).attr(fields[1]));
			contentB = parseFloat( $(b).attr(fields[1]));
		}
		return (contentA > contentB) ? -1 : 1;
	}
	
	function movieCompareByDate(a,b){
		var fields = ["attr-created"];
		
		var contentA = parseInt( $(a).attr(fields[0]));
		var contentB = parseInt( $(b).attr(fields[0]));
		return (contentA > contentB) ? -1 : 1;
	}

	function movieCompareByLanguage(a,b){
		var fields = ["attr-language"];
		
		var contentA = ( $(a).attr(fields[0]).toLowerCase());
		var contentB = ( $(b).attr(fields[0]).toLowerCase());
		if (!contentA)
			return 1;
		if (!contentB)
			return -1;
		if (contentA == contentB)
			return movieCompareByTitle(a,b);
		return (contentA < contentB) ? -1 : 1;
	}
	
	function movieCompareByTitle(a,b){
		var fields = ["attr-title"];
		
		var contentA = ( $(a).attr(fields[0]).toLowerCase());
		var contentB = ( $(b).attr(fields[0]).toLowerCase());
		return (contentA < contentB) ? -1 : 1;
	}
	
	function movieCompareByNextScreening(a,b){
		var fields = ["attr-next-screening"];
		
		var contentA = parseInt( $(a).attr(fields[0]));
		var contentB = parseInt( $(b).attr(fields[0]));
		return (contentA < contentB) ? -1 : 1;
	}

	function movieCompareByScreenings(a,b){
		var fields = ["attr-screenings"];
		
		var contentA = parseInt( $(a).attr(fields[0]));
		var contentB = parseInt( $(b).attr(fields[0]));
		return (contentA > contentB) ? -1 : 1;
	}
	
	function disablePassedScreenings()
	{
		$('a.price-button:not(.disabled)').each(function(){
			timestamp = parseInt ($(this).parent().attr('attr-time'));
			current = (new Date()).getTime() / 1000;
			if ( !isNaN(timestamp) && (timestamp - current) < 1800.0 ) // disable button 30 mins before begin
				$(this).addClass('disabled');
		});
	}
	

	function invokeScroll()
	{
		$(window).scrollTop($(window).scrollTop() + 1);
		$(window).scrollTop($(window).scrollTop() - 1);
	}

	/* When document is ready */
	
	$( document ).ready(function(){
		activateFilterButton($("#button-all-day"));
		buttonFilterPressed = "all-day";
		priceSliderValue = PRICE_MAX;
		$( priceSlider ).slider( "value", PRICE_MAX );
		
		//activateSortButton($("#button-sort-title"));
		//buttonSortPressed = "sort-name";
		
		activateTrailerButton($("#button-trailer-original"));
		buttonTrailerPressed = "trailer-original";		
		$("#button-group-trailers").show();		
		loadFrameVideo($("#trailer-original"));
		$("#trailer-original").show();
		$("#trailers").show();
		
		$("#filters").show();	

		disablePassedScreenings();
		window.setInterval(function(){
			disablePassedScreenings();
		}, 120 * 1000); // every 2 mins
		
		$("#button-screenings").addClass("active");	

		//$(".movie-poster-mobile img.poster").trigger("unveil");
		$(".movie-poster-mobile img.poster").unveil(300);
	
		// hack to trigger scrolling (unveil doesn't work until scroll happens although it should)
		invokeScroll();
		//$("img.poster").unveil();
		$("#button-sort-imdb").click();
	});
       
});

function rambler(cinemaId, movieId, time) {
	ticketManager.hallPlanV2(cinemaId, movieId, time);
	return false;
}
