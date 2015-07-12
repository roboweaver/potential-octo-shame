<html>
	<head>
		<cfset code = "">
		<cfif isDefined("url.code")>
			<cfset code = url.code>
		</cfif>
		<cfset subtype = "">
		<cfif isDefined("url.subtype")>
			<cfset subtype = UCase(url.subtype)>
		</cfif>
		<cfset eventType = "">
		<cfif isDefined("url.eventType")>
			<cfset eventType = UCase(url.eventType)>
		</cfif>
		<cfset generator = createObject("component", "tdGenerator")>
		<cfset me = generator>		
		

		<title>
			Event Criteria List
		</title>
		<cfinclude template="headInclude.cfm">
		<cfoutput>
			<script>
				function codeFormatter(value){
					value = value.trim();
					var returnValue = '<a href="eventcriteria.cfm"><i class="glyphicon glyphicon-remove"></i> ' + value + '</a>';
					if (value.toLowerCase() != "#LCase(code)#"){
						returnValue = '<a href="eventcriteria.cfm?code=' + value + '"><i class="glyphicon glyphicon-filter"></i>' + value + '</a>'
					}
					return returnValue;
				};
				function subtypeFormatter(value){
					value = value.trim();
					var returnValue = '<a href="eventcriteria.cfm"><i class="glyphicon glyphicon-remove"></i> ' + value + '</a>';
					if (value.toLowerCase() != "#LCase(subtype)#"){
						returnValue = '<a href="eventcriteria.cfm?subtype=' + value + '"><i class="glyphicon glyphicon-filter"></i>' + value + '</a>'
					}
					return returnValue;
				};
				function event_typeFormatter(value){
					value = value.trim();
					var returnValue = '<a href="eventcriteria.cfm"><i class="glyphicon glyphicon-remove"></i> ' + value + '</a>';
					if (value.toLowerCase() != "#LCase(eventType)#"){
						returnValue = '<a href="eventcriteria.cfm?eventType=' + value + '"><i class="glyphicon glyphicon-filter"></i>' + value + '</a>'
					}
					return returnValue;	
				}
				function td_nhsn_criteria_idsFormatter(value){
					value = value.trim();
					return '<a href="rules.cfm?td_nhsn_criteria_ids='+ value +'">' + value + '</a>';
				};
			</script>
			</cfoutput>
	</head>
	<body>
		<cfoutput>
				<cfif code NEQ "">
			<cfset getCriteriaByCode = me.getCriteriaByCode(code=#code#, subtype='')>
		<cfelse>
			<cfif eventType NEQ "">
				<cfset getCriteriaByCode = me.getCriteriaByCode(eventType=#eventType#)>
			<cfelse>
				<cfset getCriteriaByCode = me.getCriteriaByCode(code=#code#, subtype=#subtype#)>
			</cfif>
		</cfif>
		<cfset cols = getMetadata(getCriteriaByCode)>
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
							<div class="panel-heading">Event Criteria
							<cfif code NEQ "">
								for Code 
								#UCase(code)#
							</cfif>
							<cfif subtype NEQ "">
								for subtype 
								#UCase(subtype)#
							</cfif>
							<cfif eventType NEQ "">
								for Event Type 
								#UCase(subtype)#
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
						 					data-width="100%"
						 					data-pagination="true">
										<thead>
											<tr>
												<cfloop list="#colList#" index="col">
													<th data-field="#col#" data-sortable="true" data-formatter="#LCase(col)#Formatter">
														#col#
													</th>
												</cfloop>
											</tr>
										</thead>
										<tbody>
											<cfloop query="getCriteriaByCode">
												<tr>
													<cfloop list="#colList#" index="anotherName">
														<td>
															#getCriteriaByCode[anotherName][getCriteriaByCode.currentRow]#
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