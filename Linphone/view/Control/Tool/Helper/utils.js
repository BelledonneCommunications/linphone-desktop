/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
 *
 * This file is part of linphone-desktop
 * (see https://www.linphone.org).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
// =============================================================================
// Contains many common helpers.
// =============================================================================

.pragma library

.import QtQuick as QtQuick
.import Linphone as Linphone

// =============================================================================
// Constants.
// =============================================================================


var SCHEME_REGEX = new RegExp('^[^:]+:')

// =============================================================================
// QML helpers.
// =============================================================================

function buildCommonDialogUri (component) {
  return 'qrc:/ui/modules/Common/Dialog/' + component + '.qml'
}
function buildCommonUri (component, subComponent) {
  return 'qrc:/ui/modules/Common/'+subComponent+'/' + component + '.qml'
}

function buildLinphoneDialogUri (component) {
  return 'qrc:/ui/modules/Linphone/Dialog/' + component + '.qml'
}

function buildAppDialogUri (component) {
  return 'qrc:/ui/views/App/Dialog/' + component + '.qml'
}

// -----------------------------------------------------------------------------

// Destroy timeout.
function clearTimeout (timer) {
  timer.stop() // NECESSARY.
  timer.destroy()
}

// -----------------------------------------------------------------------------

function createObject (source, parent, options) {
  if (options && options.isString) {
    var object = Qt.createQmlObject(source, parent)

    var properties = options && options.properties
    if (properties) {
      for (var key in properties) {
        object[key] = properties[key]
      }
    }

    return object
  }

  var component = Qt.createComponent(source)
  if (component.status !== QtQuick.Component.Ready) {
    console.debug('Component not ready.')
    if (component.status === QtQuick.Component.Error) {
      console.debug('Error: ' + component.errorString())
    }
    return // Error.
  }

  var object = component.createObject(parent, (options && options.properties) || {})
  if (!object) {
    console.debug('Error: unable to create dynamic object.')
  }

  return object
}

// -----------------------------------------------------------------------------

function getSystemPathFromUri (uri) {
  var str = uri.toString()
  if (startsWith(str, 'file://')) {
    str = str.substring(7)

    // Absolute path.
    if (str.charAt(0) === '/') {
      return runOnWindows() ? str.substring(1) : str
    }
  }

  return str
}

function getUriFromSystemPath (path) {
  if (path.startsWith('file://')) {
    return path
  }

  if (runOnWindows()) {
    return 'file://' + (/^\w:/.exec(path) ? '/' : '') + path
  }

  return 'file://' + path
}

// -----------------------------------------------------------------------------

// Returns the top (root) parent of one object.
function getTopParent (object, useFakeParent) {
  function _getTopParent (object, useFakeParent) {
    return (useFakeParent && object.$parent) || object.parent
  }

  var parent = _getTopParent(object, useFakeParent)
  var p
  while ((p = _getTopParent(parent, useFakeParent)) != null) {
    parent = p
  }

  return parent
}

// -----------------------------------------------------------------------------

// Load by default a window in the ui/views folder.
// If options.isString is equals to true, a marshalling component can
// be used.
//
// Supported options: isString, exitHandler, properties.
//
// If exitHandler is used, window must implement exitStatus signal.
function openWindow (window, parent, options, fullscreen) {
  var object = createObject(window, parent, options)

  object.closing.connect(object.destroy.bind(object))

  if (options && options.exitHandler) {
    object.exitStatus.connect(
      // Bind to access parent properties.
      options.exitHandler.bind(parent)
    )
  }
  if( runOnWindows()){
    object.show() // Needed for Windows : Show the window in all case. Allow to graphically locate the window before going to fullscreen.
    if(fullscreen)
      object.showFullScreen()// Should be equivalent to changing visibility
  }else if(fullscreen)
      object.showFullScreen()// Should be equivalent to changing visibility
  else
    object.show()
  return object
}

// -----------------------------------------------------------------------------

function resolveImageUri (name) {
  return name
    //? 'image://internal/' + removeScheme(Qt.resolvedUrl('/assets/images/' + name + '.svg'))
    ? 'image://internal/' + name
    : ''
}

// -----------------------------------------------------------------------------


function runOnWindows () {
  var os = Qt.platform.os
  return os === 'windows' || os === 'winrt'
}

// -----------------------------------------------------------------------------

// Test if a point is in a item.
//
// `source` is the item that generated the point.
// `target` is the item to test.
// `point` is the point to test.
function pointIsInItem (source, target, point) {
  point = source.mapToItem(target.parent, point.x, point.y)

  return (
    point.x >= target.x &&
    point.y >= target.y &&
    point.x < target.x + target.width &&
    point.y < target.y + target.height
  )
}

// -----------------------------------------------------------------------------

// Test the type of a qml object.
// Warning: this function is probably not portable
// on new versions of Qt.
//
// So, if you want to use it on a specific `className`, please to add
// a test in `test_qmlTypeof_data` of `utils.spec.qml`.
function qmlTypeof (object, className) {
  var str = object.toString()

  return (
    str.indexOf(className + '(') == 0 ||
    str.indexOf(className + '_QML') == 0
  )
}

// -----------------------------------------------------------------------------

function removeScheme (url) {
  return url.toString().replace(SCHEME_REGEX, '')
}

// -----------------------------------------------------------------------------

// A copy of `Window.setTimeout` from js.
// delay is in milliseconds.
function setTimeout (parent, delay, cb) {
  var timer = new (function (parent) {
    return Qt.createQmlObject('import QtQml 2.2; Timer { }', parent)
  })(parent)

  timer.interval = delay
  timer.repeat = false
  timer.triggered.connect(cb)
  timer.start()

  return timer
}

// =============================================================================
// GENERIC.
// =============================================================================

function _computeOptimizedCb (func, context) {
  return context
    ? (function () {
      return func.apply(context, arguments)
    }) : func
}

function _indexFinder (array, cb, context) {
  var length = array.length

  for (var i = 0; i < length; i++) {
    if (cb( (array.getAt ? array.getAt(i) : array[i]), i, array)) {
      return i
    }
  }

  return -1
}

function _keyFinder (obj, cb, context) {
  var keys = Object.keys(obj)
  var length = keys.length

  for (var i = 0; i < length; i++) {
    var key = keys[i]
    if (cb(obj[key], key, obj)) {
      return key
    }
  }
}

// -----------------------------------------------------------------------------

// Basic assert function.
function assert (condition, message) {
  if (!condition) {
    throw new Error('Assert: ' + message)
  }
}

// -----------------------------------------------------------------------------

function basename (str) {
  if (!str) {
    return ''
  }

  if (runOnWindows()) {
    str = str.replace(/\\/g, '/')
  }

  var str2 = str
  var length = str2.length - 1

  if (str2[length] === '/') {
    str2 = str2.substring(0, length)
  }

  return str2.slice(str2.lastIndexOf('/') + 1)
}

// -----------------------------------------------------------------------------

function capitalizeFirstLetter (str) {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

// -----------------------------------------------------------------------------

function dirname (str) {
  if (!str) {
    return ''
  }

  if (runOnWindows()) {
    str = str.replace(/\\/g, '/')
  }

  var str2 = str
  var length = str2.length - 1

  if (str2[length] === '/') {
    str2 = str2.substring(0, length)
  }

  return str2.slice(0, str2.lastIndexOf('/') + 1)
}

// -----------------------------------------------------------------------------

function extractProperties (obj, pattern) {
  if (!pattern) {
    return {}
  }

  var obj2 = {}
  pattern.forEach(function (property) {
    obj2[property] = obj[property]
  })

  return obj2
}

// -----------------------------------------------------------------------------

// Returns an array from an `object` or `array` argument.
function ensureArray (obj) {
  if (isArray(obj)) {
    return obj
  }

  var keys = Object.keys(obj)
  var length = keys.length
  var values = Array(length)

  for (var i = 0; i < length; i++) {
    values[i] = obj[keys[i]]
  }

  return values
}

// -----------------------------------------------------------------------------

function escapeQuotes (str) {
  return str != null
    ? str.replace(/([^'\\]*(?:\\.[^'\\]*)*)'/g, '$1\\\'')
    : ''
}

function decode(str){
  return decodeURIComponent(escape(str.replace(/%([0-9A-Fa-f]{2})/g, function() {
    return String.fromCharCode(parseInt(arguments[1], 16));
  })));
}
// -----------------------------------------------------------------------------

// Get the first matching value in a array or object.
// The matching value is obtained if `cb` returns true.
function find (obj, cb, context) {
  cb = _computeOptimizedCb(cb, context)

  var finder = isArray(obj) ? _indexFinder : _keyFinder
  var key = finder(obj, cb, context)

  return key != null && key !== -1 ? obj[key] : null
}

// -----------------------------------------------------------------------------

function findIndex (array, cb, context) {
  cb = _computeOptimizedCb(cb, context)

  var key = _indexFinder(array, cb, context)
  return key != null ? key : -1
}

// -----------------------------------------------------------------------------
function formatElapsedTime (seconds) {
  seconds = parseInt(seconds, 10)
//s,	m,	h,		d,		W,		M,			Y
//1,	60,	3600,	86400,	604800,	2592000,	31104000
	var y = Math.floor(seconds / 31104000)
	if(y > 0)
		return y+ ' years'
	var M = Math.floor(seconds / 2592000)
	if(M > 0)
		return M+' months'
	var w = Math.floor(seconds / 604800)
	if(w>0)
		return w+' week';
	var d = Math.floor(seconds / 86400)
	if(d>0)
		return d+' days'
	var h = Math.floor(seconds / 3600)
	var m = Math.floor((seconds - h * 3600) / 60)
	var s = seconds - h * 3600 - m * 60
	
	if (h < 10 && h > 0) {
		h = '0' + h
	}
	
	if (m < 10) {
		m = '0' + m
	}
	
	if (s < 10) {
		s = '0' + s
	}
	
	return (h === 0 ? '' : h + ':') + m + ':' + s
}

function formatDuration (seconds) {
  seconds = parseInt(seconds, 10)
//s,	m,	h,		d,		W,		M,			Y
//1,	60,	3600,	86400,	604800,	2592000,	31104000
	var y = Math.floor(seconds / 31104000)
	if(y > 0)
	//: '%1 year'
		return qsTr('formatYears', '', y).arg(y)
	var M = Math.floor(seconds / 2592000)
	if(M > 0)
		//: '%1 month'
		return qsTr('formatMonths', '', M).arg(M)
	var w = Math.floor(seconds / 604800)
	if(w>0)
		//: '%1 week'
		return qsTr('formatWeeks', '', w).arg(w)
	var d = Math.floor(seconds / 86400)
	if(d>0)
		//: '%1 day'
		return qsTr('formatDays', '', d).arg(d)
	var h = Math.floor(seconds / 3600)
	var m = Math.floor((seconds - h * 3600) / 60)
	var s = seconds - h * 3600 - m * 60
	
	//: '%1 hour'
	return  (h > 0 ? qsTr('formatHours', '', h).arg(h): '')
	//: '%1 minute'
			+ (m > 0 ? (h > 0 ? ', ' : '') +qsTr('formatMinutes', '', m).arg(m): '')
	//: '%1 second'
			+ (s > 0 ? (h> 0 || m > 0 ? ', ' : '') +qsTr('formatSeconds', '', s).arg(s): '')
}

function buildDate(date, time){
	var dateTime = new Date()
	dateTime.setFullYear(date.getFullYear(), date.getMonth(), date.getDate())
	dateTime.setHours(time.getHours())
	dateTime.setMinutes(time.getMinutes())
	dateTime.setSeconds(time.getSeconds())
	return dateTime
}

function equalDate(date1, date2){
    return date1.getFullYear() == date2.getFullYear() && date1.getMonth() == date2.getMonth() && date1.getDate() == date2.getDate()
}

function fromUTC(date){
	return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(),
                date.getUTCDate(), date.getUTCHours(),
                date.getUTCMinutes(), date.getUTCSeconds()));
}
// -----------------------------------------------------------------------------

