var w = 600,
	h = 600;

var colorscale = d3.scale.category10();

function getAxisValue(eje,porcentaje) {
	return {axis:eje,value:porcentaje};
}

function combineArrays(arr1, arr2, finalArr) {
  // Just so we don't have to remember to pass an empty array as the third
  // argument when calling this function, we'll set a default.
  finalArr = finalArr || [];

  // Push the current element in each array into what we'll eventually return
  finalArr.push(getAxisValue(arr1[0], arr2[0]));

  var remainingArr1 = arr1.slice(1),
      remainingArr2 = arr2.slice(1);

  // If the three arrays are empty, then we're done
  if(remainingArr1.length === 0 && remainingArr2.length === 0) {
    return finalArr;
  }
  else {
    // Recursion!
    return combineArrays(remainingArr1, remainingArr2, finalArr);
  }
};

function resumen(secciones,notas_max,coeficientes,resultados, finalArr) {
	finalArr = finalArr || [];

	var porcentajes = resultados[0].Notas.map(function(n, i) { return n * coeficientes[i] / notas_max[i]; });
	var sum = porcentajes.reduce(function(a, b) { return a + b });

	var sum_coeficientes = coeficientes.reduce(function(a, b) { return a + b });
	var avg = sum / sum_coeficientes;

	finalArr.push({
		nombre: resultados[0].Nombre,
		promedio: avg,
		d3: combineArrays(secciones, porcentajes)
	});
	var remainingResultados = resultados.slice(1);

	if(remainingResultados.length === 0) {
		return finalArr;
	} else {
		// Recursion!
		return resumen(secciones,notas_max,coeficientes,remainingResultados, finalArr);
	}
}

function draw_graphics(item,chart,wrapper) {
//Data
if (!item.coeficientes || item.coeficientes.length !== item.secciones.length) {
	item.coeficientes = Array.apply(null, new Array(item.secciones.length)).map(Number.prototype.valueOf,1);
}
var d = resumen(item.secciones,item.notas_max,item.coeficientes,item.resultados);

// Ordenar por promedio
d.sort(function(a,b) { return parseFloat(b.promedio) - parseFloat(a.promedio) });


function promedio2Percent(num) {
	return Math.ceil(num * 100);
}

//Legend titles
var LegendOptions = d.map(function(item) {
	return item.nombre;
});

var datos_d3 = d.map(function(item) {
	return item.d3;
});

//Options for the Radar chart, other than default
var mycfg = {
  w: w,
  h: h,
  maxValue: 1,
  levels: 5,
  ExtraWidthX: 400,
  radar_chart_serie: "item"+item.numero_item+"-radar-chart-serie",
  candidato: "item"+item.numero_item+"candidato",
  coeficientes: item.coeficientes
}

//Call function to draw the Radar chart
//Will expect that data is in %'s
RadarChart.draw(chart, datos_d3, mycfg);

////////////////////////////////////////////
/////////// Initiate legend ////////////////
////////////////////////////////////////////

function toggleRadarItem(item) {
	visible = item.style.visibility;
	if (!visible || visible.localeCompare("hidden")) {
		item.style.visibility = "hidden";
	} else {
		item.style.visibility = "visible";
	}
}

function toggleLegendItem(item) {
	style = item.style.fontWeight;
	if (!style || style.localeCompare("bold")) {
		item.style.fontWeight = "bold";
	} else {
		item.style.fontWeight = "";
	}
}

function toggleCandidate(i) {
	radar_items = document.getElementsByClassName(mycfg.radar_chart_serie + i);
	radar_items = Array.prototype.slice.call( radar_items );
	radar_items.map(toggleRadarItem);

	legend_items = document.getElementsByClassName(mycfg.candidato + i);
	legend_items = Array.prototype.slice.call( legend_items );
	legend_items.map(toggleLegendItem);
}

var svg = d3.select(wrapper)
	.selectAll('svg')
	.append('svg')
	.attr("width", w+400)
	.attr("height", h)

//Create the title for the legend
var text = svg.append("text")
	.attr("class", "title")
	.attr('transform', 'translate(200,0)')
	.attr("x", w - 70)
	.attr("y", 10)
	.attr("font-size", "12px")
	.attr("fill", "#404040")
	.text("Evaluados");

//Initiate Legend
var legend = svg.append("g")
	.attr("class", "legend")
	.attr("height", 100)
	.attr("width", 200)
	.attr('transform', 'translate(200,20)')
	;
	//Create colour squares
	legend.selectAll('rect')
	  .data(LegendOptions)
	  .enter()
	  .append("rect")
	  .attr("x", w - 65)
	  .attr("y", function(d, i){ return i * 20;})
	  .attr("width", 10)
	  .attr("height", 10)
	  .attr("class", function(d, i){ return mycfg.candidato + i;})
	  .style("fill", function(d, i){ return colorscale(i);})
	  .on("click", function(d, i){ return toggleCandidate(i);})
	  ;
	//Create text next to squares
	legend.selectAll('text')
	  .data(LegendOptions)
	  .enter()
	  .append("text")
	  .attr("x", w - 52)
	  .attr("y", function(d, i){ return i * 20 + 9;})
	  .attr("font-size", "11px")
	  .attr("fill", "#737373")
	  .attr("class", function(d, i){ return mycfg.candidato + i;})
	  .text(function(d) { return d; })
	  .on("click", function(d, i){ return toggleCandidate(i);})
	  ;

}
