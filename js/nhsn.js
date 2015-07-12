/**
 * Ajax lookup of names (synchronous)
 * 
 * TODO: modify the queries to handle this lookup so we don't do so many calls
 *       just to find the user name - also shouldn't need to be synchronous
 *       
 * @param {string} value of name field
 * @returns {string} formatted name
 */
function getFormattedNameByID(value) {
	value = value.trim();
	var formattedName = value;
	console.log("UserId: " + value);
	var begURL = 'tdUser.cfc?method=getFormattedName\&id=';
	jQuery.ajax({
		url: begURL + value,
		type:'GET',
		success: function (data) {
		console.log("Formatted name: " + data);
		formattedName = data;
		}, 
		async: false
	}).error(function(xhr){
				console.log("getFormattedNameByID errored out");
				formattedName = "Unknown";
				$('#results').html(xhr.responseText)
				});
	return formattedName;
}
;

var surgeryData;

function getSurgeryData(offset, limit){
	console.log('getSurgeryData');
	var begURL = 'tdUser.cfc';
			var postData = {
						method: 'getSurgeryData',
						p_limit : (limit ? limit : 10),
						p_offset: (offset ? offset : 0),
						p_debug: $('#debugButton').data('debug') ? 'Y' : 'N'
					};
	jQuery.ajax({
		url: begURL,
		type:'GET',
		success: function (data) {
			console.log("return data: " + data);
			surgeryData = data;
		}, 
	}).error(function(xhr){
				console.log("SurgeryData errored out");
				surgeryData = "Unknown";
				$('#results').html(xhr.responseText)
				});
}
;

/**
 * Status lookup (calls the getStatusName web service)
 * 
 * TODO: cache the values so we don't call the web service on every lookup 
 *      (especially since there are only a few statuses). Alternative is to
 *      change the query to return the value we want to display which is 
 *      probably faster anyway.
 * 
 * @param {type} value
 * @returns {data}
 */
function getStatusByID(value) {
	var statusName = value.trim();
	jQuery.ajax({
		url: 'tdUser.cfc?method=getStatusName\&id=' + statusName,
		success: function (data) {
			console.log("StatusID: " + data);
			statusName = data;
		},
		async: false
	}).error(function(xhr){
				console.log("error");
				$('#results').html(xhr.responseText)
				});
	return statusName;
}
;

/**
 * Ajax lookup of names (synchronous)
 * 
 * @param {type} value
 * @returns {data|String}
 */
function create_byFormatter(value) {
    return getFormattedNameByID(value);
}
;
/**
 * Name lookup for last update by
 * @param {type} value
 * @returns {String|data}
 */
function last_update_byFormatter(value) {
    return create_byFormatter(value);
}
;
/**
 * Status lookup for td_status_id field
 * 
 * @param {type} value
 * @returns {data}
 */
function td_status_idFormatter(value) {
    return getStatusByID(value);
}
;
/**
 * Date trimmer ...
 * 
 * @param {type} value
 * @returns {unresolved}
 */
function create_dateFormatter(value) {
    return  value.match(/\d+?-\d+?-\d+?\w+?/);
    ;
}
;

/**
 * Last update formatter
 * @param {type} value
 * @returns {unresolved}
 */
function last_update_dateFormatter(value) {
    return create_dateFormatter(value);
}
;

/**
 * Code field formatter
 * @param {type} value
 * @returns {unresolved}
 */
function codeFormatter(value) {
	value = value.trim();
	return '<a href="eventtypes.cfm?infClass=' + value + '">' + value + '</a>'
}
;

/**
 * Event code formatter
 * @param {type} value
 * @returns {unresolved}
 */
function parent_codeFormatter(value) {
	return codeFormatter(value);
}
;

/**
 * Ajax generate infections
 */
function generateInfections() {
	if ($('#generateForm')[0].checkValidity()) {
		$('input,select').each(function(index, element){
			if(this.checkValidity()){
				// Reset to not bad
				$(this).closest('.form-group').removeClass('has-error');
				// multi-select button needs to turn dangerous ...
				$(this).next().find('button').removeClass('btn-danger').addClass('btn-default');
			}
		});
		$('#results').html('<img src="images/ajax-loader.gif" class="center-block"/>');
		$('inputData').html('<img src="images/ajax-loader.gif" />');
		var begURL = 'tdGenerator.cfc';
		var institutions = -1;
		if ($('#p_inst_num').val()){
			institutions = $('#p_inst_num').val().join(',');
		}
		var postData = {
						method: 'generateInfections',
						p_inst_num : institutions,
						p_infection_list: $('#p_infection_list').val().join(','),
						p_start_date : $('#p_start_date').val(),
						p_end_date : $('#p_end_date').val(),
						p_min_infections : $('#p_min_infections').val(),
						p_max_infections :  $('#p_max_infections').val(),
						p_require_organism: $('#p_require_organism').is(':checked') ? 'Y' : 'N',
						p_require_location: $('#p_require_location').is(':checked') ? 'Y' : 'N',
						p_require_hai: $('#p_require_hai').is(':checked') ? 'Y' : 'N',
						p_require_no_surv: $('#p_require_no_surv').is(':checked') ? 'Y' : 'N',
						p_debug: $('#debugButton').data('debug') ? 'Y' : 'N'
					};
		$('#inputData').html(JSON.stringify(postData, null, 4));

		jQuery.ajax({
			type: 'POST',
			url: begURL,
			data: postData,
			dataType: 'json',
			success: function (data) {
				console.log("POST done");
				var myData = data.DATA;
				var outString = "<h3>Results</h3>";
				$(myData).each(function(index, element){
					outString = outString + element + '<br />';
				})
				$('#results').html(outString);
			}
		}).error(function(xhr){console.log("error");
		$('#results').html(xhr.responseText)});
	} else {
		$('input,select').each(function(index, element){
			if(this.checkValidity()){
				// Reset to not bad
				$(this).closest('.form-group').removeClass('has-error');
				// multi-select button needs to turn dangerous ...
				$(this).next().find('button').removeClass('btn-danger').addClass('btn-default');
			} else {
				$(this).closest('.form-group').addClass('has-error');
				// multi-select button needs to turn dangerous ...
				$(this).next().find('button').removeClass('btn-default').addClass('btn-danger');
			}
		});
		 return false;
	}
}
;
/**
 * Ajax generate surgeries for institution
 */
