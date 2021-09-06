// TextButtonBStyle
pragma Singleton
import QtQml 2.2
import ColorsList 1.0
// =============================================================================

QtObject {
  property QtObject backgroundColor: QtObject {
    property color disabled: ColorsList.add("TextButtonB_background_disabled", "i30").color
    property color hovered: ColorsList.add("TextButtonB_background_hovered", "b").color
    property color normal: ColorsList.add("TextButtonB_background_normal", "i").color
    property color pressed: ColorsList.add("TextButtonB_background_pressed", "m").color
  }

  property QtObject textColor: QtObject {
    property color disabled: ColorsList.add("TextButtonB_text_disabled", "q").color
    property color hovered: ColorsList.add("TextButtonB_text_hovered", "q").color
    property color normal: ColorsList.add("TextButtonB_text_normal", "q").color
    property color pressed: ColorsList.add("TextButtonB_text_pressed", "q").color
  }
  property QtObject borderColor : backgroundColor
}
