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
	headers = window.data.shift()

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

// $('.ui.dropdown').dropdown();

$('.button.filter').click(function(){
	console.log("filter");

});


});