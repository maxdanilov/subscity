$(function() {
	var PRICE_MIN = 100;
	var PRICE_MAX = 600;
	var PRICE_STEP = 50;
	
	var buttonFilterPressed;
	var priceSliderValue;
	var priceSlider = "#price-slider";

	var buttonSortPressed;

	function format_price(val)
	{
		if ( val == PRICE_MAX)
			return "любая";
		else
			return val + " руб."
	}
	
	function hide(obj, speed)
	{
		if(typeof(speed)==='undefined') speed = 1000;
		obj.addClass("hidden");
		obj.fadeOut(speed);
	}
	
	function show(obj, speed)
	{
		if(typeof(speed)==='undefined') speed = 1000;
		obj.fadeIn(speed);
		obj.removeClass("hidden");
	}
	
	function stripe_table(obj, color_even, color_odd)
	{
		obj.find("tr.row-entity").not(".hidden").filter(":odd").find("td").css("background-color", color_odd);
		obj.find("tr.row-entity").not(".hidden").filter(":even").find("td").css("background-color", color_even);
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
			
			//stripe_table($(this).next("table"), "#f9f9f9", $("body").css("background-color"));

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
			$("#ticket-price").text(format_price( ui.value));
		},
		change: function( event, ui ) {
			$("#ticket-price").text(format_price( ui.value));
			priceSliderValuePrev = priceSliderValue;
			priceSliderValue = ui.value;
			if (priceSliderValuePrev != priceSliderValue)
				filter_screenings();
		}
	});
	
	/* Movie sorting button */
	
	function activateSortButton(button){
		var buttons = ["#button-sort-title", "#button-sort-date", "#button-sort-imdb", "#button-sort-kinopoisk", "#button-sort-screenings", "#button-sort-language"];
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
			$('#movie-plates .movie-plate').sort(compareBy).appendTo('#movie-plates');
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
	
	$(".show-button").click(function(){
		$(this).closest("table").next("table").toggle();
		$(this).children(":first").toggleClass("glyphicon-chevron-down");
		$(this).children(":first").toggleClass("glyphicon-chevron-up");
		//$("img").unveil(0);
		$(this).closest("table").next("table").find("img:first").unveil(0);
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
		var fields = ["attr-imdb", "attr-imdb-votes"];

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
		var fields = ["attr-kinopoisk", "attr-kinopoisk-votes"];
		
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
	
	/* When document is ready */
	
	$( document ).ready(function(){
	    
		//$("html").niceScroll({styler:"fb",cursorcolor:"#000"});
	
		activateFilterButton($("#button-all-day"));
		buttonFilterPressed = "all-day";
		priceSliderValue = PRICE_MAX;
		$( priceSlider ).slider( "value", PRICE_MAX );
		
		activateSortButton($("#button-sort-title"));
		buttonSortPressed = "sort-name";
		
		$("#filters").show();	

		disablePassedScreenings();
		window.setInterval(function(){
			disablePassedScreenings();
		}, 120 * 1000); // every 2 mins
		
		$("#button-screenings").addClass("active");
		
		//$("img").unveil(0);
		//$("img").trigger("unveil");
		
	});
       
});

// bg parallax
function onLoad() {
	return;
	/*window.onscroll = function() {
		document.body.style.backgroundPosition = "0px " + (-window.pageYOffset / 10) + "px";
	}*/
}

function rambler(cinemaId, movieId, time) {
	ticketManager.hallPlanV2(cinemaId, movieId, time);
	return false;
}