function generateSurgeriesForInstitution() {
	if ($('#generateForm')[0].checkValidity()) {
		$('input,select').each(function(index, element){
			if(this.checkValidity()){
				// Reset to not bad
				$(this).closest('.form-group').removeClass('has-error');
				// multi-select button needs to turn dangerous ...
				$(this).next().find('button').removeClass('btn-danger').addClass('btn-default');
			}
		});
		$('#results').html('<img src="images/ajax-loader.gif" class="center-block"/>');
		$('inputData').html('<img src="images/ajax-loader.gif" />');
		var begURL = 'tdGenerator.cfc';
		var postData = {
						method: 'generateSurgeriesForInstitution',
						p_inst_num : $('#p_inst_num').val().join(','),
						p_procedures: $('#p_procedures').val().join(','),
						p_start_date : $('#p_start_date').val(),
						p_end_date : $('#p_end_date').val(),
						p_include_no_discharge: $('#p_include_no_discharge:checked').val() ? 'Y' : 'N',
						p_count: $('#p_count').val(),
						p_min_los: $('#p_min_los').val(),
						p_min_lab: $('#p_min_lab').val(),
						p_require_organism: $('#p_require_organism:checked').val() ? 'Y' : 'N',
						p_surg_code_percent: parseInt($('#p_surg_code_percent').val()),
						p_debug: $('#debugButton').data('debug') ? 'Y' : 'N'
					};
		$('#inputData').html(JSON.stringify(postData, null, 4));

		jQuery.ajax({
			type: 'POST',
			url: begURL,
			data: postData,
			dataType: 'json',
			success: function (data) {
				console.log("POST done");
				var myData = data.DATA;
				var outString = "<h3>Results</h3>";
				$(myData).each(function(index, element){
					outString = outString + element + '<br />';
				})
				$('#results').html(outString);
			}
		}).error(function(xhr){console.log("error");
		$('#results').html(xhr.responseText)});
	} else {
		$('input,select').each(function(index, element){
			if(this.checkValidity()){
				// Reset to not bad
				$(this).closest('.form-group').removeClass('has-error');
				// multi-select button needs to turn dangerous ...
				$(this).next().find('button').removeClass('btn-danger').addClass('btn-default');
			} else {
				$(this).closest('.form-group').addClass('has-error');
				// multi-select button needs to turn dangerous ...
				$(this).next().find('button').removeClass('btn-default').addClass('btn-danger');
			}
		});
		 return false;
	}
}
;

/**
  * Submit for for intervention maker 
  *
  **/
submitForm = function() {
				var theForm = document.forms["interventionMaker"];
				if (theForm) theForm.submit();
				};

toggleDebug = function(){
	$(this).toggleClass('glyphicon-eye-plus glyphicon-minus')
	$(this).data('debug', !$(this).data('debug'));
	console.log($(this).data('debug'));
}
/**
 * Initialization on ready ...
**/
$(document).ready(function () {
	
	// Turn the multi-select to be multi-select enabled
	$('select.multiselect').multiselect({
		includeSelectAllOption: true,
		 enableFiltering: true,
		 enableCaseInsensitiveFiltering: true,
	});

	// Connect to 'change' event in order to toggle glyphs
	$("[type='checkbox']").change(function () {
		if ($(this).prop('checked')) {
			$(this).prev().addClass('glyphicon-ok-circle');
			$(this).prev().removeClass('glyphicon-unchecked');
		} else {
			$(this).prev().removeClass('glyphicon-ok-circle');
			$(this).prev().addClass('glyphicon-unchecked');
		}
	});
	
	$("#generateSurgeryButton").on('click',generateSurgeriesForInstitution);
	$("#generateInfectionButton").on('click',generateInfections);
	$('form#generateForm').on('submit', function(){return false;});
	$('.nav a[href*="' + document.location.href.match(/[^\/]+$/)[0] + '"]').parent().addClass("active");
	$('#debugButton').on('click', toggleDebug);
	


});
