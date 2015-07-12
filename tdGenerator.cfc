<cfcomponent>
	<cfset This["infectionGenerator"] = {}>
	<!--- Make an alias that's much shorter and easier to type... --->
	<cfset me = This.infectionGenerator>

	<!--- Set some defaults... --->
	<cfset me.END_DATE = DateFormat(Now(), 'yyyy-mm-dd')>
	<cfset me.START_DATE = DateFormat(DateAdd('yyyy', -1, Now()), 'yyyy-mm-dd')>
	<cfset me.getInfectionClasses = getInfectionClasses>
	<cfset me.getEventTypesForClass = getEventTypesForClass>
	<cfset me.getCriteriaByCode = getCriteriaByCode>
	<cfset me.getCriteriaByCode = getCriteriaInfo>
	<!--- Get the institution information --->
	<cfquery name="me.institutionQuery" datasource="tdweb">
		SELECT *
		FROM td_institution
	</cfquery>
	<!--- Query for procedure codes --->
	<cfquery name="me.procedureQuery" datasource="tdweb">
		SELECT procedure_code, specific_procedure_codes
		FROM td_nhsn_procedure_code
		where td_status_id = 1
	</cfquery>
	<!--- Infection type query --->
	<cfquery name="me.infectionQuery" datasource="tdweb">
		SELECT infection_key
		FROM TABLE(td_generate_data_pkg.get_infection_type_list())
	</cfquery>

	
	<!--- Get the list of infection types --->
		<cffunction name="getListOfInfectionTypes" access="remote" returntype="Struct" httpmethod="GET"
	            restpath="{id}" description="Get a list of infection types" 
	            hint="Get a list of infection types">
		<cfstoredproc procedure="td_infection_generator_pkg.get_infection_type_list" datasource="tdweb">
			<cfprocresult name="getInfectionTypesQueryResult">
		</cfstoredproc>
		<cfreturn getInfectionTypesQueryResult>
	</cffunction>
	
	<!--- Get the infection data for a given infection type --->
	
	<cffunction name="getInfectionData" access="remote" returntype="String" httpmethod="GET"
	            respath="{id}" description="Get the infection data for the infection type" 
	            hint="Get the infection data for the infection type">
		<cfdump var="id: /#id#/" abort="false">
		<cfquery name="getInfectionDataQueryResult" datasource="tdweb">
			select td_infection_generator_pkg.get_infection_data(<cfqueryparam value="#id#" 
		              cfsqltype="CF_SQL_VARCHAR">
			) as data from dual
		</cfquery>
		<cfreturn getInfectionDataQueryResult.data>
	</cffunction>
	
	<!--- Generate surgeries --->
	
	<cffunction name="generateSurgeriesForInstitution" access="remote" returntype="string" 
	            returnformat="JSON" consumes="JSON" httpmethod="POST" 
	            description="Generate surgeries for this institution" 
	            hint="Generate surgeries for this institution">
		<!--- The reset output, makes sure we don't get any output from prior runs --->
		
		<cfstoredproc datasource="tdweb" procedure="td_generate_data_pkg.reset_output"/>
		<!---     To turn on debug, change the following debug flags
		
		         This is per session, so could be done as a separate call
		         and/or function
		--->
		<cfquery datasource="tdweb">
			begin
			TD_SURGERY_GENERATOR_PKG.P_DEBUG := '#Arguments.p_debug#';
			TD_GENERATE_DATA_PKG.P_DEBUG := '#Arguments.p_debug#';
			end;
		</cfquery>
		<!--- Loop through the institutions --->
		<cfloop list="#Arguments.p_inst_num#" index="p_inst">
			<!--- Call the create surgeries method for this institution --->
			<cfstoredproc datasource="tdweb" procedure="td_surgery_generator_pkg.create_surgeries">
				<cfprocparam cfsqltype="CF_SQL_NUMERIC" type="IN" value="#p_inst#" dbvarname="p_inst_num">
				<cfprocparam cfsqltype="CF_SQL_VARCHAR" type="IN" value="#p_procedures#" 
				             dbvarname="p_procedure_list">
				<cfprocparam cfsqltype="CF_SQL_DATE" type="IN" value="#Arguments.p_start_date#" 
				             dbvarname="p_start_date">
				<cfprocparam cfsqltype="CF_SQL_DATE" type="IN" value="#Arguments.p_end_date#" 
				             dbvarname="p_end_date">
				<cfprocparam cfsqltype="CF_SQL_VARCHAR" type="IN" value="#Arguments.p_include_no_discharge#" 
				             dbvarname="p_include_no_discharge">
				<cfprocparam cfsqltype="CF_SQL_NUMERIC" type="IN" value="#Arguments.p_count#" 
				             dbvarname="p_count">
				<cfprocparam cfsqltype="CF_SQL_NUMERIC" type="IN" value="#Arguments.p_min_los#" 
				             dbvarname="p_min_los">
				<cfprocparam cfsqltype="CF_SQL_NUMERIC" type="IN" value="#Arguments.p_min_lab#" 
				             dbvarname="p_min_lab">
				<cfprocparam cfsqltype="CF_SQL_VARCHAR" type="IN" value="#Arguments.p_require_organism#" 
				             dbvarname="p_require_organism">
				<cfprocparam cfsqltype="CF_SQL_NUMERIC" type="IN" value="#Arguments.p_surg_code_percent#" 
				             dbvarname="p_surg_code_percent">
			</cfstoredproc>
		</cfloop>
		<!--- Get the output from the above calls --->
		<cfquery datasource="tdweb" name="dbmsOutputQuery">
			select * from table(TD_GENERATE_DATA_PKG.GET_OUTPUT)
		</cfquery>
		<!--- Serialize the output as JSON and return --->
		<cfreturn serializeJSON(dbmsOutputQuery)>
	
	</cffunction>
	
	<!--- Generate infections --->
	
	<cffunction name="generateInfections" access="remote" returntype="string" returnformat="JSON"
	            consumes="JSON" httpmethod="POST" description="Generate infection documents" 
	            hint="Generate infection documents">
		<!--- First reset the output so we don't get any stale messages --->
		
		<cfstoredproc datasource="tdweb" procedure="td_generate_data_pkg.reset_output">
		</cfstoredproc>
		<!---     To turn on debug, change the following debug flags
		
		         This is per session, so could be done as a separate call
		         and/or function
		--->
		<cfquery datasource="tdweb">
			begin
			TD_INFECTION_GENERATOR_PKG.P_DEBUG := '#Arguments.p_debug#';
			TD_GENERATE_DATA_PKG.P_DEBUG := '#Arguments.p_debug#';
			end;
		</cfquery>
		<!--- Loop through the institutions --->
		<cfloop list="#Arguments.p_inst_num#" index="p_inst">
			<!--- Create institutions using the list we got from the form --->
			<cfstoredproc datasource="tdweb" 
			              procedure="td_infection_generator_pkg.create_infections_from_list">
				<cfprocparam cfsqltype="CF_SQL_VARCHAR" type="IN" value="#Arguments.p_infection_list#" 
				             dbvarname="p_infection_list">
				<cfprocparam cfsqltype="CF_SQL_DATE" type="IN" value="#Arguments.p_start_date#" 
				             dbvarname="p_start_date">
				<cfprocparam cfsqltype="CF_SQL_DATE" type="IN" value="#Arguments.p_end_date#" 
				             dbvarname="p_end_date">
				<cfprocparam cfsqltype="CF_SQL_NUMERIC" type="IN" value="#Arguments.p_min_infections#" 
				             dbvarname="p_min_infections">
				<cfprocparam cfsqltype="CF_SQL_NUMERIC" type="IN" value="#Arguments.p_max_infections#" 
				             dbvarname="p_max_infections">
				<cfprocparam cfsqltype="CF_SQL_VARCHAR" type="IN" value="#Arguments.p_require_organism#" 
				             dbvarname="p_require_organism">
				<cfprocparam cfsqltype="CF_SQL_VARCHAR" type="IN" value="#Arguments.p_require_location#" 
				             dbvarname="p_require_location">
				<cfprocparam cfsqltype="CF_SQL_VARCHAR" type="IN" value="#Arguments.p_require_hai#" 
				             dbvarname="p_require_hai">
				<cfprocparam cfsqltype="CF_SQL_VARCHAR" type="IN" value="#Arguments.p_require_no_surv#" 
				             dbvarname="p_require_no_surv">
				<cfprocparam cfsqltype="CF_SQL_NUMERIC" type="IN" value="#p_inst_num#" dbvarname="p_inst_num">
			</cfstoredproc>
		</cfloop>
		<!--- Get the output from the above procedure calls
		        This could be done as a separate AJAX call too
		--->
		<cfquery datasource="tdweb" name="dbmsOutputQuery">
			select * from table(TD_GENERATE_DATA_PKG.GET_OUTPUT)
		</cfquery>
		<!--- Serialize the output as JSON and return it --->
		<cfreturn serializeJSON(dbmsOutputQuery)>
	</cffunction>
	
	<cffunction name="getInfectionClasses" access="remote" httpmethod="GET" restpath="{code}"
	            description="Get a list of infection classes" hint="Get a list of infection classes">
		<cfquery datasource="tdweb" name="infectionClassQuery">
			SELECT a.code, a.description, a.td_status_id, a.create_by, a.create_date, a.last_update_by, 
			a.last_update_date
			FROM td_inf_document_code_desc a
			WHERE parent_code = 'infxClass'
			AND UPPER (code) LIKE '%' || UPPER (<cfqueryparam value="#code#" cfsqltype="CF_SQL_VARCHAR">
			) || '%'
			AND EXISTS (SELECT 1
			FROM td_nhsn_event b
			WHERE (UPPER (a.code) || '_' || UPPER (b.event_type))
			IN (SELECT UPPER (c.code)
			FROM td_inf_document_code_desc c
			WHERE UPPER (c.parent_code) = UPPER (a.code)))
			ORDER BY a.display_order
		</cfquery>
		<cfreturn infectionClassQuery>
	</cffunction>
	
	<cffunction name="getEventTypesForClass" access="remote" httpmethod="GET" restpath="{infClass}"
	            description="Get a list of event types for a given class" 
	            hint="Get a list of event types for a given class">
		<cfquery datasource="tdweb" name="getEventTypesForClassQuery">
			SELECT event.td_nhsn_event_id, doc.code as event_code, doc.parent_code, event.event_type, 
			event.code_system, event.code as nhsn_code, event.last_update_by, event.last_update_date, 
			event.td_status_id
			FROM td_nhsn_event event
			JOIN td_inf_document_code_desc doc
			ON UPPER (doc.code) LIKE
			('%' || UPPER ( <cfqueryparam value="#infClass#" cfsqltype="CF_SQL_VARCHAR">
			|| '_' || UPPER (event.event_type)))
		</cfquery>
		<cfreturn getEventTypesForClassQuery>
	</cffunction>
	
	<cffunction name="getCriteriaByCode" access="remote" httpmethod="GET" restpath="{code}/{subtype}"
	            description="Get criteria by code" hint="Get criteria by code">
	            <cfargument name="code" required="false" restargname="code" default="" >
	            <cfargument name="subtype" required="false" restargname="subtype" default="">
	            <cfargument name="eventType" required="false" restargname="eventtype" default="">
		<cfquery datasource="tdweb" name="getCriteriaByCodeQuery">
			SELECT doctypes.code AS code,
			subtype.code AS subtype,
			event.event_type,
			event.event_description,
			criteria.*
			FROM (SELECT code
				FROM td_inf_document_code_desc
				WHERE parent_code = 'infxClass') doctypes,
				(SELECT *
					FROM td_inf_document_code_desc
					WHERE parent_code IN (SELECT code
						FROM td_inf_document_code_desc
						WHERE parent_code = 'infxClass')) subtype,
				td_nhsn_event event,
				td_nhsn_event_criteria criteria
			WHERE	doctypes.code = subtype.parent_code
				AND LOWER (doctypes.code || '_' || event.event_type) = subtype.code
				AND event.td_nhsn_event_id = criteria.td_nhsn_event_id
				AND LOWER (doctypes.code) LIKE '%' || LOWER (<cfqueryparam value="#Arguments.code#" cfsqltype="CF_SQL_VARCHAR">) || '%'
				AND LOWER (subtype.code) LIKE '%' || LOWER (<cfqueryparam value="#Arguments.subtype#" cfsqltype="CF_SQL_VARCHAR">) || '%'
				AND LOWER (event.event_type) LIKE '%' || LOWER(<cfqueryparam value="#Arguments.eventType#" cfsqltype="CF_SQL_VARCHAR">) || '%'
		</cfquery>
		<cfreturn getCriteriaByCodeQuery>
	</cffunction>
	
	<cffunction name="getRules" access="remote" httpmethod="GET" restpath="{td_nhsn_criteria_ids}"
	            description="Get a list of event types for a given class" 
	            hint="Get a list of event types for a given class">
		<cfargument name="td_nhsn_criteria_ids" required="false" restargname="td_nhsn_criteria_ids">
		
		<cfquery datasource="tdweb" name="getRulesQuery">
			SELECT td_nhsn_criteria_id, criteria, min_criteria_count, death_criteria, last_update_by, last_update_date, td_status_id
			  FROM td_nhsn_criteria
			 WHERE td_nhsn_criteria_id IN (SELECT COLUMN_VALUE
											FROM TABLE (TD_UTIL_PKG.CSL_TO_NUMBER_TABLE (<cfqueryparam value="#Arguments.td_nhsn_criteria_ids#" cfsqltype="CF_SQL_VARCHAR">)))
		</cfquery>
		<cfif len(trim(Arguments.td_nhsn_criteria_ids))>
		<cfreturn getRulesQuery>
		</cfif>
		<cfquery datasource="tdweb" name="getAllRulesQuery">
			SELECT * 
			  FROM td_nhsn_criteria
		</cfquery>
		<cfreturn getAllRulesQuery>
	</cffunction>
	
		<cffunction name="getCriteriaInfo" access="remote" httpmethod="GET" restpath="{code}"
	            description="Get a list of event types for a given class" 
	            hint="Get a list of event types for a given class">
		<cfargument name="code" required="false" restargname="code">
		
		<cfif find("|", Arguments.code) GT 0> 
		<cfquery datasource="tdweb" name="getCriteriaInfoQuery">
			WITH pattern_list
				AS (SELECT '%' || COLUMN_VALUE AS pattern
					FROM TABLE (TD_UTIL_PKG.csl_to_varchar_table (<cfqueryparam value="#Arguments.code#" cfsqltype="CF_SQL_VARCHAR">, '|')))
					SELECT td_inf_document_code_desc.*
					  FROM td_inf_document_code_desc
						JOIN pattern_list ON upper(code) LIKE upper(pattern)
		</cfquery>
		<cfreturn getCriteriaInfoQuery>
		</cfif>
		<cfquery datasource="tdweb" name="getAllCriteriaInfo">
					SELECT td_inf_document_code_desc.*
					  FROM td_inf_document_code_desc
		</cfquery>
		<cfreturn getAllCriteriaInfo>
	</cffunction>
</cfcomponent>