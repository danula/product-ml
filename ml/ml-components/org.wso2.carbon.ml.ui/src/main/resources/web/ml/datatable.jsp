<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
	
<link rel="stylesheet" type="text/css" href="./css/mlmain.css">
<link rel="stylesheet" type="text/css" href="./css/jquery.dataTables.css">
<script src="./js/jquery.js"></script>
<script src="./js/jquery.dataTables.js"></script>
<script src="./js/d3.min.js"></script>

<%
	response.resetBuffer();
%>

<div id="changeSampleButtons">
	<a href=# > <button class="greenButton">Random Sample</button></a>
	<a href=# > <button class="greenButton">Full Data Set</button></a>
</div>

<table id="datasetTable" class="display">
	<thead>
		<tr>
			<th>Feature</th>
			<th>Input</th>
			<th>Type</th>
			<th>Summary Statistics</th>
			<th>Impute</th>
		</tr>
	</thead>
	<tbody>
	</tbody>
</table>

<div class="bottomNavigationButtons">
	<a href=# > <button class="blueButton">Explore Data</button></a>
	<a href=# > <button class="blueButton">Build Model</button></a>
</div>
<div style="clear:both"></div>
<script type="text/javascript">
    	$('document').ready(function() {    	
	    $('#datasetTable').dataTable({
	        "bServerSide": true,
	        "sAjaxSource": "datasetserviceclient_ajaxprocessor.jsp",
	        "bProcessing": false,
	        "bLengthChange": false,
	        "bFilter": false,
	    });

	    $('#datasetTable').on('draw.dt', function() {
	    	
	    	$('.summaryStatistics').each(function() {
	            var jsonText = $(this).text();
	            console.log(jsonText);
	            var jsonObj  = JSON.parse(jsonText);
	            $(this).text("");
	            
	            var type = jsonObj.type;
	            var frequencies = jsonObj.frequencies;
	            var dataArray = $.map(frequencies, function(value, index) {
            		return [value.frequency];
            	});
	            
	            if (type == 'CATEGORICAL'){       	
	            	
	            	var w = 40;
	            	var h = 40;
	            	var pie = d3.layout.pie();
	            	
	            	var outerRadius = w / 2;
	            	var innerRadius = 0;
	            	var arc = d3.svg.arc()
	            	                .innerRadius(innerRadius)
	            	                .outerRadius(outerRadius);

	            	  var svg = d3.select(this)
	            	            .append("svg")
	            	            .attr("width", w)
	            	            .attr("height", h);

	            	  var arcs = svg.selectAll("g.arc")
	            	        .data(pie(dataArray))
	            	        .enter()
	            	        .append("g")
	            	        .attr("class", "arc")
	            	        .attr("transform", "translate(" + outerRadius + ", " + outerRadius + ")");

	            	  var color = d3.scale.category20();
	            	  arcs.append("path")
	            	    .attr("fill", function(d, i) {
	            	        return color(i);
	            	    })
	            	    .attr("d", arc);
	            	
	            }else{
	            	
	            	var w = 200;
	            	var h = 40;	            	
	            	var barPadding = 1;
	            	var yScale = d3.scale.linear()
	                			  .domain([0, d3.max(dataArray, function(d) {
	                    			 return d;
	                			   })])
	                			   .range([0,h]);
	            	
	            	var svg = d3.select(this)
	                .append("svg")
	                .attr("width", w)
	                .attr("height", h);
	            	
	            	svg.selectAll("rect")
	 			   		.data(dataArray)
	 			   		.enter()
	 			   		.append("rect")
	 			   		.attr("x", function(d, i) {
	 			   			return i * (w / dataArray.length);
	 			   		})
	 			   		.attr("y", function(d) {
	 			   			return h - yScale(d);
	 			   		})
	 			   		.attr("width", w / dataArray.length - barPadding)
	 			   		.attr("height", function(d) {
	 			   			return yScale(d);
	 			   		})
	 			   		.attr("fill", '#2b8cab');
	            }
	        });
	        
            // TODO: AJAX call per change in the data-table is an overhead
            // findout a better approach
	        $('.fieldType').on('change', function(e) {
	            var closestTr = $(this).closest('tr');
	            var selectedFeature = closestTr.find('.feature').text();
	            
	            var selectedFeatureType = this.options[e.target.selectedIndex].text;

	            $.ajax({
	                type: "POST",
	                url: "./updatefeaturetype_ajaxprocessor.jsp",
	                data: {
	                    'FEATURE_TYPE': selectedFeatureType,
	                    'FEATURE_NAME': selectedFeature
	                }
	            });
	        });

	        $('.includeFeature').on('change', function(e) {
	            var closestTr = $(this).closest('tr');
	            var selectedFeature = closestTr.find('.feature').text();
	            var selectionFlag = 'false';

	            if (this.checked) {
	            	selectionFlag = 'true';
	            }
				console.log("selectionFlag: "+selectionFlag);
	            $.ajax({
	                type: "POST",
	                url: "./updateinput_ajaxprocessor.jsp",
	                data: {
	                    'IS_FEATURE_SELECTED': selectionFlag,
	                    'FEATURE_NAME': selectedFeature
	                }
	            });
	        });

	        $('.imputeMethod').on('change', function(e) {
	            var closestTr = $(this).closest('tr');
	            var selectedFeature = closestTr.find('.feature').text();
	            var imputedMethod = this.options[e.target.selectedIndex].text;

	            $.ajax({
	                type: "POST",
	                url: "./updateimputemethod_ajaxprocessor.jsp",
	                data: {
	                    'IMPUTE_OPTION': imputedMethod,
	                    'FEATURE_NAME': selectedFeature
	                }
	            });
	        });

	    });


	});
    </script>