function formatSize (size) {
  var units = ['KB', 'MB', 'GB', 'TB']
  var unit = 'B'

  if (size == null) {
    size = 0
  }

  var length = units.length
  for (var i = 0; size >= 1024 && i < length; i++) {
    unit = units[i]
    size /= 1024
  }

  return parseFloat(size.toFixed(2)) + unit
}

// -----------------------------------------------------------------------------

// Generate a random number in the [min, max[ interval.
// Uniform distrib.
function genRandomNumber (min, max) {
  return Math.random() * (max - min) + min
}

function genRandomColor(){
	return '#'+ Math.floor(Math.random()*255).toString(16)
									  +Math.floor(Math.random()*255).toString(16)
									  +Math.floor(Math.random()*255).toString(16)
}

// -----------------------------------------------------------------------------

// Generate a random number between a set of intervals.
// The `intervals` param must be orderer like this:
// `[ [ 1, 4 ], [ 8, 16 ], [ 22, 25 ] ]`
function genRandomNumberBetweenIntervals (intervals) {
  if (intervals.length === 1) {
    return genRandomNumber(intervals[0][0], intervals[0][1])
  }

  // Compute the intervals size.
  var size = 0
  intervals.forEach(function (interval) {
    size += interval[1] - interval[0]
  })

  // Generate a value in the interval: `[0, size[`
  var n = genRandomNumber(0, size)

  // Map the value in the right interval.
  n += intervals[0][0]
  for (var i = 0; i < intervals.length - 1; i++) {
    if (n < intervals[i][1]) {
      break
    }

    n += intervals[i + 1][0] - intervals[i][1]
  }

  return n
}

