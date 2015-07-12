<cfcomponent>
	<!--- Encapsulate in some kind of scope... --->
	<cfset This["interventionMaker"] = {}>
	<!--- Make an alias that's much shorter and easier to type... --->
	<cfset me = This.interventionMaker>

	<!--- Set some defaults... --->
	<cfset me.CLINICAL_ACTIVITY_INT = 523995>
	<cfset me.DEFAULT_DATASOURCE = "TDWEB">
	<cfset me.GENERAL_INT = 523993>
	<cfset me.MEDICATION_INT = 523994>

	<!--- Setup other vars --->
	<cfparam name="Form.enddate" default="#Now()#">
	<cfparam name="Form.generation" default="#GetTickCount()#">
	<cfparam name="Form.numIntsToCreate" default="10">
	<cfparam name="Form.startdate" default="#DateAdd('d',-1,Now())#">
	<cfparam name="Form.td_group_id" default="">
	<cfparam name="Form.td_roster_id" default="">

	<cfparam name="me.aErrors" default="#[]#">
	<cfparam name="me.aMessages" default="#[]#">
	<cfparam name="me.dbVersion" default="">
	<cfparam name="me.doGenerals" default="true">
	<cfparam name="me.doClinActivities" default="true">
	<cfparam name="me.int_id_list" default="">
	<cfparam name="me.maxTimeSpent" default="59">
	<cfparam name="me.maxActivities" default="3">
	<cfparam name="me.maxReasons" default="3">
	<cfparam name="me.maxOutcomes" default="3">
	<cfparam name="me.xmlDoc" default="">

	<cfset me.oAdmin = CreateObject("CFIDE.adminapi.administrator")>
	<cfset me.oDatasource = CreateObject("CFIDE.adminapi.datasource")>

	<cfif !structkeyexists(Form, "doClinActivities")>
		<cfset me.doClinActivities = false>
	</cfif>
	<cfif !structkeyexists(Form, "doGenerals")>
		<cfset me.doGenerals = false>
	</cfif>
	<cfif !me.doGenerals and !me.doClinActivities>
		<cfset me.doClinActivities = true>
	</cfif>
	<!--- Get datasource version --->
	<cfquery datasource="tdweb" name="me.qDBVersion">
		SELECT	value
		FROM		td_config
		WHERE		name = 'taf.version_string'
	</cfquery>
	<cfif me.qDBVersion.RecordCount>
		<cfset me.dbVersion = ListFirst(me.qDBVersion.value, ".")>
	</cfif>
	
	<cfif NOT IsNumeric(me.dbVersion)>
		<cfquery datasource="tdweb" name="me.qDBVersion">
			SELECT	td_dc_node_id
			FROM		td_dc_node
			WHERE		td_dc_node_id = 527629 <!--- intervention institution in data model --->
		</cfquery>
		<cfif me.qDBVersion.RecordCount>
			<cfset me.dbVersion = 4>
		<cfelse>
			<cfset me.dbVersion = 3>
		</cfif>
	</cfif>
	<!--- Users --->
	<cfquery datasource="tdweb" name="me.qUsers">
		SELECT	a.td_user_id, a.first, a.last
		FROM		td_user a, td_user_group b
		WHERE		a.td_user_id = b.td_user_id
		AND a.td_status_id = 1
		<cfif Form.td_group_id NEQ "">
			AND b.td_group_id IN (
			#Form.td_group_id#
			)
		</cfif>
		
	</cfquery>
	<cfset me.numUsers = me.qUsers.RecordCount>

	<!--- Patients --->
	<cfquery datasource="tdweb" name="me.qPatients">
		SELECT	td_patient_id
		<cfif me.dbVersion GT 3>
			, td_location_id,td_institution_id
		</cfif>
		FROM		td_tracker_date_vw
		WHERE		rownum <= 250
		<cfif Form.td_roster_id NEQ "">
			AND td_patient_id NOT IN (
			SELECT	rp.td_patient_id
			FROM		td_roster r, td_roster_patient rp
			WHERE		r.TD_ROSTER_ID = rp.TD_ROSTER_ID
			AND r.TD_ROSTER_ID IN (
			#Form.td_roster_id#
			)
			)
		</cfif>
		
	</cfquery>

	<!--- DateRange --->
	<!--- The dates submitted will have a midnight timestamp.  Let's bump up the enddate by 1 so that 
	the full date
	specified by the user is available.  Then we'll take the minimum of now and end date in order to 
	avoid creating
	interventions a couple hours into the future --->
	<cfset Form.enddate = DateAdd('d', 1, Form.enddate)>
	<cfif DateCompare(Form.enddate, Now()) EQ 1>
		<cfset Form.enddate = Now()>
	</cfif>
	<cfset me.numSecsTimeRange = DateDiff("s", Form.startdate, Form.enddate)>
	<cfif me.numSecsTimeRange LT 0>
		<cfset ArrayAppend(me.aErrors, "Start Date cannot be after End Date")>
	</cfif>
	<!--- Intervention Type --->
	<cfif me.doClinActivities>
		<cfset me.int_id_list = ListAppend(me.int_id_list, me.CLINICAL_ACTIVITY_INT)>
	</cfif>
	<cfif me.doGenerals>
		<cfset me.int_id_list = ListAppend(me.int_id_list, me.GENERAL_INT)>
	</cfif>
	<cfquery datasource="tdweb" name="me.qInterventionTypes">
		SELECT	td_dc_node_id AS int_type
		FROM		td_dc_node_vw n
		WHERE		parent_node = 523992
		<cfif Len(me.int_id_list)>
			AND td_dc_node_id IN (
			#me.int_id_list#
			)
		</cfif>
		
	</cfquery>
	<cfset me.numInterventionTypes = me.qInterventionTypes.RecordCount>
	<!--- Reasons --->
	<cfquery datasource="tdweb" name="me.qReasons">
		SELECT						*
		FROM							td_dc_node
		WHERE							classname != 'Folder'
		START WITH				td_dc_node_id = 518701
		CONNECT BY PRIOR	td_dc_node_id = parent_node
	</cfquery>
	<cfset me.numReasons = me.qReasons.RecordCount>
	<!--- Outcomes --->
	<cfquery datasource="tdweb" name="me.qOutcomes">
		SELECT						*
		FROM							td_dc_node
		WHERE							classname != 'Folder'
		START WITH				td_dc_node_id = 518720
		CONNECT BY PRIOR	td_dc_node_id = parent_node
	</cfquery>
	<cfset me.numOutcomes = me.qOutcomes.RecordCount>
	<!--- Clinical Activities --->
	<cfquery datasource="tdweb" name="me.qClinicalActivities">
		SELECT						*
		FROM							td_dc_node
		WHERE							classname != 'Folder'
		START WITH				td_dc_node_id = 518833
		CONNECT BY PRIOR	td_dc_node_id = parent_node
	</cfquery>
	<cfset me.numClinicalActivites = me.qClinicalActivities.RecordCount>
	<!--- Followup Status --->
	<cfquery datasource="tdweb" name="me.qFollowupStatus">
		SELECT	td_dc_node_id
		FROM		td_dc_node_vw n
		WHERE		parent_node = 519435
	</cfquery>
	<!--- Intervention Status --->
	<cfquery datasource="tdweb" name="me.qInterventionStatus">
		SELECT	td_dc_node_id
		FROM		td_dc_node_vw n
		WHERE		parent_node = 519434
	</cfquery>

	<cfset Randomize(Right(Form.generation, 8))>

	<cfif IsDefined("Form.submitButton") AND ArrayLen(me.aErrors) 
	      EQ 0>
	
		<!--- Prepare a structure to keep track of some stats --->
		<cfset me.results = {}>
		<cfset me.results.intervention_type = {}>
		<cfset me.results.activities = 0>
		<cfset me.results.reasons = 0>
		<cfset me.results.outcomes = 0>
	
		<cfset me.timeStart = GetTickCount()>
	
		<cfloop from="1" to="#Form.numIntsToCreate#" index="me.idx">
			<!--- Set up intervention structure --->
			<cfset me.int = {}>
			<cfset me.randRow = RandRange(1, me.qUsers.RecordCount)>
			<cfset me.int.u = me.qUsers.td_user_id[me.randRow]>
			<cfset me.int.dv = DateFormat(Now(), "mm/dd/yyyy ") & TimeFormat(Now(), "HH:mm:ss")>
			<cfset me.int["517881"] = "#me.int.u#^#UCase(me.qUsers.last[me.randRow])#, #UCase(me.qUsers.first[me.randRow])#">
			<cfset me.int["517455"] = "now^#RandRange(0,59)#^nn">
		
			<cfset me.randRow = RandRange(1, me.qInterventionTypes.RecordCount)>
			<cfset me.int["519053"] = me.qInterventionTypes.int_type[me.randRow]>
			<cfset me.intervention_type = me.int["519053"]>
			<cfif me.intervention_type EQ me.CLINICAL_ACTIVITY_INT>
				<!--- Give the intervention some clinical activites --->
				<cfset me.int["519067"] = "">
				<cfloop condition="ListLen(me.int['519067']) LT RandRange(1,me.maxActivities)">
					<cfset me.randRow = RandRange(1, me.qClinicalActivities.RecordCount)>
					<cfset me.clinAct = me.qClinicalActivities.td_dc_node_id[me.randRow]>
					<cfif NOT ListFind(me.int["519067"], me.clinAct)>
						<cfset me.int["519067"] = ListAppend(me.int["519067"], me.clinAct)>
					</cfif>
				</cfloop>
				<cfset me.results.activities = me.results.activities + ListLen(me.int["519067"])>
			<cfelseif me.intervention_type EQ me.GENERAL_INT>
				<!--- Reasons --->
				<cfset me.int["517909"] = "">
				<cfloop condition="ListLen(me.int['517909']) LT RandRange(1,me.maxActivities)">
					<cfset me.randRow = RandRange(1, me.qReasons.RecordCount)>
					<cfset me.clinAct = me.qReasons.td_dc_node_id[me.randRow]>
					<cfif NOT ListFind(me.int["517909"], me.clinAct)>
						<cfset me.int["517909"] = ListAppend(me.int["517909"], me.clinAct)>
					</cfif>
				</cfloop>
				<cfset me.results.reasons = me.results.reasons + ListLen(me.int["517909"])>
				<!--- outcomes --->
				<cfset me.int["517910"] = "">
				<cfloop condition="ListLen(me.int['517910']) LT RandRange(1,me.maxActivities)">
					<cfset me.randRow = RandRange(1, me.qOutcomes.RecordCount)>
					<cfset me.clinAct = me.qOutcomes.td_dc_node_id[me.randRow]>
					<cfif NOT ListFind(me.int["517910"], me.clinAct)>
						<cfset me.int["517910"] = ListAppend(me.int["517910"], me.clinAct)>
					</cfif>
				</cfloop>
				<cfset me.results.outcomes = me.results.outcomes + ListLen(me.int["517910"])>
			</cfif>
			<cfset me.int["517948"] = me.qFollowUpStatus.td_dc_node_id[RandRange(1, 
			                                                                     me.qFollowUpStatus.RecordCount)]>
			<cfset me.int["517949"] = me.qInterventionStatus.td_dc_node_id[RandRange(1, 
			                                                                         me.qInterventionStatus.RecordCount)]>
			<cfset me.patIndex = RandRange(1, me.qPatients.RecordCount)>
			<cfset me.int["517876"] = me.qPatients.td_patient_id[me.patIndex]>
		
			<cfif me.dbVersion GT 3><!--- add institution/location if 4.0 or higher --->
				<cfset me.int["527630"] = me.qPatients.td_location_id[me.patIndex]>
				<cfset me.int["527629"] = me.qPatients.td_institution_id[me.patIndex]>
			</cfif>
			<cfset me.int["519068"] = "Auto Populate: (#Form.generation#:#me.idx#)">
			<cfset me.int["519073"] = "Team Comments for #Form.generation#:#me.idx#">
			<cfset me.int["517454"] = "Comments for #Form.generation#:#me.idx#">
		
			<!--- intervention date --->
			<!--- SEE REASONS BELOW FOR HAVING COMMENTED THIS PART OUT.
			<cfset int_date = DateAdd("s",0-RandRange(0,numSecsTimeRange),enddate)>
			<cfset int["528170"] = DateFormat(int_date,"mm/dd/yyyy ") & TimeFormat(int_date,"HH:mm:ss")> --->
			<cfsavecontent variable="me.xmlDoc">
			<cfoutput>
			<cfxml variable="me.interventionXML">
				<o l="Auto" u="#me.int.u#" c="517390" s="1" dv="#me.int.dv#" id="">
					<cfloop collection="#me.int#" item="me.key">
						<cfif IsNumeric(me.key)><!--- We've got ourselves a node id here --->
							<cfif IsArray(me.int[me.key])>
								<cfloop from="1" to="#ArrayLen(me.int[me.key])#" index="me.i">
									<v id="#me.key#">#me.int[me.key][me.i]#</v>
								</cfloop>
							<cfelse>
								<v id="#me.key#">#me.int[me.key]#</v>
							</cfif>
						</cfif>
					</cfloop>
				</o>
			</cfxml>
			</cfoutput>
			</cfsavecontent>
			<cfset me.xmlInt = '<o l="Palm" u="108" c="517390" s="1" dv="05/04/2007 11:16:23" id=""><v id="517881">108^WINTER, CHAD</v><v id="517455">now^5^nn</v><v id="519068">desc</v><v id="517909">518703</v><v id="517910">518782</v><v id="519073">Team Comments</v><v id="517454">Comments</v><v id="520179">0</v><v id="517948">519437</v><v id="517949">519439</v><v id="517876">992</v><v id="519053">523993</v></o>'>
			<!--- 520179: Other costs --->
			<cfset me.xmlInt = ToString(me.interventionXML)>
		
			<cfstoredproc procedure="td_dc_data_pkg.parseXML" datasource="tdweb">
			
				<cfprocparam type="out" variable="me.spDCDO" value="0" cfsqltype="CF_SQL_NUMERIC"/>
				<cfprocparam type="in" value="#me.xmlInt#" cfsqltype="CF_SQL_VARCHAR"/>
				<cfprocparam type="out" variable="me.spError" cfsqltype="CF_SQL_VARCHAR"/>
			</cfstoredproc>
		
			<cfif me.spDCDO EQ 0 OR me.spError NEQ 0>
				<cfset ArrayAppend(me.aErrors, "dataowner: #me.spDCDO#; error: #me.spError#")>
			<cfelse>
				<!---
				    <cflunacy>
				
				    This is where each intervention manually has its date/time created updated.
				    It was originally done above by updating a new node in the intervention model (528170).  
				Then
				 all of
				    the api in the database handled everything.
				
				    Supposedly, we're doing it this way to keep things simple.
				    And really, it is rather simple.  But now the intervention generator has a different way of
				    "backdating" interventions than the future (and, mind you, requested) intervention wizard 
				will.
				
				--->
				<cfset me.int_date = DateAdd("s", 0 - RandRange(0, me.numSecsTimeRange), Form.enddate)>
				<cfquery datasource="tdweb" name="me.qNewIntervention">
					SELECT	a.td_intervention_id
					FROM		td_intervention a, td_dc_dataowner b
					WHERE		b.td_dc_dataowner_id = #me.spDCDO#AND b.link_id = a.td_intervention_id
				</cfquery>
			
				<cfquery datasource="tdweb" name="me.qUpdateInterventionDate">
					UPDATE	td_intervention
					SET			created_date = to_date('#DateFormat(me.int_date, "mm/dd/yyyy ") & TimeFormat(me.int_date, 
				                                                                                    "HH:mm:ss")#
					','MM/DD/YYYY HH24:MI:SS'),
					last_update_date = to_date('#DateFormat(me.int_date, "mm/dd/yyyy ") & TimeFormat(me.int_date, 
				                                                                                  "HH:mm:ss")#
					','MM/DD/YYYY HH24:MI:SS')
					WHERE		td_intervention_id = #me.qNewIntervention.td_intervention_id#
				</cfquery>
			
				<!---
				    </cflunacy>
				 --->
			</cfif>
			<!--- Log some details --->
			<cfif NOT StructKeyExists(me.results.intervention_type, me.intervention_type)><!--- Keep track of
                                                                                  
			                                                                                intervention 
   types 
			                                                                                --->
				<cfset me.results.intervention_type[me.intervention_type] = 1>
			<cfelse>
				<cfset me.results.intervention_type[me.intervention_type] = me.results.intervention_type[me.intervention_type] 
				                                                            + 1>
			</cfif>
		</cfloop>
	
		<cfset me.timeEnd = GetTickCount()>
		<cfset me.timeTotalSecs = (me.timeEnd - me.timeStart) / 1000>
	
		<!--- Print the stats we've got available --->
		<cfset ArrayAppend(me.aMessages, "Finished in #me.timeTotalSecs# seconds")>
		<cfif StructKeyExists(me.results.intervention_type, me.CLINICAL_ACTIVITY_INT)>
			<cfset ArrayAppend(me.aMessages, 
			                   "Clinical Activity Alerts: #me.results.intervention_type[me.CLINICAL_ACTIVITY_INT]#")>
			<cfset ArrayAppend(me.aMessages, "&nbsp;&nbsp;Activities: #me.results.activities#")>
		</cfif>
		<cfif StructKeyExists(me.results.intervention_type, me.GENERAL_INT)>
			<cfset ArrayAppend(me.aMessages, "General Alerts: #me.results.intervention_type[me.GENERAL_INT]#")>
			<cfset ArrayAppend(me.aMessages, "&nbsp;&nbsp;Reasons: #me.results.reasons#")>
			<cfset ArrayAppend(me.aMessages, "&nbsp;&nbsp;Outcomes: #me.results.outcomes#")>
		</cfif>
	</cfif>
	<cfquery datasource="tdweb" name="me.qUserGroup">
		SELECT		group_name, td_group_id
		FROM			td_group
		ORDER BY	group_name
	</cfquery>

	<cfquery datasource="tdweb" name="me.qRosters">
		SELECT		r.td_roster_id, r.roster_name || '-(' || u.user_name || ')' AS roster_display
		FROM			td_roster r
		JOIN			td_user u
		ON r.td_user_id = u.td_user_id
		ORDER BY	UPPER(roster_display)
	</cfquery>

	<!--- new generation seed so that we can start fresh. --->
	<cfset Form.generation = GetTickCount()>

</cfcomponent>