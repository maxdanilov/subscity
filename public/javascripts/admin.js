$(function() {
	var ticking = false;

	/* Admin section */

	function fillAdminPage()
	{
		$("select.movie").each(function(){
			for(var i = 0; i < titles.length; i++)
				$(this).append("<option attr-id=" + ids[i] + " value=" + (i + 1) + ">" + "[" + ids[i] + "] " + titles[i] + "</option>");
		});
	}

	// on selected movie change, reload kinopoisk, imdb and trailers
	$("select.movie").change(function () {
		parent = $(this).closest(".movie-edit");
		if ($(this).val() > 0)
			{
				i = $(this).val() - 1;
				parent.find(".kinopoisk").val(kinopoiskIds[i]);
				parent.find(".imdb").val(imdbIds[i]);
				parent.find(".trailer-original").val(trailers_original[i]);
				parent.find(".trailer-russian").val(trailers_russian[i]);
			}
		else
			{
				parent.find(".kinopoisk").val("");
				parent.find(".imdb").val("");
				parent.find(".trailer-original").val("");
				parent.find(".trailer-russian").val("");
			}
	}).change();

	function writeToLog(data)
	{
		writeToLogNoNewLine(data + "\n");
	}

	function writeToLogNoNewLine(data)
	{
		$("#result-update:hidden").show();
		$("#result-update").append(data);
		$(document).scrollTop($(document).height());
	}

	function tabText(s)
	{
		arrayOfLines = s.match(/[^\r\n]+/g);
		result = "";
		if (arrayOfLines)
			for(i = 0; i < arrayOfLines.length; i++)
			{
				result += "\t" + arrayOfLines[i] + "\n";
			}
		return result;
	}

	function startTicking()
	{
		ticking = true;
	}

	function stopTicking()
	{
		ticking = false;
	}
	function tick()
	{
		if (ticking)
			writeToLogNoNewLine(".");
	}

	function blockSubmit()
	{
		$("#submit-update").attr("disabled", true);
	}

	function unblockSubmit()
	{
		$("#submit-update").removeAttr("disabled");
	}

	function parseYoutubeUrl(url)
	{
		if (typeof url === 'undefined')
			return "";
		if (url.length <= 11)
			return url;
		var regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
		var match = url.match(regExp);
		if (match && match[2].length == 11)
		  return match[2];
		else
		  return "";
	}

	$('.trailer-russian, .trailer-original').blur(function() {
	  	$(this).val(parseYoutubeUrl($(this).val()));
	});

	function updateMovie(id, title, kinopoisk, imdb, trailer_original, trailer_russian)
	{
        var a = $.Deferred();
		trailers = parseYoutubeUrl(trailer_original);
		if (parseYoutubeUrl(trailer_russian) != "")
			trailers += "*" + parseYoutubeUrl(trailer_russian);
		writeToLogNoNewLine( ":: updating [" + id + "] '" + title + "' ");
		var start = new Date().getTime();
		url = "/movies/update";
		$.post( url, { id: id.toString(), kinopoisk_id: kinopoisk.toString(), imdb_id: imdb.toString(), trailers: trailers.toString() } )
			.done(function(msg) {
				var elapsed = new Date().getTime() - start;
				writeToLog("\n" + tabText(msg));
			})
			.fail(function(msg) {
				writeToLog( "\n:: error" );
			})
			.always(function(){			
				a.resolve();
			});

		return a.promise();
	}

	$("#submit-update").click(function(){
		var chain = $.when(true);
		var funcs = [];
		startTicking();
		blockSubmit();
		$('.movie-edit').each(function(){
			var _id = $(this).find(".movie").val() - 1;
			if (_id >= 0)
			{
				var id = ids[_id];
				var title = titles[_id];
				var kinopoisk = $(this).find(".kinopoisk").val();
				var imdb = $(this).find(".imdb").val();
				var trailer_original = $(this).find(".trailer-original").val();
				var trailer_russian = $(this).find(".trailer-russian").val();
				if (typeof id !== 'undefined')
					funcs.push(function() { return updateMovie(id, title, kinopoisk, imdb, trailer_original, trailer_russian); });
			}
		});
		for(i = 0; i < funcs.length; i++)
			chain = chain.then(funcs[i]);
		chain = chain.done(stopTicking, unblockSubmit);
	});
	
	/* When document is ready */
	
	$( document ).ready(function(){
		if (admin)
		{
			fillAdminPage();
		}

		window.setInterval(function(){ tick(); }, 1000);

	});
	
});