// -----------------------------------------------------------------------------

// Returns the extension of a filename.
function getExtension (str) {
  var index = str.lastIndexOf('.')

  if (index === -1) {
    return ''
  }

  return str.slice(index + 1)
}

// -----------------------------------------------------------------------------

// Test if a value is included in an array or object.
function includes (obj, value, startIndex) {
  obj = ensureArray(obj)
  if (startIndex == null) {
    startIndex = 0
  }
  var length = obj.length

  for (var i = startIndex; i < length; i++) {
    if (
      value == obj[i] ||
      // Check `NaN`.
      (value !== value && obj[i] !== obj[i])
    ) {
      return true
    }
  }
  return false
}

// -----------------------------------------------------------------------------

function isArray (array) {
  return (array instanceof Array)
}

// -----------------------------------------------------------------------------

function isFunction (func) {
  return typeof func === 'function'
}

// -----------------------------------------------------------------------------

function isInteger (integer) {
  return integer === parseInt(integer, 10)
}

// -----------------------------------------------------------------------------

function isObject (object) {
  return object !== null && typeof object === 'object'
}

// -----------------------------------------------------------------------------

function isString (string) {
  return typeof string === 'string' || string instanceof String
}

// -----------------------------------------------------------------------------

// Convert a snake_case string to a lowerCamelCase string.
function snakeToCamel (s) {
  return s.replace(/(\_\w)/g, function (matches) {
    return matches[1].toUpperCase()
  })
}

