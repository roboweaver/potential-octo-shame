<html>
	<head>
		<cfset code = "">
		<cfif isDefined("url.code")>
			<cfset code = url.code>
		</cfif>
		<cfset generator = createObject("component", "tdGenerator")>
		<cfset me = generator.infectionGenerator>		
		<cfset infectionClassQuery = me.getInfectionClasses(#code#)>
		<cfset cols = getMetadata(infectionClassQuery)>
		<cfset colList = "">
		<cfloop from="1" to="#arrayLen(cols)#" index="x">
			<cfset colList = listAppend(colList, cols[x].name)>
		</cfloop>
		<title>
			Infection Classes
		</title>
		<cfinclude template="headInclude.cfm">
		<script>
			<!-- format the code links -->
			function codeFormatter(value) {
				value = value.trim();
				return '<a href="eventtypes.cfm?infClass=' + value + '">' + value + '</a>'
			};
		</script>
	</head>
	<body>
		<cfoutput>
		<div class="container-fluid">
			<div class="row">
				<div class="col-sm-3 col-md-2 sidebar">
					<cfinclude template="navbar.cfm">
				</div>
				<div class="col-sm-9 col-md-10 main">
					<div class="col-sm-10 col-md-12">
						<div class="panel panel-primary">
							<div class="panel-heading">Infection Classes list #code#</div>
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
						 					data-width="100%"
						 					data-pagination="true">
										<thead>
											<tr>
												<cfloop list="#colList#" index="col">
													<th data-field="#col#" data-sortable="true" data-formatter="#LCase(col)#Formatter">#col#</th>
												</cfloop>
											</tr>
										</thead>
										<tbody>
											<cfloop query="infectionClassQuery">
												<tr>
													<cfloop list="#colList#" index="anotherName">
														<td>#infectionClassQuery[anotherName][infectionClassQuery.currentRow]#</td>
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