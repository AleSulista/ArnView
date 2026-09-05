import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtCore

ApplicationWindow {
    id: root

    // =========================================================
    // MENU NATIVO MACOS — ARNVIEW
    // =========================================================

    menuBar: MenuBar {

        Menu {
            title: "ArnView"

            Action {
                text: "Sobre o ArnView"
                onTriggered: aboutDialog.open()
            }

            MenuSeparator {}

            Action {
                text: "Ocultar ArnView"
                shortcut: "Meta+H"
                onTriggered: root.hide()
            }

            MenuSeparator {}

            Action {
                text: "Sair do ArnView"
                shortcut: "Meta+Q"
                onTriggered: Qt.quit()
            }
        }

        Menu {
            title: "Arquivo"

            Action {
                text: "Abrir imagem…"
                shortcut: StandardKey.Open
                onTriggered: root.openImageDialog()
            }

            MenuSeparator {}

            Action {
                text: "Anterior"
                enabled: imageController.hasImage
                onTriggered: imageController.previous()
            }

            Action {
                text: "Próxima"
                enabled: imageController.hasImage
                onTriggered: imageController.next()
            }
        }
        Menu {
            title: "Editar"

            Action {
                text: "Desfazer"
                shortcut: StandardKey.Undo
                enabled: imageController.canUndo
                onTriggered: imageController.undo()
            }

            Action {
                text: "Refazer"
                shortcut: StandardKey.Redo
                enabled: imageController.canRedo
                onTriggered: imageController.redo()
            }

            MenuSeparator {}

            Action {
                text: "Abrir Editor"
                enabled: imageController.hasImage
                onTriggered: arnEditorWindow.openEditor()
            }
        }

        Menu {
            title: "Imagem"

            Action {
                text: "Girar 90° à esquerda"
                enabled: imageController.hasImage
                onTriggered: imageController.rotateLeft()
            }

            Action {
                text: "Girar 90° à direita"
                enabled: imageController.hasImage
                onTriggered: imageController.rotateRight()
            }

            MenuSeparator {}

            Action {
                text: "Espelhar horizontalmente"
                enabled: imageController.hasImage
                onTriggered: imageController.flipHorizontal()
            }

            Action {
                text: "Espelhar verticalmente"
                enabled: imageController.hasImage
                onTriggered: imageController.flipVertical()
            }

            MenuSeparator {}

            Action {
                text: "Preto e branco"
                enabled: imageController.hasImage
                onTriggered: imageController.grayscale()
            }

            Action {
                text: "Sépia"
                enabled: imageController.hasImage
                onTriggered: imageController.sepia()
            }

            Action {
                text: "Melhoria automática"
                enabled: imageController.hasImage
                onTriggered: imageController.autoImprove()
            }
        }

        Menu {
            title: "IA"

            Action {
                text: "Melhoria inteligente"
                enabled: imageController.hasImage && !imageController.aiBusy
                onTriggered: imageController.runVisionAi("auto")
            }

            Action {
                text: "Reduzir ruído"
                enabled: imageController.hasImage && !imageController.aiBusy
                onTriggered: imageController.runVisionAi("denoise")
            }

            Action {
                text: "Clarear foto escura"
                enabled: imageController.hasImage && !imageController.aiBusy
                onTriggered: imageController.runVisionAi("lowlight")
            }

            Action {
                text: "Restaurar fotografia"
                enabled: imageController.hasImage && !imageController.aiBusy
                onTriggered: imageController.runVisionAi("restore")
            }

            MenuSeparator {}

            Action {
                text: "Melhorar rostos"
                enabled: imageController.hasImage && !imageController.aiBusy
                onTriggered: imageController.runVisionAi("face")
            }

            Action {
                text: "Desfocar rostos"
                enabled: imageController.hasImage && !imageController.aiBusy
                onTriggered: imageController.runVisionAi("blurfaces")
            }

            MenuSeparator {}

            Action {
                text: "Upscale 2×"
                enabled: imageController.hasImage && !imageController.aiBusy
                onTriggered: imageController.runVisionAi("upscale", "2")
            }

            Action {
                text: "Upscale 4×"
                enabled: imageController.hasImage && !imageController.aiBusy
                onTriggered: imageController.runVisionAi("upscale", "4")
            }

            MenuSeparator {}

            Action {
                text: "Extrair texto da imagem (OCR)"
                enabled: imageController.hasImage && !imageController.aiBusy
                onTriggered: imageController.runVisionText("ocr", "")
            }

            MenuSeparator {}

            Action {
                text: "Remover fundo"
                enabled: imageController.hasImage && !imageController.aiBusy
                onTriggered: imageController.runRemoveBackground()
            }

            Action {
                text: "Remover objeto…"
                enabled: imageController.hasImage && !imageController.aiBusy
                onTriggered: {
                    root.lamaBrushMode = true
                    root.wakeControls()
                }
            }
        }

        Menu {
            title: "Visualizar"

            Action {
                text: "Ajustar imagem à janela"
                shortcut: "0"
                enabled: imageController.hasImage
                onTriggered: root.fitImage()
            }

            Action {
                text: "Tamanho real"
                shortcut: "1"
                enabled: imageController.hasImage
                onTriggered: root.actualSize()
            }

            MenuSeparator {}

            Action {
                text: "Aumentar zoom"
                shortcut: "Meta++"
                enabled: imageController.hasImage
                onTriggered: root.zoom = Math.min(32.0, root.zoom * 1.2)
            }

            Action {
                text: "Diminuir zoom"
                shortcut: "Meta+-"
                enabled: imageController.hasImage
                onTriggered: root.zoom = Math.max(0.02, root.zoom / 1.2)
            }

            MenuSeparator {}

            Action {
                text: root.fullScreenMode ? "Sair da tela cheia" : "Entrar em tela cheia"
                shortcut: "Ctrl+Meta+F"
                onTriggered: root.toggleFullScreen()
            }
        }

        Menu {
            title: "Janela"

            Action {
                text: "Minimizar"
                shortcut: "Meta+M"
                onTriggered: root.showMinimized()
            }

            Action {
                text: "Trazer ArnView para frente"
                onTriggered: {
                    root.show()
                    root.raise()
                    root.requestActivate()
                }
            }
        }

        Menu {
            title: "Ajuda"

            Action {
                text: "Sobre o ArnView"
                onTriggered: aboutDialog.open()
            }

            Action {
                text: "Créditos"
                onTriggered: creditsDialog.open()
            }

            Action {
                text: "Licenças"
                onTriggered: licensesDialog.open()
            }
        }
    }

    visible: true
    visibility: Window.Windowed
    width: 1100
    height: 720
    minimumWidth: 720
    minimumHeight: 480
    flags: Qt.Window | Qt.FramelessWindowHint
    color: "transparent"
    title: imageController.currentName.length ? imageController.currentName + " — ArnView" : "ArnView"

    property real zoom: 1.0
    property real fitZoom: 1.0
    property real panX: 0
    property real panY: 0
    property bool controlsVisible: true
    property bool dimBackground: false
    property bool fullScreenMode: visibility === Window.FullScreen
    property bool editorVisible: false
    property bool aiPanelVisible: false
    property bool pendingFit: true
    property bool lamaBrushMode: false
    property real lamaBrushSize: 60

    property bool textPanelVisible: false
    property real textBoxWidth: 360
    property real textBoxHeight: 110
    property real textX: imageController.imageWidth > 0
                             ? imageController.imageWidth * 0.15 : 0
    property real textY: imageController.imageHeight > 0
                             ? imageController.imageHeight * 0.18 : 0

    function openImageDialog() {
        root.raise()
        root.requestActivate()

        openDialog.currentFolder =
            StandardPaths.writableLocation(
                StandardPaths.PicturesLocation
            )

        openDialog.open()
    }

    function resetAdjustmentSliders() {
        brightnessSlider.value = 0; contrastSlider.value = 0; saturationSlider.value = 0
        temperatureSlider.value = 0; tintSlider.value = 0; monoSlider.value = 0; sepiaSlider.value = 0
    }

    function previewAdjustments() {
        imageController.previewAdjustments(Math.round(brightnessSlider.value), Math.round(contrastSlider.value),
                                           Math.round(saturationSlider.value), Math.round(temperatureSlider.value),
                                           Math.round(tintSlider.value), Math.round(monoSlider.value),
                                           Math.round(sepiaSlider.value))
    }

    function toggleFullScreen() {
        if (fullScreenMode) {
            visibility = Window.Windowed
            width = 1100
            height = 720
            x = Math.round((Screen.width - width) / 2)
            y = Math.round((Screen.height - height) / 2)
        } else {
            visibility = Window.FullScreen
        }
        wakeControls()
    }

    function wakeControls() {
        controlsVisible = true
        hideTimer.restart()
    
        if (thumbnailStrip)
            thumbnailStrip.wakeDock()
    }

    function fitImage() {
        if (photo.status !== Image.Ready || imageController.imageWidth <= 0 || imageController.imageHeight <= 0)
            return
        const marginX = 70
        const marginY = 110
        fitZoom = Math.min(1.0,
                           (root.width - marginX) / imageController.imageWidth,
                           (root.height - marginY) / imageController.imageHeight)
        zoom = fitZoom
        panX = 0
        panY = 0
    }

    function actualSize() {
        zoom = 1.0
        panX = 0
        panY = 0
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        Behavior on color { ColorAnimation { duration: 180 } }
    }

    // Faixa invisível para mover a janela sem adicionar uma moldura tradicional.
    MouseArea {
        z: 100
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 48
        acceptedButtons: Qt.LeftButton
        onPressed: root.startSystemMove()
        onDoubleClicked: root.toggleFullScreen()
    }

    Text {
        anchors.centerIn: parent
        visible: !imageController.hasImage
        text: "ARNVIEW\n\nArraste uma imagem para cá\nou pressione ⌘O"
        horizontalAlignment: Text.AlignHCenter
        color: "#E6FFFFFF"
        font.pixelSize: 20
        font.letterSpacing: 2
    }

    Item {
        id: imageStage
        anchors.fill: parent
        clip: false

        Image {
            id: photo
                z: root.textPanelVisible ? 30 : 0
            source: imageController.displayUrl
            asynchronous: false
            cache: false
            autoTransform: true
            smooth: true
            mipmap: true
            width: imageController.imageWidth
            height: imageController.imageHeight
            x: (imageStage.width - width) / 2 + root.panX
            y: (imageStage.height - height) / 2 + root.panY
            scale: root.zoom
            transformOrigin: Item.Center

            onStatusChanged: {
                if (status === Image.Ready && root.pendingFit) {
                    root.pendingFit = false
                    root.fitImage()
                }
            }

            layer.enabled: true
            layer.smooth: true

            Item {
                id: textOverlay
                z: 300

                x: root.textX
                y: root.textY

                width: root.textBoxWidth
                height: root.textBoxHeight

                visible:
                    root.textPanelVisible
                    && imageController.hasImage

                rotation:
                    textRotation.value

                Rectangle {
                    anchors.fill: parent

                    color: "#10000000"

                    border.width: 2
                    border.color: "#F0FFFFFF"

                    radius: 5
                }

                // =================================================
                // BARRA PARA MOVER
                // =================================================

                Rectangle {
                    id: textDragBar

                    z: 50

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top

                    height: 24

                    color: "#AA202020"

                    Text {
                        anchors.centerIn: parent

                        text: "Arraste para mover"

                        color: "#E8FFFFFF"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent

                        cursorShape:
                            Qt.SizeAllCursor

                        property real startX
                        property real startY
                        property real boxX
                        property real boxY

                        onPressed: mouse => {

                            boxX = root.textX
                            boxY = root.textY

                            var p =
                                mapToItem(
                                    photo,
                                    mouse.x,
                                    mouse.y
                                )

                            startX = p.x
                            startY = p.y

                            mouse.accepted = true
                        }

                        onPositionChanged: mouse => {

                            if (!pressed)
                                return

                            var p =
                                mapToItem(
                                    photo,
                                    mouse.x,
                                    mouse.y
                                )

                            root.textX =
                                boxX + p.x - startX

                            root.textY =
                                boxY + p.y - startY

                            mouse.accepted = true
                        }
                    }
                }

                // =================================================
                // SOMBRA - PREVIEW FUNCIONAL
                // =================================================

                Text {
                    id: liveShadow

                    z: 5

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: textDragBar.bottom
                    anchors.bottom: parent.bottom

                    anchors.margins: 8

                    property real rad:
                        shadowAngle.value
                        * Math.PI / 180

                    transform: Translate {
                        x:
                            Math.cos(liveShadow.rad)
                            * shadowDistance.value

                        y:
                            Math.sin(liveShadow.rad)
                            * shadowDistance.value
                    }

                    text:
                        textInput.text

                    font.family:
                        fontCombo.currentText

                    font.pixelSize:
                        textSize.value
                        + shadowSize.value * 0.20

                    font.bold:
                        textBold.checked

                    font.italic:
                        textItalic.checked

                    wrapMode:
                        Text.Wrap

                    horizontalAlignment:
                        Text.AlignHCenter

                    verticalAlignment:
                        Text.AlignVCenter

                    color:
                        shadowColorControl.chosenColor

                    opacity:
                        shadowOpacity.value / 100

                    visible:
                        textShadow.checked
                        && textInput.text.length > 0
                }

                // =================================================
                // CONTORNO PREVIEW
                // =================================================

                Text {
                    id: liveOutline

                    z: 10

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: textDragBar.bottom
                    anchors.bottom: parent.bottom

                    anchors.margins: 8

                    text:
                        textInput.text

                    font.family:
                        fontCombo.currentText

                    font.pixelSize:
                        textSize.value

                    font.bold:
                        textBold.checked

                    font.italic:
                        textItalic.checked

                    wrapMode:
                        Text.Wrap

                    horizontalAlignment:
                        Text.AlignHCenter

                    verticalAlignment:
                        Text.AlignVCenter

                    color:
                        textColorButton.chosenColor

                    style:
                        Text.Outline

                    styleColor:
                        textColorButton.chosenColor.toString().toUpperCase()
                        === "#000000"
                        ? "white"
                        : "black"

                    opacity:
                        textOpacity.value / 100

                    visible:
                        textOutline.checked
                        && textInput.text.length > 0
                }

                // =================================================
                // TEXTO EDITÁVEL
                // =================================================

                TextArea {
                    id: textInput

                    z: 20

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: textDragBar.bottom
                    anchors.bottom: parent.bottom

                    anchors.margins: 8

                    placeholderText:
                        "Digite aqui..."

                    color:
                        textColorButton.chosenColor

                    font.family:
                        fontCombo.currentText

                    font.pixelSize:
                        textSize.value

                    font.bold:
                        textBold.checked

                    font.italic:
                        textItalic.checked

                    wrapMode:
                        TextEdit.Wrap

                    horizontalAlignment:
                        TextEdit.AlignHCenter

                    verticalAlignment:
                        TextEdit.AlignVCenter

                    selectByMouse: true

                    opacity:
                        textOpacity.value / 100

                    background: Rectangle {
                        color: "transparent"
                    }
                }

                // =================================================
                // REDIMENSIONAR
                // =================================================

                Rectangle {
                    id: textResizeHandle

                    z: 100

                    width: 24
                    height: 24

                    anchors.right:
                        parent.right

                    anchors.bottom:
                        parent.bottom

                    anchors.rightMargin: -12
                    anchors.bottomMargin: -12

                    radius: 12

                    color: "white"

                    border.width: 2
                    border.color: "#202020"

                    Text {
                        anchors.centerIn: parent

                        text: "↘"

                        color: "#202020"
                        font.pixelSize: 13
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -10

                        cursorShape:
                            Qt.SizeFDiagCursor

                        property real startX
                        property real startY

                        property real originalWidth
                        property real originalHeight
                        property real originalFont

                        onPressed: mouse => {

                            var p =
                                mapToItem(
                                    photo,
                                    mouse.x,
                                    mouse.y
                                )

                            startX = p.x
                            startY = p.y

                            originalWidth =
                                root.textBoxWidth

                            originalHeight =
                                root.textBoxHeight

                            originalFont =
                                textSize.value

                            mouse.accepted = true
                        }

                        onPositionChanged: mouse => {

                            if (!pressed)
                                return

                            var p =
                                mapToItem(
                                    photo,
                                    mouse.x,
                                    mouse.y
                                )

                            var dx =
                                p.x - startX

                            var dy =
                                p.y - startY

                            var nw =
                                Math.max(
                                    120,
                                    originalWidth + dx
                                )

                            var nh =
                                Math.max(
                                    55,
                                    originalHeight + dy
                                )

                            var scale =
                                nw / originalWidth

                            root.textBoxWidth = nw
                            root.textBoxHeight = nh

                            textSize.value =
                                Math.max(
                                    8,
                                    Math.min(
                                        300,
                                        originalFont
                                        * scale
                                    )
                                )

                            mouse.accepted = true
                        }
                    }
                }
            }
        }

        Item {
            id: lamaOverlay
            z: 20

            visible: root.lamaBrushMode
                  && imageController.hasImage

            width: imageController.imageWidth
            height: imageController.imageHeight

            x: photo.x
            y: photo.y
            scale: root.zoom
            transformOrigin: Item.Center

            Canvas {
                id: lamaCanvas
                anchors.fill: parent

                property var strokes: []

                function addStroke(x1, y1, x2, y2, size) {
                    var copy = strokes.slice()
                    copy.push({
                        x1: x1,
                        y1: y1,
                        x2: x2,
                        y2: y2,
                        size: size
                    })
                    strokes = copy
                    requestPaint()
                }

                function clearMask() {
                    strokes = []
                    requestPaint()
                }

                onPaint: {
                    var ctx = getContext("2d")

                    ctx.reset()
                    ctx.clearRect(0, 0, width, height)

                    ctx.strokeStyle = "rgba(255, 45, 45, 0.58)"
                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"

                    for (var i = 0; i < strokes.length; ++i) {
                        var st = strokes[i]

                        ctx.lineWidth = st.size
                        ctx.beginPath()
                        ctx.moveTo(st.x1, st.y1)
                        ctx.lineTo(st.x2, st.y2)
                        ctx.stroke()
                    }
                }
            }

            MouseArea {
                id: lamaMouse
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                hoverEnabled: true

                property real lastX: 0
                property real lastY: 0

                cursorShape: Qt.CrossCursor

                onPressed: mouse => {
                    lastX = mouse.x
                    lastY = mouse.y

                    lamaCanvas.addStroke(
                        mouse.x,
                        mouse.y,
                        mouse.x + 0.01,
                        mouse.y + 0.01,
                        root.lamaBrushSize
                    )

                    imageController.lamaMaskStroke(
                        mouse.x,
                        mouse.y,
                        mouse.x,
                        mouse.y,
                        root.lamaBrushSize
                    )
                }

                onPositionChanged: mouse => {
                    root.wakeControls()

                    if (!pressed)
                        return

                    lamaCanvas.addStroke(
                        lastX,
                        lastY,
                        mouse.x,
                        mouse.y,
                        root.lamaBrushSize
                    )

                    imageController.lamaMaskStroke(
                        lastX,
                        lastY,
                        mouse.x,
                        mouse.y,
                        root.lamaBrushSize
                    )

                    lastX = mouse.x
                    lastY = mouse.y
                }
            }
        }

        // =========================================================
        // TRACKPAD — PINÇA NATIVA MACOS / QT
        // =========================================================
        PinchHandler {
            id: trackpadPinch

            target: null

            enabled:
                imageController.hasImage
                && !root.lamaBrushMode

            acceptedDevices:
                PointerDevice.TouchPad

            minimumPointCount: 2
            maximumPointCount: 2

            onScaleChanged: (delta) => {

                if (!isFinite(delta) || delta <= 0)
                    return

                var oldZoom = root.zoom

                var newZoom =
                    Math.max(
                        0.02,
                        Math.min(
                            32.0,
                            oldZoom * delta
                        )
                    )

                if (Math.abs(newZoom - oldZoom) < 0.000001)
                    return

                // Centro atual da pinça
                var cx = centroid.position.x
                var cy = centroid.position.y

                var centerX =
                    imageStage.width / 2

                var centerY =
                    imageStage.height / 2

                // Faz o zoom acontecer exatamente
                // sob o ponto onde estão os dedos.
                var ratio =
                    newZoom / oldZoom

                root.panX =
                    cx
                    - centerX
                    - (
                        cx
                        - centerX
                        - root.panX
                      ) * ratio

                root.panY =
                    cy
                    - centerY
                    - (
                        cy
                        - centerY
                        - root.panY
                      ) * ratio

                root.zoom = newZoom
                root.wakeControls()
            }
        }

        MouseArea {
            id: interaction
            enabled: !root.lamaBrushMode
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: true
            property real startPanX
            property real startPanY
            property real startMouseX
            property real startMouseY

            onPositionChanged: root.wakeControls()
            onPressed: mouse => {
                startPanX = root.panX
                startPanY = root.panY
                startMouseX = mouse.x
                startMouseY = mouse.y
            }
            onMouseXChanged: {
                if (pressed) root.panX = startPanX + mouseX - startMouseX
            }
            onMouseYChanged: {
                if (pressed) root.panY = startPanY + mouseY - startMouseY
            }
            onDoubleClicked: root.zoom === root.fitZoom ? root.actualSize() : root.fitImage()
            onWheel: wheel => {
                const factor = wheel.angleDelta.y > 0 ? 1.14 : 1 / 1.14
                root.zoom = Math.max(0.02, Math.min(32.0, root.zoom * factor))
                root.wakeControls()
                wheel.accepted = true
            }
        }
    }

    DropArea {
        anchors.fill: parent
        onEntered: drag => drag.accept(Qt.LinkAction)
        onDropped: drop => {
            if (drop.urls.length > 0)
                imageController.openUrl(drop.urls[0])
        }
    }

    Rectangle {
        id: topLabel
        visible: imageController.hasImage
        opacity: root.controlsVisible ? 1 : 0
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 18
        width: Math.min(titleText.implicitWidth + 36, root.width - 80)
        height: 38
        radius: 19
        color: "#B51A1A1A"
        Behavior on opacity { NumberAnimation { duration: 220 } }

        Text {
                    id: textShadowPreview

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: textDragBar.bottom
                    anchors.bottom: parent.bottom

                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    anchors.topMargin: 8
                    anchors.bottomMargin: 8

                    property real shadowRadians:
                        shadowAngle.value * Math.PI / 180

                    x:
                        Math.cos(shadowRadians)
                        * shadowDistance.value

                    y:
                        Math.sin(shadowRadians)
                        * shadowDistance.value

                    text: textInput.text

                    font.family:
                        fontCombo.currentText

                    font.pixelSize:
                        textSize.value

                    font.bold:
                        textBold.checked

                    font.italic:
                        textItalic.checked

                    wrapMode:
                        Text.Wrap

                    horizontalAlignment:
                        Text.AlignHCenter

                    verticalAlignment:
                        Text.AlignVCenter

                    color:
                        shadowColorControl.chosenColor

                    opacity:
                        shadowOpacity.value / 100

                    visible:
                        textShadow.checked

                    // Dá sensação de sombra maior/mais forte.
                    style:
                        shadowSize.value > 0
                        ? Text.Outline
                        : Text.Normal

                    styleColor:
                        shadowColorControl.chosenColor
                }
    }

    EditorWindow {
        id: arnEditorWindow
    }

    Rectangle {
        id: editorPanel
        z: 90
        visible: root.editorVisible
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: Math.min(300, root.width * 0.38)
        color: "#EE151515"
        border.color: "#4DD4AF37"
        border.width: 1

        ToolButton {
            id: closeEditorPanel
            z: 300
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 8
            text: "✕"

            onClicked: {
                imageController.commitAdjustments()
                root.editorVisible = false
            }
        }

        ScrollView {
            anchors.fill: parent
            anchors.margins: 18
            contentWidth: availableWidth

            ColumnLayout {
                width: editorPanel.width - 36
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Label { text: "Editar imagem"; color: "#E6C56A"; font.bold: true; font.pixelSize: 19; Layout.fillWidth: true }
                    ToolButton { text: "×"; font.pixelSize: 22; onClicked: { imageController.cancelAdjustments(); root.resetAdjustmentSliders(); root.editorVisible = false } }
                }
                Label { text: "Histórico"; color: "white"; font.bold: true }
                RowLayout {
                    Button { text: "Desfazer"; enabled: imageController.canUndo; onClicked: imageController.undo() }
                    Button { text: "Refazer"; enabled: imageController.canRedo; onClicked: imageController.redo() }
                    Button { text: "Original"; enabled: imageController.hasImage; onClicked: imageController.reset() }
                }
                MenuSeparator { Layout.fillWidth: true }
                Label { text: "Luz e cores"; color: "white"; font.bold: true }
                Button { text: "Melhoria automática"; Layout.fillWidth: true; enabled: imageController.hasImage; onClicked: { imageController.cancelAdjustments(); root.resetAdjustmentSliders(); imageController.autoImprove(); imageController.beginAdjustments() } }

                Label { text: "Brilho   " + Math.round(brightnessSlider.value); color: "white" }
                Slider { id: brightnessSlider; from: -100; to: 100; value: 0; stepSize: 1; Layout.fillWidth: true; onMoved: adjustmentPreviewTimer.restart() }
                Label { text: "Contraste   " + Math.round(contrastSlider.value); color: "white" }
                Slider { id: contrastSlider; from: -100; to: 100; value: 0; stepSize: 1; Layout.fillWidth: true; onMoved: adjustmentPreviewTimer.restart() }
                Label { text: "Saturação   " + Math.round(saturationSlider.value); color: "white" }
                Slider { id: saturationSlider; from: -100; to: 100; value: 0; stepSize: 1; Layout.fillWidth: true; onMoved: adjustmentPreviewTimer.restart() }
                Label { text: "Temperatura   " + Math.round(temperatureSlider.value); color: "white" }
                Slider { id: temperatureSlider; from: -100; to: 100; value: 0; stepSize: 1; Layout.fillWidth: true; onMoved: adjustmentPreviewTimer.restart() }
                Label { text: "Matiz   " + Math.round(tintSlider.value); color: "white" }
                Slider { id: tintSlider; from: -100; to: 100; value: 0; stepSize: 1; Layout.fillWidth: true; onMoved: adjustmentPreviewTimer.restart() }
                Label { text: "Preto e branco   " + Math.round(monoSlider.value) + "%"; color: "white" }
                Slider { id: monoSlider; from: 0; to: 100; value: 0; stepSize: 1; Layout.fillWidth: true; onMoved: adjustmentPreviewTimer.restart() }
                Label { text: "Sépia   " + Math.round(sepiaSlider.value) + "%"; color: "white" }
                Slider { id: sepiaSlider; from: 0; to: 100; value: 0; stepSize: 1; Layout.fillWidth: true; onMoved: adjustmentPreviewTimer.restart() }

                RowLayout {
                    Layout.fillWidth: true
                    Button { text: "Aplicar ajustes"; Layout.fillWidth: true; onClicked: { adjustmentPreviewTimer.stop(); root.previewAdjustments(); imageController.commitAdjustments(); root.resetAdjustmentSliders(); imageController.beginAdjustments() } }
                    Button { text: "Cancelar"; onClicked: { imageController.cancelAdjustments(); root.resetAdjustmentSliders(); imageController.beginAdjustments() } }
                }
                MenuSeparator { Layout.fillWidth: true }
                Label { text: "Transformar"; color: "white"; font.bold: true }
                RowLayout {
                    Button { text: "↶ 90°"; onClicked: { imageController.commitAdjustments(); imageController.rotateLeft(); root.resetAdjustmentSliders(); imageController.beginAdjustments() } }
                    Button { text: "↷ 90°"; onClicked: { imageController.commitAdjustments(); imageController.rotateRight(); root.resetAdjustmentSliders(); imageController.beginAdjustments() } }
                }
                RowLayout {
                    Button { text: "Espelhar ↔"; onClicked: { imageController.commitAdjustments(); imageController.flipHorizontal(); root.resetAdjustmentSliders(); imageController.beginAdjustments() } }
                    Button { text: "Espelhar ↕"; onClicked: { imageController.commitAdjustments(); imageController.flipVertical(); root.resetAdjustmentSliders(); imageController.beginAdjustments() } }
                }
                Button { text: "Salvar"; Layout.fillWidth: true; enabled: imageController.hasImage; onClicked: imageController.save() }
                Button { text: "Salvar como…"; Layout.fillWidth: true; enabled: imageController.hasImage; onClicked: saveDialog.open() }
            }
        }
    }


    Rectangle {
        id: aiPanel

        z: 95
        visible: root.aiPanelVisible

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        width: Math.min(320, root.width * 0.40)

        color: "#EE151515"

        ToolButton {
            id: closeAiPanel
            z: 300
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 8
            text: "✕"

            onClicked: {
                root.lamaBrushMode = false
                root.aiPanelVisible = false
            }
        }

        ScrollView {
            anchors.fill: parent
            clip: true

            ColumnLayout {
                width: aiPanel.width
                spacing: 12

                Item {
                    Layout.preferredHeight: 12
                }

                Label {
                    text: "INTELIGÊNCIA ARTIFICIAL"
                    color: "#79E08B"
                    font.bold: true
                    font.pixelSize: 17

                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                }

                Label {
                    text: "IA Local • Offline • Sem créditos"
                    color: "#C8FFFFFF"

                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                }

                MenuSeparator {
                    Layout.fillWidth: true
                }

                Label {
                    text: "Remover fundo"
                    color: "white"
                    font.bold: true
                    Layout.leftMargin: 16
                }

                Button {
                    text: imageController.aiBusy
                          ? "Processando…"
                          : "Remover fundo automaticamente"

                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16

                    enabled: imageController.hasImage
                          && !imageController.aiBusy

                    onClicked: {
                        root.lamaBrushMode = false
                        imageController.runRemoveBackground()
                    }
                }

                MenuSeparator {
                    Layout.fillWidth: true
                }

                Label {
                    text: "Remover objetos"
                    color: "white"
                    font.bold: true

                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                }

                Label {
                    text: "Ative o pincel e pinte de vermelho somente sobre aquilo que deseja remover."
                    color: "#C8FFFFFF"
                    wrapMode: Text.WordWrap

                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16

                    Button {
                        text: root.lamaBrushMode
                              ? "✓ Pincel ativo"
                              : "Pincel de remoção"

                        checkable: true
                        checked: root.lamaBrushMode
                        Layout.fillWidth: true

                        onClicked: {
                            root.lamaBrushMode = checked
                            root.wakeControls()
                        }
                    }

                    Button {
                        text: "Limpar"

                        enabled: imageController.hasImage

                        onClicked: {
                            imageController.clearLamaMask()
                            lamaCanvas.clearMask()
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16

                    Label {
                        text: "Pincel"
                        color: "white"
                    }

                    Slider {
                        from: 6
                        to: 180
                        value: root.lamaBrushSize

                        Layout.fillWidth: true

                        onMoved:
                            root.lamaBrushSize = value
                    }

                    Label {
                        text: Math.round(root.lamaBrushSize)
                        color: "white"
                        Layout.minimumWidth: 35
                    }
                }

                Button {
                    text: imageController.aiBusy
                          ? "Processando…"
                          : "Remover seleção"

                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16

                    // NÃO trava mais depois da primeira remoção.
                    enabled: imageController.hasImage
                          && !imageController.aiBusy

                    onClicked: {
                        imageController.runLamaMask()
                    }
                }

                BusyIndicator {
                    visible: imageController.aiBusy
                    running: visible

                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    visible: imageController.aiStatus.length > 0

                    text: imageController.aiStatus

                    color: "white"
                    wrapMode: Text.WordWrap

                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                }

                MenuSeparator {
                    Layout.fillWidth: true
                }

                Label {
                    text: "Recursos locais"
                    color: "#79E08B"
                    font.bold: true

                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                }

                Label {
                    text: "Aqui vamos acrescentar remover fundo, melhorar foto, restaurar, aumentar resolução e outros recursos locais."
                    color: "#AFFFFFFF"
                    wrapMode: Text.WordWrap

                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                }

                Item {
                    Layout.preferredHeight: 10
                }

                Button {
                    text: "Salvar imagem"

                    enabled: imageController.hasImage

                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16

                    onClicked:
                        imageController.save()
                }

                Button {
                    text: "Salvar como…"

                    enabled: imageController.hasImage

                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16

                    onClicked:
                        saveDialog.open()
                }

                Item {
                    Layout.preferredHeight: 20
                }
            }
        }
    }


    Rectangle {
        id: textPanel
        z: 180

        visible: root.textPanelVisible

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        width: Math.min(340, root.width * 0.42)

        color: "#F0151515"

        ToolButton {
            z: 10

            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 8

            text: "✕"
            font.pixelSize: 18

            onClicked: {
                root.textPanelVisible = false
                textInput.focus = false
                root.wakeControls()
            }
        }

        ScrollView {
            anchors.fill: parent

            anchors.topMargin: 14
            anchors.bottomMargin: 14
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            clip: true

            ColumnLayout {
                width: textPanel.width - 32
                spacing: 10

                Label {
                    text: "Inserir texto"
                    color: "white"
                    font.pixelSize: 18
                    font.bold: true
                }

                Label {
                    text: "Digite e arraste o texto diretamente sobre a imagem."
                    color: "#BFFFFFFF"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                

                Label {
                    text: "Fonte"
                    color: "white"
                }

                ComboBox {
                    id: fontCombo
                    Layout.fillWidth: true
                    model: Qt.fontFamilies()
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Tamanho"
                        color: "white"
                    }

                    Label {
                        text: Math.round(textSize.value) + " px"
                        color: "#BFFFFFFF"
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                    }
                }

                Slider {
                    id: textSize

                    Layout.fillWidth: true

                    from: 10
                    to: 240
                    value: 64
                    stepSize: 1
                }

                RowLayout {
                    Layout.fillWidth: true

                    Item {
                        id: textColorButton
                        property color chosenColor: "white"
                        width: 1
                        height: 1
                        visible: false
                    }

                    Label {
                        text: "Cor do texto"
                        color: "white"
                        Layout.fillWidth: true
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: [
                                "#FFFFFF",
                                "#000000",
                                "#FF3B30",
                                "#FF9500",
                                "#FFCC00",
                                "#34C759",
                                "#00C7BE",
                                "#007AFF",
                                "#5856D6",
                                "#AF52DE",
                                "#FF2D55",
                                "#8E8E93"
                            ]

                            Rectangle {
                                width: 28
                                height: 28
                                radius: 14

                                required property string modelData

                                color: modelData

                                border.width:
                                    textColorButton.chosenColor.toString().toUpperCase()
                                    === modelData
                                    ? 3 : 1

                                border.color: "white"

                                MouseArea {
                                    anchors.fill: parent

                                    onClicked:
                                        textColorButton.chosenColor =
                                            parent.color
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: 44
                        height: 28
                        radius: 5

                        color: textColorButton.chosenColor

                        border.width: 1
                        border.color: "#80FFFFFF"
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2

                    CheckBox {
                        id: textBold
                        text: "Negrito"
                    }

                    CheckBox {
                        id: textItalic
                        text: "Itálico"
                    }

                    CheckBox {
                        id: textOutline
                        text: "Contorno"
                    }

                    CheckBox {
                        id: textShadow
                        text: "Sombra"
                    }
                }

                Item {
                    id: shadowColorControl

                    property color chosenColor: "#000000"

                    Layout.fillWidth: true
                    Layout.preferredHeight: textShadow.checked
                                            ? 72 : 0

                    visible: textShadow.checked

                    Column {
                        anchors.fill: parent
                        spacing: 6

                        Label {
                            text: "Cor da sombra"
                            color: "white"
                        }

                        Flow {
                            width: parent.width
                            spacing: 6

                            Repeater {
                                model: [
                                    "#000000",
                                    "#FFFFFF",
                                    "#FF3B30",
                                    "#FF9500",
                                    "#FFCC00",
                                    "#34C759",
                                    "#00C7BE",
                                    "#007AFF",
                                    "#5856D6",
                                    "#AF52DE"
                                ]

                                Rectangle {
                                    width: 26
                                    height: 26
                                    radius: 13

                                    required property string modelData

                                    color: modelData

                                    border.width:
                                        shadowColorControl.chosenColor.toString().toUpperCase()
                                        === modelData
                                        ? 3 : 1

                                    border.color: "white"

                                    MouseArea {
                                        anchors.fill: parent

                                        onClicked:
                                            shadowColorControl.chosenColor =
                                                parent.color
                                    }
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    visible: textShadow.checked
                    Layout.fillWidth: true
                    spacing: 7

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: "Distância"
                            color: "white"
                        }

                        Label {
                            text: Math.round(shadowDistance.value) + " px"
                            color: "#BFFFFFFF"
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    Slider {
                        id: shadowDistance
                        Layout.fillWidth: true
                        from: 0
                        to: 80
                        value: 12
                        stepSize: 1
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: "Ângulo"
                            color: "white"
                        }

                        Label {
                            text: Math.round(shadowAngle.value) + "°"
                            color: "#BFFFFFFF"
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    Slider {
                        id: shadowAngle
                        Layout.fillWidth: true
                        from: 0
                        to: 360
                        value: 45
                        stepSize: 1
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: "Opacidade da sombra"
                            color: "white"
                        }

                        Label {
                            text: Math.round(shadowOpacity.value) + "%"
                            color: "#BFFFFFFF"
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    Slider {
                        id: shadowOpacity
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: 60
                        stepSize: 1
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: "Tamanho da sombra"
                            color: "white"
                        }

                        Label {
                            text: Math.round(shadowSize.value) + " px"
                            color: "#BFFFFFFF"
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    Slider {
                        id: shadowSize
                        Layout.fillWidth: true
                        from: 0
                        to: 30
                        value: 4
                        stepSize: 1
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Opacidade"
                        color: "white"
                    }

                    Label {
                        text: Math.round(textOpacity.value) + "%"
                        color: "#BFFFFFFF"
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                    }
                }

                Slider {
                    id: textOpacity

                    Layout.fillWidth: true

                    from: 10
                    to: 100
                    value: 100
                    stepSize: 1
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Rotação"
                        color: "white"
                    }

                    Label {
                        text: Math.round(textRotation.value) + "°"
                        color: "#BFFFFFFF"
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                    }
                }

                Slider {
                    id: textRotation

                    Layout.fillWidth: true

                    from: -180
                    to: 180
                    value: 0
                    stepSize: 1
                }

                MenuSeparator {
                    Layout.fillWidth: true
                }

                Button {
                    text: "Centralizar"

                    Layout.fillWidth: true

                    onClicked: {
                        root.textX =
                            Math.max(
                                0,
                                (imageController.imageWidth -
                                 textOverlay.width) / 2
                            )

                        root.textY =
                            Math.max(
                                0,
                                (imageController.imageHeight -
                                 textOverlay.height) / 2
                            )
                    }
                }

                Button {
                    text: "Aplicar texto na imagem"

                    Layout.fillWidth: true

                    enabled: imageController.hasImage
                             && textInput.text.trim().length > 0

                    onClicked: {
                        imageController.addText(
                            textInput.text,
                            fontCombo.currentText,
                            Math.round(textSize.value),
                            textColorButton.chosenColor.toString(),
                            textBold.checked,
                            textItalic.checked,
                            textOutline.checked,
                            textShadow.checked,
                            shadowColorControl.chosenColor.toString(),
                            Math.round(shadowDistance.value),
                            Math.round(shadowAngle.value),
                            Math.round(shadowOpacity.value),
                            Math.round(shadowSize.value),
                            Math.round(root.textX),
                            Math.round(root.textY),
                            Math.round(root.textBoxWidth),
                            Math.round(root.textBoxHeight),
                            textRotation.value,
                            Math.round(textOpacity.value)
                        )

                        textInput.text = ""
                    }
                }
            }
        }
    }

    


    // =========================================================
    // MINIATURAS — DOCK ARNVIEW
    // =========================================================
    Rectangle {
        id: thumbnailStrip

        property bool dockVisible: true

        function wakeDock() {
            dockVisible = true
            dockHideTimer.restart()
        }

        opacity: dockVisible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Timer {
            id: dockHideTimer
            interval: 1000
            repeat: false

            onTriggered: {
                thumbnailStrip.dockVisible = false
                thumbnailList.dockHoverActive = false
                thumbnailList.dockHoverX = -10000
            }
        }

        z: 82

        visible:
            imageController.hasImage
            && imageController.folderImageUrls.length > 1
            && root.controlsVisible

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.bottomMargin: 14

        height: 138
        radius: 0

        // Faixa invisível: miniaturas e navegação ficam flutuantes.
        color: "transparent"
        border.width: 0
        border.color: "transparent"

        Behavior on opacity {
            NumberAnimation { duration: 180 }
        }


        // -----------------------------------------------------
        // VOLTAR — GLASS
        // -----------------------------------------------------
        GlassToolButton {
            id: previousGlassButton

            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            width: 48
            height: 66

            enabled: imageController.hasImage

            background: Rectangle {
                radius: 14
                border.width: 1
                border.color:
                    previousGlassButton.hovered
                    ? "#88FFFFFF"
                    : "#44FFFFFF"

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color:
                            previousGlassButton.down
                            ? "#90313A44"
                            : previousGlassButton.hovered
                              ? "#B04A5663"
                              : "#96313A44"
                    }
                    GradientStop {
                        position: 0.48
                        color: "#88242B32"
                    }
                    GradientStop {
                        position: 1.0
                        color: "#A014181D"
                    }
                }
            }

            contentItem: Text {
                text: "‹"
                color: "white"
                font.pixelSize: 34
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                style: Text.Raised
                styleColor: "#99000000"
            }

            onClicked: {
                imageController.previous()
                root.wakeControls()
            }
        }

        // -----------------------------------------------------
        // AVANÇAR — GLASS
        // -----------------------------------------------------
        GlassToolButton {
            id: nextGlassButton

            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            width: 48
            height: 66

            enabled: imageController.hasImage

            background: Rectangle {
                radius: 14
                border.width: 1
                border.color:
                    nextGlassButton.hovered
                    ? "#88FFFFFF"
                    : "#44FFFFFF"

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color:
                            nextGlassButton.down
                            ? "#90313A44"
                            : nextGlassButton.hovered
                              ? "#B04A5663"
                              : "#96313A44"
                    }
                    GradientStop {
                        position: 0.48
                        color: "#88242B32"
                    }
                    GradientStop {
                        position: 1.0
                        color: "#A014181D"
                    }
                }
            }

            contentItem: Text {
                text: "›"
                color: "white"
                font.pixelSize: 34
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                style: Text.Raised
                styleColor: "#99000000"
            }

            onClicked: {
                imageController.next()
                root.wakeControls()
            }
        }

        ListView {
            id: thumbnailList

            property bool dockHoverActive: false
            property real dockHoverX: -10000

            anchors.left: previousGlassButton.right
            anchors.right: nextGlassButton.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            anchors.leftMargin: 9
            anchors.rightMargin: 9
            anchors.topMargin: 34
            anchors.bottomMargin: 8

            orientation: ListView.Horizontal
            spacing: 7

            // O efeito Dock precisa ultrapassar a altura normal
            // das miniaturas sem ser cortado.
            clip: false

            model: imageController.folderImageUrls
            currentIndex: imageController.currentIndex

            cacheBuffer: 900
            reuseItems: true

            boundsBehavior: Flickable.StopAtBounds
            flickDeceleration: 2200
            maximumFlickVelocity: 4500

            delegate: Item {
                id: thumbDelegate

                required property int index
                required property string modelData

                width: 68
                height: 58

                property real dockDistance:
                    Math.abs(
                        (x + width / 2)
                        - thumbnailList.dockHoverX
                    )

                property real dockScale:
                    !thumbnailList.dockHoverActive
                    ? 1.0
                    : 1.0
                      + 0.78
                        * Math.exp(
                            -Math.pow(
                                dockDistance / 95.0,
                                2
                            )
                        )

                scale: dockScale
                transformOrigin: Item.Bottom

                z: Math.round(scale * 100)

                Behavior on scale {
                    NumberAnimation {
                        duration: 145
                        easing.type: Easing.OutCubic
                    }
                }

                Image {
                    id: thumbnailImage

                    anchors.fill: parent

                    source: modelData
                    fillMode: Image.PreserveAspectFit

                    asynchronous: true
                    cache: true
                    smooth: true
                    mipmap: true

                    sourceSize.width: 176
                    sourceSize.height: 148
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        thumbnailList.dockHoverActive = true
                        thumbnailList.dockHoverX =
                            thumbDelegate.x + mouseX

                        root.wakeControls()
                    }

                    onPositionChanged: mouse => {
                        thumbnailList.dockHoverActive = true
                        thumbnailList.dockHoverX =
                            thumbDelegate.x + mouse.x

                        root.wakeControls()
                    }

                    onExited: {
                        thumbnailList.dockHoverActive = false
                        thumbnailList.dockHoverX = -10000
                    }

                    onClicked: {
                        imageController.openFolderImage(index)
                        root.wakeControls()
                    }
                }
            }

            WheelHandler {
                id: thumbnailWheel
                target: null

                onWheel: event => {
                    var delta = 0

                    if (Math.abs(event.pixelDelta.x)
                            > Math.abs(event.pixelDelta.y)) {
                        delta = event.pixelDelta.x
                    } else if (event.pixelDelta.y !== 0) {
                        delta = event.pixelDelta.y
                    } else if (event.angleDelta.x !== 0) {
                        delta = event.angleDelta.x / 3
                    } else {
                        delta = event.angleDelta.y / 3
                    }

                    var maxX =
                        Math.max(
                            0,
                            thumbnailList.contentWidth
                            - thumbnailList.width
                        )

                    thumbnailList.contentX =
                        Math.max(
                            0,
                            Math.min(
                                maxX,
                                thumbnailList.contentX - delta
                            )
                        )

                    event.accepted = true
                    root.wakeControls()
                }
            }

            onCurrentIndexChanged: {
                if (currentIndex >= 0) {
                    positionViewAtIndex(
                        currentIndex,
                        ListView.Center
                    )
                }
            }
        }
    }

    // =========================================================
    // BARRA SUPERIOR — ARNVIEW GLASS
    // =========================================================
    Rectangle {
        id: toolbar

        z: 90

        opacity: root.controlsVisible ? 1 : 0
        enabled: opacity > 0.1

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 18

        height: 50
        width: controlsRow.implicitWidth + 34

        radius: 15

        border.width: 1
        border.color: "#55FFFFFF"

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#B04C5660"
            }
            GradientStop {
                position: 0.18
                color: "#9A37414B"
            }
            GradientStop {
                position: 0.52
                color: "#92242B32"
            }
            GradientStop {
                position: 1.0
                color: "#B015191E"
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 220 }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.topMargin: 1

            height: 1
            color: "#88FFFFFF"
            opacity: 0.65
        }

        RowLayout {
            id: controlsRow

            anchors.centerIn: parent
            spacing: 3

            GlassToolButton {
                text: "Abrir"
                onClicked: root.openImageDialog()
            }


            ToolSeparator {}

            GlassToolButton {
                text: "−"
                font.pixelSize: 20
                onClicked:
                    root.zoom =
                        Math.max(
                            0.02,
                            root.zoom / 1.2
                        )
            }

            Label {
                Layout.minimumWidth: 55

                horizontalAlignment:
                    Text.AlignHCenter

                text:
                    Math.round(root.zoom * 100)
                    + "%"

                color: "white"

                style: Text.Raised
                styleColor: "#88000000"
            }

            GlassToolButton {
                text: "+"
                font.pixelSize: 20

                onClicked:
                    root.zoom =
                        Math.min(
                            32,
                            root.zoom * 1.2
                        )
            }


            GlassToolButton {
                text: "1:1"
                onClicked: root.actualSize()
            }

            ToolSeparator {}

            GlassToolButton {
                text: "↻"
                font.pixelSize: 20
                onClicked:
                    imageController.rotateRight()
            }

            GlassToolButton {
                text: "Editar"
                enabled: imageController.hasImage

                onClicked: {
                    if (root.editorVisible) {
                        imageController.cancelAdjustments()
                        root.editorVisible = false
                    }

                    root.aiPanelVisible = false
                    root.textPanelVisible = false
                    root.lamaBrushMode = false

                    arnEditorWindow.openEditor()

                    root.wakeControls()
                }
            }

            GlassToolButton {
                text:
                    root.fullScreenMode
                    ? "Janela"
                    : "Tela cheia"

                onClicked:
                    root.toggleFullScreen()
            }

            GlassToolButton {
                text: "Fechar"
                onClicked: root.close()
            }
        }
    }

    Dialog {
        id: aboutDialog
        title: "Sobre o ArnView"
        modal: true
        anchors.centerIn: parent
        width: 500

        ColumnLayout {
            anchors.fill: parent
            spacing: 12

            Label {
                text: "ArnView"
                font.pixelSize: 28
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "Versão 0.4.0"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "Visualizador e editor de imagens para macOS Intel."
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Label {
                text: "Desenvolvido por Alessandro Henriques Teixeira — Studio Arn"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Label {
                text: "© 2026 Studio Arn"
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Label {
                text: "Recursos locais de edição, OCR e inteligência artificial."
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            DialogButtonBox {
                standardButtons: DialogButtonBox.Ok
                Layout.fillWidth: true
                onAccepted: aboutDialog.close()
            }
        }
    }

    Dialog {
        id: creditsDialog
        title: "Créditos"
        modal: true
        anchors.centerIn: parent
        width: 520

        ColumnLayout {
            anchors.fill: parent

            Label {
                text: "ArnView 0.4.0\n\nDesenvolvimento:\nAlessandro Henriques Teixeira — Studio Arn\n\nTecnologias e componentes:\nQt 6 · OpenCV · Tesseract OCR · Real-ESRGAN · LaMa · rembg\n\nOs componentes de terceiros permanecem sob suas respectivas licenças."
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            DialogButtonBox {
                standardButtons: DialogButtonBox.Ok
                Layout.fillWidth: true
                onAccepted: creditsDialog.close()
            }
        }
    }

    Dialog {
        id: licensesDialog
        title: "Licenças"
        modal: true
        anchors.centerIn: parent
        width: 540

        ColumnLayout {
            anchors.fill: parent

            Label {
                text: "O código original do ArnView segue a licença definida no arquivo LICENSE distribuído com o aplicativo.\n\nQt, OpenCV, Tesseract, Real-ESRGAN, LaMa, rembg e demais componentes de terceiros mantêm suas próprias licenças e avisos legais."
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            DialogButtonBox {
                standardButtons: DialogButtonBox.Ok
                Layout.fillWidth: true
                onAccepted: licensesDialog.close()
            }
        }
    }

    FileDialog {
        id: openDialog
        title: "Abrir imagem"
        currentFolder: StandardPaths.writableLocation(
            StandardPaths.PicturesLocation
        )
        nameFilters: ["Imagens (*.jpg *.jpeg *.png *.webp *.bmp *.gif *.tif *.tiff *.heic *.heif)", "Todos os arquivos (*)"]
        onAccepted: imageController.openUrl(selectedFile)
    }

    FileDialog {
        id: saveDialog
        title: "Salvar imagem como"
        fileMode: FileDialog.SaveFile
        defaultSuffix: "png"
        nameFilters: ["PNG (*.png)", "JPEG (*.jpg *.jpeg)", "WebP (*.webp)", "TIFF (*.tif *.tiff)"]
        onAccepted: imageController.saveAs(selectedFile)
    }

    Dialog {
        id: errorDialog
        title: "ArnView"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok
        property string message: ""
        Label { text: errorDialog.message; wrapMode: Text.WordWrap; width: Math.min(480, root.width - 100) }
    }

    Connections {
        target: imageController
        function onErrorOccurred(message) { errorDialog.message = message; errorDialog.open() }
        function onFileChanged() {
            root.pendingFit = true

            root.textX =
                imageController.imageWidth * 0.15

            root.textY =
                imageController.imageHeight * 0.18
        }
        function onLamaMaskCleared() {
            if (typeof lamaCanvas !== "undefined")
                lamaCanvas.clearMask()
        }
    }

    Timer {
        id: hideTimer
        interval: 2600
        running: true
        onTriggered: root.controlsVisible = false
    }

    Timer {
        id: adjustmentPreviewTimer
        interval: 45
        repeat: false
        onTriggered: root.previewAdjustments()
    }

    Shortcut {
        sequence: StandardKey.Open
        onActivated: root.openImageDialog()
    }
    Shortcut { sequence: "Escape"; onActivated: root.close() }
    Shortcut { sequence: "Right"; onActivated: imageController.next() }
    Shortcut { sequence: "Left"; onActivated: imageController.previous() }
    Shortcut { sequence: "Space"; onActivated: root.fitImage() }
    Shortcut { sequence: "0"; onActivated: root.fitImage() }
    Shortcut { sequence: "1"; onActivated: root.actualSize() }
    Shortcut { sequence: "+"; onActivated: root.zoom = Math.min(32, root.zoom * 1.2) }
    Shortcut { sequence: "-"; onActivated: root.zoom = Math.max(0.02, root.zoom / 1.2) }
    Shortcut { sequence: "R"; onActivated: imageController.rotateRight() }
    Shortcut { sequence: "F"; onActivated: root.toggleFullScreen() }
    Shortcut { sequence: StandardKey.Undo; onActivated: imageController.undo() }
    Shortcut { sequence: StandardKey.Redo; onActivated: imageController.redo() }

    Component.onCompleted: {
        x = Math.round((Screen.width - width) / 2)
        y = Math.round((Screen.height - height) / 2)
        wakeControls()
    }
}
