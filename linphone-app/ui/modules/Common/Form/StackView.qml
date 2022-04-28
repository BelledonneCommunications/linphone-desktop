import QtQuick 2.7
import QtQuick.Controls 2.12 as Control

import Common 1.0
import Common.Styles 1.0

import Utils 1.0

Control.StackView {
    id: stack
	clip:true
	property string viewsPath
	signal exit()
	
	readonly property alias nViews: stack.depth

    function pushView (view, properties) {
		stack.push(Utils.isString(view) ? viewsPath + view + '.qml' : view,properties)
	}
	
	function getView (index) {
		return stack.get(index)
	}
	
	function popView () {
		if( nViews <= 1 ) {
			stack.pop()
			stack.exit()
		}else
			stack.pop()
	}

    // -------------------------------------------------------------------------

    popEnter: Transition {
      YAnimator {
        duration: StackViewStyle.stackAnimation.duration
        easing.type: Easing.OutBack
        from: stack.height + StackViewStyle.bottomMargin
        to: 0
      }
    }

    popExit: Transition {
      XAnimator {
        duration: StackViewStyle.stackAnimation.duration
        easing.type: Easing.OutBack
        from: 0
        to: stack.width + StackViewStyle.rightMargin
      }
    }

    pushEnter: Transition {
      XAnimator {
        duration: StackViewStyle.stackAnimation.duration
        easing.type: Easing.OutBack
        from: stack.width + StackViewStyle.rightMargin
        to: 0
      }
    }

    pushExit: Transition {
      YAnimator {
        duration: StackViewStyle.stackAnimation.duration
        easing.type: Easing.OutBack
        from: 0
        to: stack.height + StackViewStyle.bottomMargin
      }
    }
  }