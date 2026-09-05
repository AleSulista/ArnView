import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Button {
    id: control

    implicitHeight: 34
    implicitWidth: Math.max(88, label.implicitWidth + 30)

    contentItem: Text {
        id: label
        text: control.text

        color: control.enabled ? "#F8FAFC" : "#75FFFFFF"

        font.pixelSize: 13
        font.bold: control.checked

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        style: Text.Raised
        styleColor: "#D0000000"
    }

    background: Item {
        implicitWidth: 90
        implicitHeight: 34

        MultiEffect {
            anchors.fill: glass
            source: glass

            shadowEnabled: true
            shadowOpacity: control.checked ? 0.55 : 0.42
            shadowBlur: 0.78
            shadowVerticalOffset: 2
            blurMax: 16

            z: -1
        }

        Rectangle {
            id: glass
            anchors.fill: parent

            radius: 7
            border.width: 1

            border.color:
                !control.enabled ? "#28FFFFFF"
                : control.checked ? "#FFE1A0"
                : control.hovered ? "#C4E5F4FF"
                : "#849FB1C0"

            gradient: Gradient {
                GradientStop {
                    position: 0.00
                    color:
                        control.checked ? "#DCEAB85A"
                        : control.down ? "#B83A444C"
                        : control.hovered ? "#B985A0B4"
                        : "#94718493"
                }

                GradientStop {
                    position: 0.18
                    color:
                        control.checked ? "#C8D29A32"
                        : control.hovered ? "#986A8294"
                        : "#79596B78"
                }

                GradientStop {
                    position: 0.47
                    color:
                        control.checked ? "#C0B87918"
                        : "#6E43515C"
                }

                GradientStop {
                    position: 0.53
                    color:
                        control.checked ? "#BCA8670E"
                        : "#6836414A"
                }

                GradientStop {
                    position: 1.00
                    color:
                        control.checked ? "#A9623305"
                        : control.down ? "#C5141A1F"
                        : "#9A1B252C"
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: 6

                color:
                    control.checked ? "#12FFE9A6"
                    : control.hovered ? "#14DCEFFF"
                    : "#0BCDE0EC"
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                anchors.leftMargin: 2
                anchors.rightMargin: 2
                anchors.topMargin: 2

                height: parent.height * 0.43
                radius: 5

                opacity:
                    !control.enabled ? 0.05
                    : control.down ? 0.09
                    : control.checked ? 0.31
                    : control.hovered ? 0.29
                    : 0.20

                gradient: Gradient {
                    GradientStop {
                        position: 0.00
                        color: "#F4FFFFFF"
                    }

                    GradientStop {
                        position: 0.38
                        color: "#6AFFFFFF"
                    }

                    GradientStop {
                        position: 1.00
                        color: "#00FFFFFF"
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                anchors.leftMargin: 5
                anchors.rightMargin: 5
                anchors.bottomMargin: 2

                height: 1
                color: "#99000000"
                opacity: 0.45
            }
        }

        scale: control.down ? 0.985 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 80
                easing.type: Easing.OutQuad
            }
        }
    }
}