// -----------------------------------------------------------------------------

// Test if a string starts by a given string.
function startsWith (str, searchStr) {
  if (searchStr == null) {
    searchStr = ''
  }

  return str.slice(0, searchStr.length) === searchStr
}

// -----------------------------------------------------------------------------

// Invoke a `cb` function with each value of the interval: `[0, n[`.
// Return a mapped array created with the returned values of `cb`.
function times (n, cb, context) {
  var arr = Array(Math.max(0, n))
  cb = _computeOptimizedCb(cb, context, 1)

  for (var i = 0; i < n; i++) {
    arr[i] = cb(i)
  }

  return arr
}

// -----------------------------------------------------------------------------

function unscapeHtml (str) {
  return str.replace(/&/g, '&amp;')
    .replace(/</g, '\u2063&lt;')
    .replace(/>/g, '\u2063&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;')
}

// -----------------------------------------------------------------------------

function write (fileName, text) {
  // TODO: Deal with async.
  var request = new XMLHttpRequest()
  request.open('PUT', getUriFromSystemPath(fileName), false)
  request.send(text)
}

function computeAvatarSize (container, maxSize, ratio) {
  var height = container.height * ratio
  var width = container.width * ratio
  var size = height < maxSize && height > 0 ? height : maxSize
  return size < width ? size : width
}

// -----------------------------------------------------------------------------

function openCodecOnlineInstallerDialog (mainWindow, coreObject, cancelCallBack, successCallBack, errorCallBack) {
	mainWindow.showConfirmationLambdaPopup("",
        //: "Installation de codec"
        qsTr("codec_install"),
        //: "Télécharger le codec %1 (%2) ?"
        qsTr("download_codec").arg(capitalizeFirstLetter(coreObject.mimeType)).arg(coreObject.encoderDescription),
		function (confirmed) {
			if (confirmed) {
				coreObject.loaded.connect(function(success) {
					mainWindow.closeLoadingPopup()
					if (success) {
                        //: "Succès"
                        mainWindow.showInformationPopup(qsTr("information_popup_success_title"),
                                                        //: "Le codec a été installé avec succès."
                                                        qsTr("information_popup_codec_install_success_text"), true)
						if (successCallBack)
							successCallBack()
					} else {
                        mainWindow.showInformationPopup(qsTr("information_popup_error_title"),
                                                        //: "Le codec n'a pas pu être installé."
                                                        qsTr("information_popup_codec_install_error_text"), false)
						if (errorCallBack)
							errorCallBack()
					}
				})
				coreObject.extractError.connect(function() {
					mainWindow.closeLoadingPopup()
                    mainWindow.showInformationPopup(qsTr("information_popup_error_title"),
                                                    //: "Le codec n'a pas pu être sauvegardé."
                                                    qsTr("information_popup_codec_save_error_text"), false)
					if (errorCallBack)
						errorCallBack()
				})
				coreObject.downloadError.connect(function() {
					mainWindow.closeLoadingPopup()
                    mainWindow.showInformationPopup(qsTr("information_popup_error_title"),
                                                    //: "Le codec n'a pas pu être téléchargé."
                                                    qsTr("information_popup_codec_download_error_text"), false)
					if (errorCallBack)
						errorCallBack()
				})

                //: "Téléchargement en cours …"
                mainWindow.showLoadingPopup(qsTr("loading_popup_codec_install_progress"))
				coreObject.downloadAndExtract()
			} else
				if (cancelCallBack)
					cancelCallBack()
		}
	)
}

