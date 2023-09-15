import QtQuick 2.7
import QtQuick.Controls 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

DialogPlus {
	id: mainItem
	height: timePicker.visible ? 575 : 500
	width: 550
	
	property alias hideOldDates: datePicker.hideOldDates
	
	property alias showDatePicker : datePicker.visible
	property alias showTimePicker: timePicker.visible
	
	property alias selectedDate: datePicker.selectedDate
	property alias selectedTime: timePicker.selectedTime
	
// ---------------------------------------------------------------------------
	buttons: [
		TextButtonB {
			text: 'ok'

			onClicked: {
				exit({selectedDate: mainItem.selectedDate, selectedTime: mainItem.selectedTime})
			}
		}
	]

	buttonsAlignment: Qt.AlignCenter
	
	//: 'Select date' : Menu title to show select date.
	property string dateTitle: qsTr('dateTimeDialogDate')
	//: 'Select time' : Menu title to show select time.
	property string timeTitle: qsTr('dateTimeDialogTime')
	//: 'Select date and time' : Menu title to show select date and time.
	property string dateTimeTitle: qsTr('dateTimeDialogDateTime')
	title: showDatePicker 
				? showTimePicker
					? dateTimeTitle
					: timeTitle
				: timeTitle
	showCloseCross: true
	// ---------------------------------------------------------------------------
	RowLayout{
		anchors.fill: parent
		DatePicker{
			id: datePicker
			visible: false
			Layout.fillHeight: true
			Layout.fillWidth: true
		}
		TimePicker{
			id: timePicker
			visible: false
			Layout.fillHeight: true
			Layout.fillWidth: true
		}
	}
}
