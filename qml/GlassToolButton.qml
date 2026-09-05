import QtQuick
import QtQuick.Controls
import QtQuick.Effects

ToolButton {
    id: control

    implicitHeight: 34
    implicitWidth: Math.max(44, label.implicitWidth + 24)

    contentItem: Text {
        id: label
        text: control.text

        color: control.enabled ? "#F8FAFC" : "#75FFFFFF"

        font.pixelSize: control.font.pixelSize > 0
                        ? control.font.pixelSize
                        : 13

        font.bold: control.checked

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        style: Text.Raised
        styleColor: "#D0000000"
    }

    background: Item {
        implicitWidth: 48
        implicitHeight: 34

        MultiEffect {
            anchors.fill: glass
            source: glass

            shadowEnabled: true
            shadowOpacity: 0.42
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
                : control.hovered ? "#C4E5F4FF"
                : "#849FB1C0"

            gradient: Gradient {
                GradientStop {
                    position: 0.00
                    color:
                        !control.enabled ? "#4E4A535B"
                        : control.down ? "#B83A444C"
                        : control.hovered ? "#B985A0B4"
                        : "#94718493"
                }

                GradientStop {
                    position: 0.18
                    color:
                        control.hovered ? "#986A8294"
                        : "#79596B78"
                }

                GradientStop {
                    position: 0.47
                    color: "#6E43515C"
                }

                GradientStop {
                    position: 0.53
                    color: "#6836414A"
                }

                GradientStop {
                    position: 1.00
                    color:
                        control.down ? "#C5141A1F"
                        : "#9A1B252C"
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: 6

                color:
                    control.hovered ? "#14DCEFFF"
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
