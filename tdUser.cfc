<cfcomponent>
	<cffunction name="getFormattedName" 
				access="remote" 
				returntype="String" 
				httpmethod="POST"
				restpath="{id}"
				returnformat="plain" 
				description="Get the formatted name using the database package"
				hint="Get the formatted name using the database package"
				>
		<cfargument name="id" 
					type="numeric" 
					required="true"
					restargname="id" 
					restargsource="Path">
			<cfquery name="getFormattedNameQuery"
						datasource="tdweb"
						maxrows="1"
			>
				select td_nhsn_generator_pkg.get_create_by(#id#) as formattedName from dual	
			</cfquery>
		<cfreturn getFormattedNameQuery.formattedName[1]>
	</cffunction>
	
	<cffunction name="getStatusName"
				access="remote"
				returntype="String"
				httpmethod="GET"
				restpath="{id}"
				returnformat="plain"
				description="Get the status name for a td_status_id"
				hint="Get the status name for a td_status_id"
				>
		<cfargument name="id" 
					type="numeric" 
					required="true"
					restargname="id" 
					restargsource="Path">
		<cfquery name="getStatusName"
					datasource="tdweb"
					maxrows="1"
					>
					select status_desc from td_status where td_status_id = #id#
		</cfquery>
		<cfreturn getStatusName.status_desc[1]>
	</cffunction>
	
	<cffunction name="getSurgery" 
				access="remote" 
				returntype="string" 
				returnformat="plain" 
				produces="JSON"
				consumes="JSON" 
				httpmethod="GET"
				description="Get the surgery data and return results as JSON for bootstrap-tables" 
				hint="Get the surgery data and return results as JSON for bootstrap-tables">
		<cfargument name="offset" 
					type="numeric" 
					required="false"
					restargname="offset" 
					restargsource="query"
					default="0" >
		<cfargument name="limit" 
					type="numeric" 
					required="false"
					restargname="offset" 
					restargsource="limit"
					default="10" >
		<cfquery name="getSurgeryQuery" datasource="tdweb">
			SELECT td_surgery_id,
						primary_proc_code,
						primary_proc_desc,
						surgery_start_date_time,
						surgery_start_time,
						surgery_stop_date_time,
						surgery_stop_time,
						primary_surgeon_codes,
						primary_surgeons,
						primary_anesthesiologist_code,
						primary_anesthesiologists,
						asa_class,
						emergency,
						endoscope,
						general_anesthesia,
						implant,
						multiple_procedures,
						nhsn_category,
						nnis_category,
						operating_room,
						outpatient,
						primary_closure,
						primary_proc_modifier,
						risk_index,
						scheduled_proc_date,
						security_control,
						surgery_service,
						td_concept_id,
						td_encounter_id,
						td_institution_id,
						td_location_id,
						td_message_id,
						td_patient_id,
						td_service_id,
						td_status_id,
						transplant,
						transplant_autologous,
						trauma,
						wound_class
						last_update_by,
						last_update_date
				  FROM 	td_surgery
				  where rownum > #Arguments.offset#
				  and rownum <= #Arguments.offset + Arguments.limit# 
		</cfquery>
		<cfset var cols = getMetadata(getSurgeryQuery)>
		<cfset var colList = "">
		<cfloop from="1" to="#arrayLen(cols)#" index="x">
			<cfset colList = listAppend(colList, cols[x].name)>
		</cfloop>

		<cfset dataSet = "[" >
		<cfloop query="getSurgeryQuery" >
			<!--- Because CF structs don't keep the order, we cheat and use a string append --->
			<cfset thisRow = "{" >
			<cfloop list="#colList#" index="anotherName">
				<!--- After the first item has been added, precede the next with a comma --->
				<cfif Len(thisRow) GT 1>
					<cfset thisRow &= ",">
				</cfif>
				<!--- Add the column to the list --->
				<cfset thisRow &= '"#anotherName#":"#getSurgeryQuery[anotherName][getSurgeryQuery.currentRow]#"'>
			</cfloop>
			<!--- Close off the row --->
			<cfset thisRow &= "}">
			<!--- If we've already added a row, we need to add a comma before the next one --->
			<cfif Len(dataSet) GT 1>
				<cfset dataSet &= ",">
			</cfif>
			<!--- Add the row to the data set --->
			<cfset dataSet &= thisRow>
		</cfloop>
		<!--- Close off the data set --->
		<cfset dataSet &= "]" >
		<!--- Add the row count and rows to the data to be returned --->
		<cfset returnData = '{"total": #getSurgeryQuery.recordcount#,"rows": #dataSet#}'>
		<cfreturn returnData>
	</cffunction>
</cfcomponent>