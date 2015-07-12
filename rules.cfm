<html>
	<head>
		<title>
			Rules List
		</title>
		<cfinclude template="headInclude.cfm">
		<cfset generator = createObject("component", "tdGenerator")>
		<cfset me = generator>		
		<script>
			function event_typeFormatter(value) {
			value = value.trim();
			return '<a href="eventcriteria.cfm?code=' + value + '">' + value + '</a>'
			}
			;
			function criteriaFormatter(value) {
			value = value.trim();
			return '<a href="criteria.cfm?code=' + value + '">' + value + '</a>'
			}
			;
		</script>
	</head>
	<body>
		<cfoutput>
		<cfset td_nhsn_criteria_ids = "">
		<cfif isDefined("url.td_nhsn_criteria_ids")>
			<cfset td_nhsn_criteria_ids = url.td_nhsn_criteria_ids>
		</cfif>
							<cfset eventRules = me.getRules(#td_nhsn_criteria_ids#)>
					<cfset cols = getMetadata(eventRules)>
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
							<div class="panel-heading">Rules #UCase(td_nhsn_criteria_ids)#
							<cfif td_nhsn_criteria_ids NEQ ""> 
								#UCase(td_nhsn_criteria_ids)#
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
											data-search="true">
										<thead>
											<tr>
												<!-- 
												<cfloop list="#colList#" index="col">
													-->
													<th data-field="#col#" data-sortable="true" data-formatter="#LCase(col)#Formatter">
														#col#
													</th>
													<!-- 
												</cfloop>
												-->
											</tr>
										</thead>
										<tbody>
											<cfloop query="eventRules">
												<tr>
													<cfloop list="#colList#" index="anotherName">
														<td>
															#eventRules[anotherName][eventRules.currentRow]#
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