function printObject(o) {
  var out = '';
  for (var p in o) {
    out += p + ': ' + o[p] + '\n';
  }
  if(!o)
    return 'Empty'
  else
    return out;
}

function equalObject(a, b) {
	var countA = 0, countB = 0;
	if(a == b) return true // operator could be performed
	for (var i in a) {// Check for all members
		if(a[i] != b[i]) return false
		else ++countA
	}
	for (var j in b) {// Check count
		++countB
	}
	return countB == countA && countA > 0 // if count=0; then the first '==' should already worked
}

function infoDialog(window, message) {
	window.attachVirtualWindow(buildCommonDialogUri('ConfirmDialog'), {
		buttonTexts : ['',qsTr('okButton')],
		descriptionText: message,
		showButtonOnly: 1
	}, function (status) {})
}

// Set position of list.currentItem into the scrollItem
function updatePosition(scrollItem, list){
	if(scrollItem.height == 0) return;
	var item = list.itemAtIndex(list.currentIndex)
	var centerItemPos = 0
	var topItemPos = 0
	var bottomItemPos = 0
	if(!item) item = list.currentItem
	if( item && (list.expanded || list.expanded == undefined)){
		// For debugging just in case
		//var listPosition = item.mapToItem(favoriteList, item.x, item.y)
		//var newPosition = favoriteList.mapToItem(mainItem, listPosition.x, listPosition.y)
		//console.log("item pos: " +item.x + " / " +item.y)
		//console.log("fav pos: " +favoriteList.x + " / " +favoriteList.y)
		//console.log("fav content: " +favoriteList.contentX + " / " +favoriteList.contentY)
		//console.log("main pos: " +mainItem.x + " / " +mainItem.y)
		//console.log("main content: " +mainItem.contentX + " / " +mainItem.contentY)
		//console.log("list pos: " +listPosition.x + " / " +listPosition.y)
		//console.log("new pos: " +newPosition.x + " / " +newPosition.y)
		//console.log("header pos: " +headerItem.x + " / " +headerItem.y)
		//console.log("Moving to " + (headerItem.y+item.y))
		// Middle position
		//centerItemPos = item.y + list.y + item.height/2
		//if( list.headerHeight) centerItemPos += list.headerHeight
		topItemPos = item.y
		if( list != scrollItem) topItemPos += list.y
		if( list.headerHeight) topItemPos += list.headerHeight
		bottomItemPos = topItemPos +item.height
	}
	if(item){
		// Middle position
		//var centerPos = centerItemPos - scrollItem.height/2
		//scrollItem.contentY = Math.max(0, Math.min(centerPos, scrollItem.height, scrollItem.contentHeight-scrollItem.height))
		// Visible position
		if( topItemPos < scrollItem.contentY){
			// Display item at the beginning
			scrollItem.contentY = topItemPos
			//console.debug("Set to top", scrollItem.contentY,topItemPos, item.height)
		}else if(bottomItemPos > scrollItem.contentY + scrollItem.height){
			// Display item at the end
			scrollItem.contentY = bottomItemPos - scrollItem.height
			//console.debug("Set to bottom",scrollItem.contentY,list.y,list.headerHeight, topItemPos, bottomItemPos, scrollItem.height, bottomItemPos - scrollItem.height, item.height)
		}else{
			//console.debug("Inside, do not move", topItemPos, bottomItemPos, scrollItem.contentY, (scrollItem.contentY + scrollItem.height))
		}
		
	}else{
	//	console.debug("Item is null")
	}
}


