// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require bootstrap-table
//= require moment
//= require moment/fr.js
//= require fullcalendar
//= require scheduler.min
//= require calendars
//= require bootstrap-datetimepicker
//= require pickers
//= require dragula
//= require groups

$(function () {
  $('[data-toggle="tooltip"]').tooltip()
})

// Helper function for select + filter tables
// Submitting with no filter works well, but filtering messes up the 'selected_registrations[]' array.
// Here we fill a hidden input with actual selected rows before sending the form
function setupSelectTable(tableId, buttonContainerId, fieldId) {
  var table = $(tableId);
  var button = $(buttonContainerId).find("button");
  var input = $(fieldId);
  button.click(function(e) {
    var selected = table.bootstrapTable('getAllSelections');
    var selected_id = [];
    $.each(selected, function(arrayId, elem) {
      selected_id.push(elem._id);
    });
    input.val(selected_id.join(","));
  });
}
