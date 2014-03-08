$(function() {
	var PRICE_MIN = 100;
	var PRICE_MAX = 600;
	var PRICE_STEP = 50;
	var buttonPressed;
	var sliderValue;

	function format_price(val)
	{
		if ( val == PRICE_MAX)
			return "любая";
		else
			return val + " руб."
	}
	
	function filter_by_price(obj)
	{	
		price = obj.attr("attr-price");
		return ((price > sliderValue || typeof(price) == "undefined") && sliderValue < PRICE_MAX)
	}
	
	function filter_by_time(obj)
	{
		time = obj.attr("attr-time-of-day");
		return !(buttonPressed == "all-day" || time == buttonPressed);
	}

	function hide(obj, speed)
	{
		if(typeof(speed)==='undefined') speed = 0;
		obj.addClass("hidden");
		obj.hide(speed);
	}
	
	function show(obj, speed)
	{
		if(typeof(speed)==='undefined') speed = 0;
		obj.show(speed);
		obj.removeClass("hidden");
	}
	
	function stripe_table(obj, color_even, color_odd)
	{
		obj.find("tr.row-entity").not(".hidden").filter(":odd").find("td").css("background-color", color_odd);
		obj.find("tr.row-entity").not(".hidden").filter(":even").find("td").css("background-color", color_even);
	}
	
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
			$("#nothing-found").show();
		else
			$("#nothing-found").hide();
	}
	
	$( "#slider" ).slider({
		value: PRICE_MAX,
		min: PRICE_MIN,
		max: PRICE_MAX,
		step: PRICE_STEP,
		slide: function( event, ui ) {
			$("#ticket-price").text(format_price( ui.value));
		},
		change: function( event, ui ) {
			$("#ticket-price").text(format_price( ui.value));
			sliderValuePrev = sliderValue;
			sliderValue = ui.value;
			if (sliderValuePrev != sliderValue)
				filter_screenings();
		}
	});
	
	function activateButton(button){
		var buttons = ["#button-morning", "#button-day", "#button-evening", "#button-all-day"];
		buttons.forEach(function(b) {
			$(b).removeClass("active");
		});	
		$(button).addClass("active");
	}
	
	$("#button-morning").click(function(){
		activateButton(this);
		buttonPressedPrev = buttonPressed;
		buttonPressed = "morning";
		if (buttonPressed != buttonPressedPrev) 
			filter_screenings();
	});
	
	$("#button-day").click(function(){
		activateButton(this);
		buttonPressedPrev = buttonPressed;
		buttonPressed = "day";
		if (buttonPressed != buttonPressedPrev) 
			filter_screenings();
	});
	
	$("#button-evening").click(function(){
		activateButton(this);
		buttonPressedPrev = buttonPressed;
		buttonPressed = "evening";
		if (buttonPressed != buttonPressedPrev) 
			filter_screenings();
	});
	
	$("#button-all-day").click(function(){
		activateButton(this);
		buttonPressedPrev = buttonPressed;
		buttonPressed = "all-day";
		if (buttonPressed != buttonPressedPrev) 
			filter_screenings();
	});
	
	$(".show-button").click(function(){
		$(this).closest("table").next("table").toggle();
		$(this).children(":first").toggleClass("glyphicon-chevron-down");
		$(this).children(":first").toggleClass("glyphicon-chevron-up");
	});

	$( document ).ready(function(){
		activateButton($("#button-all-day"));
		buttonPressed = "all-day";
		sliderValue = PRICE_MAX;
		
		$("#slider").slider( "value", PRICE_MAX );
	});
	
});
