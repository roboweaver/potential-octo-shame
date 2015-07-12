<html>
		<cfoutput>
	<head>
		<cfset id = "">
		<cfif isDefined("url.id")>
			<cfset id = url.id>
		</cfif>
		<title>
			Surgery #id#
		</title>
		<cfinclude template="headInclude.cfm">
		
		<script>
			<!-- format the id links -->
			function td_surgery_idFormatter(value) {
				value = value.trim();
				return '<a href="surgery.cfm?id=' + value + '">' + value + '</a>'
			};
			function td_surgery_idFormatter(value){
				value = parseInt(value.trim());
					var returnValue = '<a href="surgery.cfm"><i class="glyphicon glyphicon-remove"></i> ' + value + '</a>';
					if (value != parseInt("#id#")){
						returnValue = '<a href="surgery.cfm?id=' + value + '"><i class="glyphicon glyphicon-filter"></i>' + value + '</a>'
					}
					return returnValue;
			};
			jQuery(document).ready(function(){
				var headings = [];
				jQuery.getJSON('tdUser.cfc?method=getSurgery\&order=asc\&limit=10\&offset=0',
				function(response) {

				})
				.done(function(response){
					console.log('second success');
					var row1 = response.rows[1];
					var columns = [];
					jQuery.each(row1, function(key, val){
						columns.push({
							field: key,
							title: key,
							sortable: 'true',
							searchable: 'true'
						})
						jQuery('##headingRow').html(jQuery('##headingRow').html() + '<th data-field="' + key +'" data-sortable="true" data-formatter="' + key.toLowerCase() + 'Formatter">' + key + '</th>');
					});
					// Now do the interesting stuff ...
					jQuery('table##dataTable').bootstrapTable({
						columns: columns,
						data: response.rows,
						striped: "true",
						classes: "table table-hover table-condensed",
						showRefresh:"true",
						showToggle:"true",
						showColumns: "true",
						search:"true",
						height: "550",
						width:"100%",
						pagination: "true",
						pageSize: 10
					});

				})
				.fail(function(err){
					console.log('failed');
					console.log(err.responseText);
					console.log(jQuery.parseJSON(err.responseText));
				})
				.always(function(){
					console.log('complete');
				});
				
			});
		</script>
	</head>
	<body>
		<div class="container-fluid">
			<div class="row">
				<div class="col-sm-3 col-md-2 sidebar">
					<cfinclude template="navbar.cfm">
				</div>
				<div class="col-sm-9 col-md-10 main">
					<div class="col-sm-10 col-md-12">
						<div class="panel panel-primary">
							<div class="panel-heading">Surgery #id#</div>
							<div class="panel-body">
								<div class="col-md-12">
									<table id="dataTable"></table>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</body>
	</cfoutput>
</html>