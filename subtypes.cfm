<html>
	<head>
		<title>
			Event Type List
		</title>
		<cfinclude template="headInclude.cfm">
		<!--
		<cfset code = "">
		<cfif isDefined("url.code")>
			<cfset code = UCase(url.code)>
		</cfif>
		<cfset generator = createObject("component", "tdGenerator")>
		<cfset me = generator>	
		<cfoutput>
			-->
			<script>
				function doctypeFormatter(value){
				value = value.trim();
				var returnValue = '<a href="subtypes.cfm"><i class="glyphicon glyphicon-remove"></i> ' + value + '</a>';
				if (value.toLowerCase() != "#LCase(code)#"){
					returnValue = '<a href="subtypes.cfm?code=' + value + '"><i class="glyphicon glyphicon-filter"></i>' + value + '</a>'
				}
				return returnValue;
				};
			</script><!-- 
		</cfoutput>
		-->
	</head>
	<body>
		<cfoutput>
			<cfset getCriteriaInfo = me.getCriteriaInfo(code=#code#)>
			<cfset cols = getMetadata(getCriteriaInfo)>
			<cfset colList = "">
			<cfloop from="1" to="#arrayLen(cols)#" index="x">
				<cfset colList = listAppend(colList, cols[x].name)>
			</cfloop>
		<div class="container-fluid">
			<div class="row">
				<div class="col-sm-3 col-md-2 sidebar">
					<cfinclude template="navbar.cfm">
				</div>
				<div class="col-sm-9 col-md-10 main">
					<div class="col-sm-10 col-md-12">
						<div class="panel panel-primary">
							<div class="panel-heading">Event Sub-Type(s)
							<cfif code NEQ "">
								for Code 
								#UCase(code)#
							</cfif>
							</div>
							<div class="panel-body">
								<div class="col-md-12">
									<table data-toggle="table" 
											data-striped="true" 
											data-classes="table table-hover table-condensed"
											data-show-refresh="true"
											data-show-toggle="true"
											data-show-columns="true"
											data-search="true"
											data-height="550"
						 					width="100%"
						 					data-pagination="true">
										<thead>
											<tr>
												<cfloop list="#colList#" index="col">
													<th data-field="#col#" data-sortable="true" data-formatter="#LCase(col)#Formatter">#col#</th>
												</cfloop>
											</tr>
										</thead>
										<tbody>
											<cfloop query="getCriteriaInfo">
												<tr>
													<cfloop list="#getCriteriaInfo.ColumnList#" index="anotherName">
														<td>
															#getCriteriaInfo[anotherName][getCriteriaInfo.currentRow]#
														</td>
													</cfloop>
												</tr>
											</cfloop>
										</tbody>
									</table>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
		</cfoutput>
	</body>
</html>