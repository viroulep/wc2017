function setupForm(theForm, groupId) {
  var searchField=theForm.find('.search').first();
  // By default the bootstrap-table search field is created in a separate div,
  // We want it to be part of the first row, and taking the full space.
  searchField.removeClass("pull-right");
  searchField.addClass("clear-margin");
  searchField.find("input").attr("placeholder", "Filter people");
  var searchCell=theForm.find('th.search-cell').first();
  searchCell.append(searchField);

  // Let's add a clear icon to the search field
  var clearIcon = $('<span class="glyphicon glyphicon-remove-circle"></span>');
  var inputField = searchField.find("input");
  clearIcon.on('click', function (){
    inputField.val('');
  });
  searchField.append(clearIcon);
  searchCell.find(".th-inner").remove();

  // And finally a tooltip to the lonely checkbox
  var cbCell = theForm.find("th.bs-checkbox input");
  cbCell.attr("title", "Select all");
  cbCell.data("placement", "top");
  cbCell.data("trigger", "hover");
  cbCell.tooltip();

  var groupTable = theForm.find("table");
  var moveToButton = theForm.find(".action-move-to");
  var inputGroup = theForm.find(".input-group-number");

  theForm.find(".action-move-to").click(function (e) {
    e.preventDefault();
    moveSelectedTo(groupTable, inputGroup);
  });

  theForm.find(".action-reset").click(function (e) {
    e.preventDefault();
    resetSelected(groupTable, groupId);
  });

  theForm.find(".action-submit").click(function (e) {
    e.preventDefault();
    theForm.submit();
  });
}

function resetSelected(tableElem, groupId) {
  var selected = tableElem.bootstrapTable('getAllSelections');
  $.each(selected, function (index, cell) {
    var elem = $("#"+cell._name_id);
    elem.parent().removeClass("warning text-warning");
    elem.find('.new-group-number').empty();
    elem.find('.hidden-group-input').val(groupId);
  });
}

function moveSelectedTo(tableElem, inputElem) {
  var selected = tableElem.bootstrapTable('getAllSelections');
  var newGroup = inputElem.val();
  var newGroupName = inputElem.find(':selected').text();
  var arrowRight = '<i class="fa fa-arrow-right"></i> ';
  if (!/^\+?[1-9][\d]*$/.test(newGroup)) {
    alert("Group " + newGroup + " is not a positive Integer");
    return;
  }

  $.each(selected, function (index, cell) {
    var elem = $("#"+cell._name_id);
    elem.parent().addClass("warning text-warning");
    elem.find('.new-group-number').html(arrowRight + newGroupName);
    elem.find('.hidden-group-input').val(newGroup);
  });
}
