$(document).ready(function(){
	$(".sidebar").sidebar('attach events','.ui.launch.button');

	$(".menu a").click(function(){
   if ($(this).hasClass("active")) {
   	$(this).removeClass("active");
   } else {
   	$(this).addClass('active');
   }});

	$(".header.item").click(function() {
		$(this).next('div').toggle();
	});



	var generateData = function(rows, columns){
		arr = [] 
		var titles = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		for(i = 0; i < rows; i++){
			arr.push([]);
			for(j = 0; j < columns; j++){
				if(i==0){
					letter = titles[j%26]
					for(k=0; k < (j / 26); k++)
						letter += letter
					arr[i].push(letter)	
				
				} else
					arr[i].push(j)
			}
		}
		return arr;
	}


	
	// window.data = generateData(100, 100)

	var _translateToNames = function(row, col){
		return headers[0][col] + "" + row
	}

	var afterSelection = function(row, col){
		console.log("item selected: ", row, col)
		if (row > 0 && col < headers[0].length-1){
			$('.formula-builder').val($('.formula-builder').val() + " " +  _translateToNames(row,col))
			$('.formula-builder').focus();
		} 
	}

	var object_types = [] 


	$('#table').handsontable({
		data: window.data, 
		rowHeaders: true,
		colHeaders: headers,
	    contextMenu: true,
	    stretchH: 'all',
	    width: 1000,
	    height: 500,
		afterSelection: afterSelection

	});



	// ************ FILTER EVENT CODE *********** // 

	$('.ui.modal').modal();
	$('.dropdown').dropdown();

	var insertColumnNamesIntoDropdown = function(){
		for(i = 0; i < window.headers.length; i++){
			_.templateSettings.variable = "temp";
			var template = _.template(
		  		$("script.column-name-item").html()
			);
			var templateData = {
				 col_index: i,
		 		 col_name: window.headers[i]
			}
			$(".filter.modal .menu").prepend(
			    template(templateData)
			);
		}
	}

	window.insertFilterRow = function(row, name){
		console.log("inserting filter row", row, name);
		_.templateSettings.variable = "temp";

		// Grab the HTML out of our template tag and pre-compile it.
		var template = _.template(
		  $("script.filter-row-" + row).html()
		);
		// Define our render data (to be put into the "rc" variable).
		var templateData = {
		  col_name: name
		}
		$(".filter.modal .content").prepend(
		    template(templateData)
		);
		$('.dropdown').dropdown();
	}

	// Filter Button pressed
	$('.button.filter').click(function(){
		$('.filter-criteria').remove()
		console.log("filter");
		$('.ui.modal').modal("show");
		insertColumnNamesIntoDropdown();
		$('.column_name_dropdown').dropdown();
		$('.column_name_dropdown .text').text("Add Column to Data");
	});

	// Method is called when user selects column to filter by
	$(".filter.modal .menu").click(function(ev){
		col_selected = ($(ev.target).attr("data-value"));
		console.log("column selected", col_selected);
		type = schema['customers'][col_selected][1]
		if(type == "datetime" || type == "integer" || type == "float"){
			insertFilterRow("num-date", $(ev.target).text());
		} else if (type == "string") {
			insertFilterRow("string", $(ev.target).text());
		} else if (type == "boolean") {
			insertFilterRow("boolean", $(ev.target).text());
		}
		$('.column_name_dropdown .text').text("Add Column to Data");
	});



     

});