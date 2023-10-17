import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7

import Clipboard 1.0
import Common 1.0
import Linphone 1.0

import Common.Styles 1.0
import Linphone.Styles 1.0
import Utils 1.0
import Units 1.0
import ConstantsCpp 1.0
import UtilsCpp 1.0
import LinphoneEnums 1.0


// =============================================================================
// SpellCheckerMenu

Item {

	property string _word
	property int _position
	property SpellChecker spellChecker
	property var suggestions: []

	function open(word, position){
		_word = word
		_position = position
		suggestions = spellChecker.suggestionsForWord(word)
		spellCheckerMenu.popup()
	}
	
	Menu {
		id: spellCheckerMenu
		menuStyle : MenuStyle.aux
		
		MenuItem {
			//: 'Did you mean ?' : Suggest new words
			text: qsTr('spellCheckingMenuDidYouMean')
			menuItemStyle : MenuItemStyle.aux
			visible:suggestions.length != 0
			enabled: false
		}
		
		Repeater {
			model: suggestions
			MenuItem {
				text:modelData
				menuItemStyle : MenuItemStyle.aux
				onTriggered: spellChecker.replace(_word,modelData,_position)
				fontItalic: true
			}
		}
		
		MenuItem { // Work around to anchor separator below.
			visible:false
		}

		MenuSeparator {
			visible:suggestions.length != 0
		}
				
		MenuItem {
			//: 'Add to dictionary' : Add word to dictionary
			text: qsTr('spellCheckingMenuAddToDictionary')
			menuItemStyle : MenuItemStyle.aux
			onTriggered: spellChecker.learn(_word)
		}

		MenuItem {
			//: 'Ignore Once' : Ignore spell checking only for this occurences
			text: qsTr('spellCheckingMenuIgnoreOnce')
			menuItemStyle : MenuItemStyle.aux
			onTriggered: spellChecker.ignoreOnce(_word, _position)
		}
		
		MenuItem {
			//: 'Ignore All' : Ignore spell checking for all occurences
			text: qsTr('spellCheckingMenuIgnoreAll')
			menuItemStyle : MenuItemStyle.aux
			onTriggered: spellChecker.ignoreAll(_word)
		}
		
	}
}
