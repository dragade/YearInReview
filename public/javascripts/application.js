// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {
	pageId = $("body").attr("id");

	switch(pageId) {
		case "landing":
			initLanding();
			break;
		case "yir":		
			initYir();
			break;
		default:
			// Does nothing
	}
});


function initYir() {
	// This isn't quite working correctly in firefox
	//$("a.profile").tipsy();
}


function initLanding() {
	
	// Global vars
	maxWidth = "2600";
	maxHeight = "1685";
	
	// Hide 1st egg
	$("#egg1").hide(); $("#egg1bg").hide();	
		
	// Wait till everything is loaded
	$(window).load(function () {
		loadEggs();
	});			
}

function loadEggs() {
	loadEgg1();
};

function loadEgg1() {
	// Set hover
	var $img = $("img#w");
	
	$img.hover(function () {
		$(this).attr("src","images/w_hover.jpg");
		}, function() {
			// Do nothing
	});
	
	$("a#wa").click(function() {
		scrollRight();
		$("div#egg1").animate({
			left: '+=1755', // Move to right edge of background maximum
			easing: 'easeout',
		}, 1000, function() {									
			$("a#wa").unbind('click'); // Unbind the click animation			
			loadEgg2();
		});
	});		
	$("#egg1").show(); 
	$("#egg1bg").show();	
}

function loadEgg2() {	
	var $egg2 = $("#egg2");
	var $egg2bg = $("#egg2bg");
	var $a = $("a#ga");		
	var $img = $("img#g");
	var gx = maxWidth - ((Math.floor(Math.random() * 9) + 2) * 65); // Anywhere in the last 8 columns
	var gy = (Math.floor(Math.random() * 7) + 1) * 65; // Anywhere in the top 7 rows		
	
	/*
	$img.hover(function () {
		$(this).attr("src","resources/image/g_hover.jpg");
		}, function() {			
			// $(this).attr("src","resources/image/g.jpg");				
	})
	*/
	// Highlight the gnome automatically
	$img.attr("src", "images/g_hover.jpg");

	$a.click(function() {
		scrollBottom();
		$img.attr("src", "images/g_hover.jpg");
		$egg2.animate({
			top: maxHeight - 60, // Move to right edge of background maximum
			easing: 'easeout',
		}, 1000, function() {									
			$a.unbind('click'); // Unbind the click animation			
			loadEgg3();
		});		
	})

	$egg2.css({"top": gy, "left": gx});
	$egg2bg.css({"top": gy, "left": gx});	
	$a.focus();	
}

function loadEgg3() {
	var $egg3 = $("#egg3");
	var $egg3bg = $("#egg3bg");
	var $a = $("a#ia");
	var $img = $("img#i");
	var x = maxWidth - ((Math.floor(Math.random() * 5) + 2) * 65); // Anywhere in the last 7 columns
	var y = maxHeight - ((Math.floor(Math.random() * 3) + 2) * 65) + 5; // Anywhere in the last 3 rows		

	$img.attr("src", "images/i_hover.jpg");	
	$a.click(function() {
		scrollLeft();
		loadIdentity(y);
		$img.attr("src", "images/i_hover.jpg");
		$egg3.animate({
			left: 65 * 3,
			easing: 'easeout',
		}, 1000, function() {									
			$a.unbind('click'); // Unbind the click animation			
		});		
	})	
	
	$egg3.css({"top": y, "left": x});
	$egg3bg.css({"top": y, "left": x});	
	$("i#ga").focus();		
}

function loadIdentity(y) {
	$identity = $("#identity");
	$identity.css({"top": y, "left": 65 * 4});
}

function scrollRight() {
	$('html, body').animate({
		scrollLeft: maxWidth,
	}, 1000, function() {});
}
function scrollLeft() {
	$('html, body').animate({
		scrollLeft: 0,		 
	}, 1000, function() {});	
}
function scrollBottom() {
	$('html, body').animate({
		scrollTop: maxHeight,		 
	}, 1000, function() {});
}

