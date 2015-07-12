<cfset generator = createObject("component", "tdGenerator")>
<!--- Make an alias that's much shorter and easier to type... --->
<cfset me = generator.infectionGenerator>
<html>
			<cfoutput>
	<head>
		<title>
			Infection Generator
		</title>
		<cfinclude template="headInclude.cfm">
	</head>
	<body>
		<div class="container-fluid">
			<div class="row">
				<div class="col-sm-3 col-md-2 sidebar">
					<cfinclude template="navbar.cfm">
				</div>
				<div class="col-sm-9 col-md-10 main">
					<cfset cols = getMetadata(me.infectionQuery)>
					<cfset colList = "">
					<cfloop from="1" to="#arrayLen(cols)#" index="x">
						<cfset colList = listAppend(colList, cols[x].name)>
					</cfloop>
					<form class="form-horizontal  action="" id="generateForm"">
					<div class="col-sm-12 col-md-10 col-md-10">
						<div class="panel panel-primary">
							<div class="panel-heading">Generate Infections</div>
							<div class="panel-body">
								<div class="col-md-12">
									<!----
									    Add institution picker ...
									    
									p_inst_num               IN td_encounter.td_institution_id%TYPE,
									--->
									<div class="form-group">
										<div class="col-sm-4">
											<label for="p_inst_num" class="control-label">
												Institution(s):
											</label>
										</div>
										<div class="col-sm-8">
											<select name="p_inst_num" class="multiselect" multiple="multiple" id="p_inst_num">
												<cfloop query="me.institutionQuery">
													<option value="#me.institutionQuery.td_institution_id#">
														#me.institutionQuery.abbreviation# 
														- 
														#me.institutionQuery.institution_name# 
														(
														#me.institutionQuery.td_institution_id#
														) 
													</option>
												</cfloop>
											</select>
										</div>
									</div>
									<div class="form-group">
										<div class="col-sm-12 col-md-4">
											<label for="p_infection_list" class="control-label">Infection Type:</label>
										</div>
										<div class="col-sm-12 col-md-8">
											<select name="p_infection_list" class="multiselect" multiple="multiple" id="p_infection_list" required="required">
												<cfloop query="me.infectionQuery">
													<option value="#me.infectionQuery.infection_key#">#me.infectionQuery.infection_key#</option>
												</cfloop>
											</select>
										</div>
									</div>
									<!----
									p_start_date             IN DATE DEFAULT (SYSDATE - 30),
									--->
									<div class="form-group">
										<div class="col-sm-12 col-md-4">
											<label for="startdate" class="control-label">
												Start Date:
											</label>
										</div>
										<div class="col-sm-4">
											<input type="date" 
													label="Start Date:"
													name="p_start_date"
													id="p_start_date"
													class="form-control"
													value="#me.START_DATE#"
													min="#me.START_DATE#"
													max="#me.END_DATE#">
										</div>
									</div>
									
									<!----
									p_end_date               IN DATE DEFAULT SYSDATE,
									--->
									<div class="form-group">
										<div class="col-sm-12 col-md-4">
											<label for="enddate" class="control-label">
												End Date:
											</label>
										</div>
										<div class="col-sm-4">
											<input type="date"
													label="End Date:"
													name="p_end_date"
													id="p_end_date"
													class="form-control"
													value="#me.END_DATE#"
													min="#me.START_DATE#"
													max="#me.END_DATE#">
										</div>
									</div>
									<div class="form-group">
										<div class="col-sm-4">
											<label for="p_min_los" class="control-label">
												Minimum Infections:
											</label>
										</div>
										<div class="col-sm-8">
											<input type="number" min="0" max="1000" class="form-control"
											       placeholder="How many" name="p_min_infections" id="p_min_infections" required="required"
											       value="1">
										</div>
									</div>

									<div class="form-group">
										<div class="col-sm-4">
											<label for="p_min_los" class="control-label">
												Maximum Infections:
											</label>
										</div>
										<div class="col-sm-8">
											<input type="number" min="0" max="1000" class="form-control"
											       placeholder="How many" name="p_max_infections" id="p_max_infections" required="required"
											       value="1">
										</div>
									</div>
									</div>
									<div class="col-md-12">
									<div class="panel panel-info">
										<div class="panel-heading">Patient filtering</div>
										<div class="panel-body">
									<div class="form-group">
										<div class="col-sm-12 col-md-4"><label for="p_require_organism">Require organism result:</label></div>
										<div class="col-sm-12 col-md-8">
												<input type="checkbox" name="p_require_organism" id="p_require_organism" checked="checked">
												</input>
										</div>
									</div>
									<!--- 	Comment out for now since it's not useful and only confuses
									
									 		Was supposed to limit the patients to those results that have a location
									 		
									<div class="form-group">
										<div class="col-sm-12 col-md-4"><label for="p_require_location"  class="control-label">Require location:</label></div>
										<div class="col-sm-12 col-md-8">
											<input type="checkbox" name="p_require_location" id="p_require_location" />
										</div>
									</div>
									--->
									<div class="form-group">
										<div class="col-sm-12 col-md-4"><label for="p_require_hai"  class="control-label">Require HAI indicated results:</label></div>
										<div class="col-sm-12 col-md-8">
											<input type="checkbox" name="p_require_hai" id="p_require_hai" checked="checked" />
										</div>
									</div>
									<div class="form-group">
										<div class="col-sm-12 col-md-4"><label for="p_require_no_surv"  class="control-label">Patient has no surveillance document:</label></div>
										<div class="col-sm-12 col-md-8">
											<input type="checkbox" name="p_require_no_surv" id="p_require_no_surv" />
										</div>
									</div>
								</div>
							</div>
							</div>
							</div>
							<div class="panel-footer clearfix">
								<div class="col-sm-4"></div>
								<div class="pull-left">
									<input class="btn btn-primary" type="submit" value="Run Me" id="generateInfectionButton">
								</div>
							</div>
						</div>
						<div class="text-right">
						<button type="button" class="btn btn-info glyphicon glyphicon-plus" data-toggle="collapse" data-target="##inputData" id="debugButton"></button>
						</div>
						<pre id="inputData" class="panel-collapse collapse">Debug on, collapse to turn off</pre>
						<pre id="results"></pre>
					</div>
					</form>
				</div>
			</div>
		</div>
	</body>
	</cfoutput>
</html>