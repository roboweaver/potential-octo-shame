<cfoutput>
	<html>
		<head>
		
			<cfset generator = createObject("component", "tdGenerator")>
			<!--- Make an alias that's much shorter and easier to type... --->
			<cfset me = generator.infectionGenerator>
			<title>
				Surgery Generator
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
						<form class="form-horizontal" action="" id="generateForm">
							<div class="col-sm-8 col-md-8">
								<div class="panel panel-primary">
									<div class="panel-heading">
										Generate Surgeries
									</div>
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
													<select name="p_inst_num" class="multiselect" multiple="multiple" id="p_inst_num"
													        required="required">
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
											<!---
											p_procedures_list        IN VARCHAR2 DEFAULT 
											
											'AAA,AMP,APPY,AVSD,BILI,BRST,CARD,CBGB,CBGC,CEA,CHOL,COLO,CRAN,CSEC,FUSN,FX,GAST,HER,HPRO,HTP,HYST,KPRO,KTP,LAM,LTP,NECK,NEPH,OVRY,PACE,PRST,PVBY,REC,RFUSN,SB,SPLE,THOR,THYR,VHYS,VSHN,XLAP,OTH',
											--->
											<div class="form-group">
												<div class="col-sm-4">
													<label for="p_procedures" class="control-label">
														Procedure Type(s):
													</label>
												</div>
												<div class="col-sm-8">
													<select name="p_procedures" class="multiselect col-sm-10" multiple="multiple" 
													        id="p_procedures" required="required">
														<cfloop query="me.procedureQuery">
															<option value="#me.procedureQuery.procedure_code#">
																#me.procedureQuery.procedure_code#
															</option>
														</cfloop>
													</select>
												</div>
											</div>
											<!----
											p_start_date             IN DATE DEFAULT (SYSDATE - 30),
											--->
											<div class="form-group">
												<div class="col-sm-4">
													<label for="p_start_date" class="control-label">
														Start Date:
													</label>
												</div>
												<div class="col-sm-4">
													<input type="date" label="Start Date:" name="p_start_date" id="p_start_date"
													       class="form-control" value="#me.START_DATE#"  
													       max="#me.END_DATE#">
												</div>
											</div>
											
											<!----
											p_end_date               IN DATE DEFAULT SYSDATE,
											--->
											<div class="form-group">
												<div class="col-sm-4">
													<label for="p_end_date" class="control-label">
														End Date:
													</label>
												</div>
												<div class="col-sm-4">
													<input type="date" label="End Date:" name="p_end_date" id="p_end_date"
													       class="form-control" value="#me.END_DATE#" 
													       max="#me.END_DATE#">
												</div>
											</div>
											<!---
											p_include_no_discharge   IN VARCHAR2 DEFAULT 'N'
											--->
											<div class="form-group">
												<div class="col-sm-4">
													<label for="p_include_no_discharge" class="control-label">
														Include non-discharged patients:
													</label>
												</div>
												<div class="col-sm-8">
													<input type="checkbox" name="p_include_no_discharge" id="p_include_no_discharge" 
													       value="Y"/>
												</div>
											</div>
											<!---
											 p_count                  IN NUMBER DEFAULT 30,
											 --->
											<div class="form-group">
												<div class="col-sm-4">
													<label for="p_count" class="control-label">
														Number to generate:
													</label>
												</div>
												<div class="col-sm-8">
													<input type="number" min="1" max="1000" class="form-control"
													       placeholder="How many" name="p_count" id="p_count" required="required"
													       value="30">
												</div>
											</div>
											
											<!---
											p_min_los                IN NUMBER DEFAULT 3,
											--->
											<div class="form-group">
												<div class="col-sm-4">
													<label for="p_min_los" class="control-label">
														Minimum LOS:
													</label>
												</div>
												<div class="col-sm-8">
													<input type="number" min="0" max="1000" class="form-control"
													       placeholder="How many" name="p_min_los" id="p_min_los" required="required"
													       value="1">
												</div>
											</div>
											
											<!---
											p_min_lab                IN NUMBER DEFAULT 1,
											--->
											<div class="form-group">
												<div class="col-sm-4">
													<label for="p_min_lab" class="control-label">
														Minimum Micros:
													</label>
												</div>
												<div class="col-sm-8">
													<input type="number" min="0" max="1000" class="form-control"
													       placeholder="How many" name="p_min_lab" id="p_min_lab" required="required"
													       value="1">
												</div>
											</div>
											<!---
													p_require_organism   IN VARCHAR2 DEFAULT 'N'
											--->
											<div class="form-group">
												<div class="col-sm-4">
													<label for="p_require_organism" class="control-label">
														Micros must have organism:
													</label>
												</div>
												<div class="col-sm-8">
													<input type="checkbox" name="p_require_organism" id="p_require_organism" value="Y"/>
												</div>
											</div>
											
											<!---
													p_surg_code_percent      IN NUMBER DEFAULT 50,
											--->
											<div class="form-group">
												<div class="col-sm-4">
													<label for="p_surg_code_percent" class="control-label">
														Percent w/surgeon codes:
													</label>
												</div>
												<div class="col-sm-8">
													<input type="number" min="0" max="50" class="form-control"
													       placeholder="How many" name="p_surg_code_percent" id="p_surg_code_percent" 
													       required="required" value="50">
												</div>
											</div>
											
											<!---
											p_surgeon               IN VARCHAR2 DEFAULT TD_GENERATE_DATA_PKG.GET_RANDOM_NAME,
											--->
											<!---
											p_anesthesiologist       IN VARCHAR2 DEFAULT TD_GENERATE_DATA_PKG.GET_RANDOM_NAME,
											--->
										</div>
									</div>
									<div class="panel-footer clearfix">
										<div class="col-sm-4">
										</div>
										<div class="pull-left">
											<input class="btn btn-primary" type="submit" value="Run Me" id="generateSurgeryButton">
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
	</html>
</cfoutput>