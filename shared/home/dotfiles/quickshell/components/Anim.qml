import QtQuick
import ".."

NumberAnimation {
    duration: Appearance.anim.normal
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Appearance.anim.curves.standard
}
