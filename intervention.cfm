<cfset rules = createObject("component", "nhsnRules")>
<!--- Make an alias that's much shorter and easier to type... --->
<cfset me = rules.interventionMaker>
<!DOCTYPE html>
<cfoutput>
	<html>
		<head>
			<title>
				Intervention Generator
			</title>
			<cfinclude template="headInclude.cfm">
			<link rel="stylesheet" href="generator.css">
			</link>
		</head>
		<body>
			<div class="container-fluid">
				<div class="row">
					<div class="col-sm-3 col-md-2 sidebar">
						<cfinclude template="navbar.cfm">
					</div>
					
					<div id="messages">
						<cfloop array="#me.aMessages#" index="me.message">
							<span class="message">
								#me.message#
							</span>
							<br/>
						</cfloop>
						<div class="errors">
							<cfloop array="#me.aErrors#" index="me.err">
								<p class="error">
									ERROR: 
									#me.err#
								</p>
							</cfloop>
						</div>
					</div>
					<div class="col-sm-12 col-md-10 col-md-10">
						<div class="panel panel-primary">
							<div class="panel-heading">
								Generate Interventions
							</div>
							<div class="panel-body">
								<div class="col-md-12">
								
									<cfform format="html" action="##" name="interventionMaker" class="form-horizontal">
										<div class="form-group">
											<div class="col-sm-2">
												<label for="generation" class="control-label">
													Generation Seed:
												</label>
											</div>
											<div class="col-sm-8">
												<cfinput name="generation" type="text" label="Generation Seed: " 
												         value="#Form.generation#" class="form-control">
											</div>
										</div>
										<div class="form-group">
											<div class="col-sm-2">
												<label for="numIntsToCreate" class="control-label">
													Number of Interventions:
												</label>
											</div>
											<div class="col-sm-8">
												<cfinput name="numIntsToCreate" type="number" label="Number of Interventions: " 
												         value="#Form.numIntsToCreate#" class="form-control">
											</div>
										</div>
										
										<div class="form-group">
											<div class="col-sm-2">
												<label class="control-label">
													Intervention Types:
												</label>
											</div>
											<cfformgroup label="Intervention Types:" type="horizontal">
												<div class="col-sm-2">
													<div class="checkbox">
														<cfinput name="doClinActivities" type="checkbox" value="#me.CLINICAL_ACTIVITY_INT#" 
														         label="Clinical Activity">
														<label for="doClinActivities">
															Clinical Activity
														</label>
													</div>
												</div>
												<div class="col-sm-2">
													<div class="checkbox">
														<cfinput name="doGenerals" type="checkbox" value="#me.GENERAL_INT#" label="General">
														<label for="doGenerals">
															General
														</label>
													</div>
												</div>
											</cfformgroup>
										</div>
										
										<div class="form-group">
											<div class="col-sm-2">
												<label for="td_roster_id" class="control-label">
													Exclude Roster:
												</label>
											</div>
											<div class="col-sm-8">
												<cfselect name="td_roster_id" label="Exclude Roster:" query="me.qRosters" 
												          display="roster_display" value="td_roster_id" queryposition="below" 
												          multiple="yes" selected="#Form.td_roster_id#" size="5" 
												          class="form-control multiselect">
												</cfselect>
											</div>
										</div>
										
										<div class="form-group">
											<div class="col-sm-2">
												<label for="td_group_id" class="control-label">
													User Groups:
												</label>
											</div>
											<div class="col-sm-8">
												<cfselect name="td_group_id" label="User Groups:" query="me.qUserGroup" 
												          display="group_name" value="td_group_id" queryposition="below" multiple="yes"
												          selected="#Form.td_group_id#" size="5" class="form-control multiselect">
												</cfselect>
											</div>
										</div>
										
										<div class="form-group">
											<div class="col-sm-2">
												<label for="startdate" class="control-label">
													Start Date:
												</label>
											</div>
											<div class="col-sm-10">
												<cfinput type="datefield" label="Start Date:" name="startdate" id="startdate"
												         value="#Form.startdate#" class="form-control">
											</div>
										</div>
										<div class="form-group">
											<div class="col-sm-2">
												<label for="enddate" class="control-label">
													End Date:
												</label>
											</div>
											<div class="col-sm-10">
												<cfinput type="datefield" label="End Date:" name="enddate" id="enddate"
												         value="#Form.enddate#" class="form-control">
											</div>
										</div>
										
										<cfinput name="submitButton" type="submit" value="Create Interventions" 
										         class="btn btn-primary">
									</cfform>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</body>
	</html>
</cfoutput>