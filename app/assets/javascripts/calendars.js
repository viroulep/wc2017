// NOTE: across all this file I use 'var', because wkhtmltopdf doesn't like 'let'!

var postEventData = function(event, delta, revertFunc) {
  event_data = {};
  event_data[event.class] = {
    id: event.id,
    start: event.start.format(),
    end: event.end.format(),
  };
  $.ajax({
    url: event.update_url,
    data: event_data,
    type: 'PATCH',
  })
  .fail(function() {
    alert("Failed to update the event, reverting");
    revertFunc();
  });
};

var viewOptions = function(name, numberOfDays) {
  if (name == "fullcomp") {
    var mobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    var defaultViewNav = mobile ? "agenda" : "agendaFourDay";
    var viewAvail = mobile ? "agendaFourDay,agenda" : "listFourDay,agendaFourDay,agenda";
    // see: https://fullcalendar.io/docs/views/Custom_Views/
    return {
      views: {
        agendaFourDay: {
          type: 'agenda',
          duration: { days: numberOfDays },
          buttonText: 'Calendar',
        },
        listFourDay: {
          type: 'list',
          duration: { days: numberOfDays },
          buttonText: 'Printable',
        },
        agenda: {
          buttonText: '1-day calendar',
        },
      },
      defaultView: defaultViewNav,
      header: {
        left: '',
        center: viewAvail,
        right: 'prev,next',
      },
    }
  } else if (name == "fullcomp-list") {
    return {
      views: {
        listFourDay: {
          type: 'list',
          duration: { days: numberOfDays },
          buttonText: 'Printable',
        },
      },
      defaultView: 'listFourDay',
      header: false,
    };
  } else if (name == "day-list") {
    return {
      defaultView: 'list',
      header: false,
    };
  } else {
    // Default is to just display the agenda for the day
    return {
      defaultView: 'agendaDay',
    }
  }
}

var editableCalendarOptions = {
  editable: true,
  eventDrop: postEventData,
  eventResize: postEventData,
}

var commonOptions = function(day, editable) {
  var options = {
    defaultDate: day,
    minTime:'08:00:00',
    maxTime:'20:00:00',
    contentHeight: 'auto',
    aspectRatio: '0.75',
    slotDuration: '00:15:00',
    snapDuration: '00:05:00',
    displayEventEnd: false,
    timeFormat: 'H:mm',
    slotLabelFormat: 'H:mm',
    schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
    eventOrder: "id",
  };
  if(editable) {
    options = Object.assign(options, editableCalendarOptions);
  }
  return options;
}

function setupFullCalendarOn(elemId, day, numberOfDays, viewName, options, editable) {
  var calendarOptions = Object.assign(commonOptions(day, editable), viewOptions(viewName, numberOfDays), options);
  $(elemId).fullCalendar(calendarOptions);
}
