import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs

Window {

    palette.window: editorWindow.arnBackground
    palette.windowText: editorWindow.arnText
    palette.buttonText: editorWindow.arnText
    palette.text: editorWindow.arnText

    id: editorWindow

    visible: false
    width: 1280
    height: 820
    minimumWidth: 900
    minimumHeight: 600

    color: "#101010"

    title: imageController.currentName.length
           ? imageController.currentName + " — ArnView Editor"
           : "ArnView Editor"

    property string activeTool: "ajustes"


    FileDialog {
        id: editorSaveAsDialog
        title: "Salvar imagem como…"
        fileMode: FileDialog.SaveFile
        nameFilters: [
            "Imagens (*.png *.jpg *.jpeg *.webp *.bmp)",
            "PNG (*.png)",
            "JPEG (*.jpg *.jpeg)",
            "WebP (*.webp)",
            "Todos os arquivos (*)"
        ]

        onAccepted: {
            imageController.saveAs(selectedFile)
        }
    }


    // ========================================================
    // APARÊNCIA ARNVIEW
    // ========================================================

    property string arnTheme: "dark"

    property color arnGold: "#E9A820"

    property color arnText:
        arnTheme === "light"
        ? "#20252A"
        : "#F2F4F6"

    property color arnMutedText:
        arnTheme === "light"
        ? "#626A72"
        : "#B8C0C8"

    property color arnBackground:
        arnTheme === "light"
        ? "#E5E7E9"
        : "#111315"

    property color arnPanel:
        arnTheme === "light"
        ? "#D9DDE1"
        : "#16191C"

    property color arnBorder:
        arnTheme === "light"
        ? "#88939D"
        : "#4A5661"


    property color arnChromeTop:
        arnTheme === "light"
        ? "#D5D9DD"
        : "#171A1D"

    property color arnChromeBottom:
        arnTheme === "light"
        ? "#D5D9DD"
        : "#171A1D"


    property color arnGlassTop:
        arnTheme === "light"
        ? "#DDECF4FA"
        : "#B04A5663"

    property color arnGlassBottom:
        arnTheme === "light"
        ? "#C8BFC6CC"
        : "#B01C2228"


    property real editorZoom: 1.0

    property bool lamaBrushMode: false
    property real lamaBrushSize: 60

    property real textX: imageController.imageWidth * 0.20
    property real textY: imageController.imageHeight * 0.20
    property real textBoxWidth: Math.min(500, imageController.imageWidth * 0.60)
    property real textBoxHeight: Math.min(180, imageController.imageHeight * 0.20)

    // --------------------------------------------------------
    // ABRIR
    // --------------------------------------------------------

    function openEditor() {
        activeTool = "ajustes"
        editorZoom = 1.0
        lamaBrushMode = false

        resetAdjustmentSliders()
        imageController.beginAdjustments()

        visible = true
        showMaximized()
        raise()
        requestActivate()
    }

    function closeEditor() {
        adjustmentTimer.stop()
        imageController.commitAdjustments()
        lamaBrushMode = false
        visible = false
    }

    function chooseTool(name) {
        adjustmentTimer.stop()

        if (activeTool === "ajustes" && name !== "ajustes")
            imageController.commitAdjustments()

        activeTool = name
        lamaBrushMode = (name === "remover")

        if (name === "ajustes") {
            resetAdjustmentSliders()
            imageController.beginAdjustments()
        }

        if (name === "texto") {
            lamaBrushMode = false

            textBoxWidth =
                Math.min(
                    500,
                    Math.max(220, imageController.imageWidth * 0.55)
                )

            textBoxHeight =
                Math.min(
                    180,
                    Math.max(100, imageController.imageHeight * 0.18)
                )

            textX = Math.max(
                0,
                (imageController.imageWidth - textBoxWidth) / 2
            )

            textY = Math.max(
                0,
                (imageController.imageHeight - textBoxHeight) / 2
            )

            Qt.callLater(function() {
                textInput.forceActiveFocus()
            })
        }
    }

    function resetAdjustmentSliders() {
        brightnessSlider.value = 0
        contrastSlider.value = 0
        saturationSlider.value = 0
        temperatureSlider.value = 0
        tintSlider.value = 0
        monoSlider.value = 0
        sepiaSlider.value = 0
    }

    function previewAdjustments() {
        imageController.previewAdjustments(
            Math.round(brightnessSlider.value),
            Math.round(contrastSlider.value),
            Math.round(saturationSlider.value),
            Math.round(temperatureSlider.value),
            Math.round(tintSlider.value),
            Math.round(monoSlider.value),
            Math.round(sepiaSlider.value)
        )
    }

    Timer {
        id: adjustmentTimer
        interval: 35
        repeat: false
        onTriggered: editorWindow.previewAdjustments()
    }

    Shortcut {
        sequence: StandardKey.Cancel
        onActivated: editorWindow.closeEditor()
    }

    // Mantém a máscara visual sincronizada com a máscara real do C++.
    Connections {
        target: imageController

        function onLamaMaskCleared() {
            lamaPaint.clearMask()
        }
    }

    // ========================================================
    // FUNDO
    // ========================================================

    Rectangle {
        anchors.fill: parent
        color: "#101010"
    }

    // ========================================================
    // CABEÇALHO
    // ========================================================

    Rectangle {
        id: topBar

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: 58

        color: editorWindow.arnChromeTop

        RowLayout {

            
            
                        anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            spacing: 10

            Label {
                text: "ArnView Editor"
                color: editorWindow.arnGold
                font.pixelSize: 20
                font.bold: true
            }

            Label {
                text: imageController.currentName
                color: editorWindow.arnTheme === "light" ? "#59636C" : "#BFFFFFFF"
                elide: Text.ElideMiddle
                Layout.fillWidth: true
            }
            GlassButton {
                text:
                    editorWindow.arnTheme === "dark"
                    ? "☀ Claro"
                    : "☾ Escuro"

                onClicked: {
                    editorWindow.arnTheme =
                        editorWindow.arnTheme === "dark"
                        ? "light"
                        : "dark"
                }
            }



            GlassButton {
                text: "Desfazer"
                enabled: imageController.canUndo
                onClicked: imageController.undo()
            }

            GlassButton {
                text: "Refazer"
                enabled: imageController.canRedo
                onClicked: imageController.redo()
            }

            GlassButton {
                text: "Original"
                enabled: imageController.hasImage
                onClicked: imageController.reset()
            }

            GlassButton {
                text: "Salvar como…"
                enabled: imageController.hasImage
                onClicked: editorSaveAsDialog.open()
            }

            GlassButton {
                text: "Fechar"
                onClicked: editorWindow.closeEditor()
            }
        }
    }

    // ========================================================
    // FERRAMENTAS
    // ========================================================

    Rectangle {
        id: toolsPanel

        anchors.top: topBar.bottom
        anchors.bottom: bottomBar.top
        anchors.left: parent.left

        width: 176

        color:
            editorWindow.arnTheme === "light"
            ? "#E7EAED"
            : editorWindow.arnPanel

        border.color:
            editorWindow.arnTheme === "light"
            ? "#A5ADB5"
            : editorWindow.arnBorder

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            Label {
                text: "FERRAMENTAS"
                color: editorWindow.arnGold
                font.bold: true
                Layout.bottomMargin: 7
            }

            GlassButton {
                text: "Ajustes"
                Layout.fillWidth: true
                checkable: true
                checked: editorWindow.activeTool === "ajustes"
                onClicked: editorWindow.chooseTool("ajustes")
            }

            GlassButton {
                text: "Texto"
                Layout.fillWidth: true
                checkable: true
                checked: editorWindow.activeTool === "texto"
                onClicked: editorWindow.chooseTool("texto")
            }

            GlassButton {
                text: "Recorte"
                Layout.fillWidth: true
                checkable: true
                checked: editorWindow.activeTool === "recorte"
                onClicked: editorWindow.chooseTool("recorte")
            }

            GlassButton {
                text: "IA"
                Layout.fillWidth: true
                checkable: true
                checked: editorWindow.activeTool === "ia"
                onClicked: editorWindow.chooseTool("ia")
            }

            Item {
                Layout.fillHeight: true
            }

            Label {
                text: imageController.aiStatus
                visible: imageController.aiStatus.length > 0
                color: editorWindow.arnMutedText
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            BusyIndicator {
                visible: imageController.aiBusy
                running: visible
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // ========================================================
    // PROPRIEDADES
    // ========================================================

    Rectangle {
        id: propertiesPanel

        anchors.top: topBar.bottom
        anchors.bottom: bottomBar.top
        anchors.right: parent.right

        width:
            Math.max(
                270,
                Math.min(
                    310,
                    editorWindow.width * 0.235
                )
            )

        color:
            editorWindow.arnTheme === "light"
            ? "#E7EAED"
            : editorWindow.arnPanel

        border.color:
            editorWindow.arnTheme === "light"
            ? "#A5ADB5"
            : editorWindow.arnBorder

        ScrollView {
            anchors.fill: parent

            anchors.leftMargin: 12
            anchors.rightMargin: 16
            anchors.topMargin: 10
            anchors.bottomMargin: 10

            clip: true

            ColumnLayout {
                width:
                    Math.max(
                        220,
                        propertiesPanel.width - 34
                    )

                spacing: 7

                // =================================================
                // AJUSTES
                // =================================================

                ColumnLayout {
                    visible: editorWindow.activeTool === "ajustes"
                    Layout.fillWidth: true
                    spacing: 6

                    Label {
                        text: "AJUSTES"
                        color: editorWindow.arnGold
                        font.bold: true
                        font.pixelSize: 18
                    }

                    GlassButton {
                        text: "Melhoria automática"
                        Layout.fillWidth: true
                        onClicked: {
                            imageController.cancelAdjustments()
                            editorWindow.resetAdjustmentSliders()
                            imageController.autoImprove()
                            imageController.beginAdjustments()
                        }
                    }

                    Label {
                        text: "Brilho  " + Math.round(brightnessSlider.value)
                        color: editorWindow.arnText
                    }

                    Slider {
                        id: brightnessSlider
                        from: -100
                        to: 100
                        value: 0
                        stepSize: 1
                        Layout.fillWidth: true
                        onMoved: adjustmentTimer.restart()
                    }

                    Label {
                        text: "Contraste  " + Math.round(contrastSlider.value)
                        color: editorWindow.arnText
                    }

                    Slider {
                        id: contrastSlider
                        from: -100
                        to: 100
                        value: 0
                        stepSize: 1
                        Layout.fillWidth: true
                        onMoved: adjustmentTimer.restart()
                    }

                    Label {
                        text: "Saturação  " + Math.round(saturationSlider.value)
                        color: editorWindow.arnText
                    }

                    Slider {
                        id: saturationSlider
                        from: -100
                        to: 100
                        value: 0
                        stepSize: 1
                        Layout.fillWidth: true
                        onMoved: adjustmentTimer.restart()
                    }

                    Label {
                        text: "Temperatura  " + Math.round(temperatureSlider.value)
                        color: editorWindow.arnText
                    }

                    Slider {
                        id: temperatureSlider
                        from: -100
                        to: 100
                        value: 0
                        stepSize: 1
                        Layout.fillWidth: true
                        onMoved: adjustmentTimer.restart()
                    }

                    Label {
                        text: "Matiz  " + Math.round(tintSlider.value)
                        color: editorWindow.arnText
                    }

                    Slider {
                        id: tintSlider
                        from: -100
                        to: 100
                        value: 0
                        stepSize: 1
                        Layout.fillWidth: true
                        onMoved: adjustmentTimer.restart()
                    }

                    Label {
                        text: "Preto e branco  "
                              + Math.round(monoSlider.value)
                              + "%"
                        color: editorWindow.arnText
                    }

                    Slider {
                        id: monoSlider
                        from: 0
                        to: 100
                        value: 0
                        stepSize: 1
                        Layout.fillWidth: true
                        onMoved: adjustmentTimer.restart()
                    }

                    Label {
                        text: "Sépia  "
                              + Math.round(sepiaSlider.value)
                              + "%"
                        color: editorWindow.arnText
                    }

                    Slider {
                        id: sepiaSlider
                        from: 0
                        to: 100
                        value: 0
                        stepSize: 1
                        Layout.fillWidth: true
                        onMoved: adjustmentTimer.restart()
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        GlassButton {
                            text: "Aplicar"
                            Layout.fillWidth: true

                            onClicked: {
                                adjustmentTimer.stop()
                                editorWindow.previewAdjustments()
                                imageController.commitAdjustments()
                                editorWindow.resetAdjustmentSliders()
                                imageController.beginAdjustments()
                            }
                        }

                        GlassButton {
                            text: "Cancelar"

                            onClicked: {
                                adjustmentTimer.stop()
                                imageController.cancelAdjustments()
                                editorWindow.resetAdjustmentSliders()
                                imageController.beginAdjustments()
                            }
                        }
                    }

                    MenuSeparator {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "Transformar"
                        color: editorWindow.arnText
                        font.bold: true
                    }

                    RowLayout {
                        GlassButton {
                            text: "↶ 90°"
                            onClicked: imageController.rotateLeft()
                        }

                        GlassButton {
                            text: "↷ 90°"
                            onClicked: imageController.rotateRight()
                        }
                    }

                    GlassButton {
                        text: "Espelhar horizontal"
                        Layout.fillWidth: true
                        onClicked: imageController.flipHorizontal()
                    }

                    GlassButton {
                        text: "Espelhar vertical"
                        Layout.fillWidth: true
                        onClicked: imageController.flipVertical()
                    }
                }

                // =================================================
                // TEXTO
                // =================================================

                ColumnLayout {
                    visible: editorWindow.activeTool === "texto"
                    Layout.fillWidth: true
                    spacing: 6

                    Label {
                        text: "TEXTO"
                        color: editorWindow.arnGold
                        font.pixelSize: 18
                        font.bold: true
                    }

                    Label {
                        text: "Digite diretamente sobre a imagem."
                        color: editorWindow.arnTheme === "light" ? "#59636C" : "#BFFFFFFF"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "Fonte"
                        color: editorWindow.arnText
                    }

                    ComboBox {
                        id: fontCombo
                        Layout.fillWidth: true
                        model: Qt.fontFamilies()
                    }

                    Label {
                        text: "Tamanho  " + Math.round(textSize.value)
                        color: editorWindow.arnText
                    }

                    Slider {
                        id: textSize
                        from: 10
                        to: 240
                        value: 64
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "Cor"
                        color: editorWindow.arnText
                    }

                    Item {
                        id: textColor
                        property color chosenColor: "white"
                        width: 1
                        height: 1
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
                                "#FF2D55"
                            ]

                            Rectangle {
                                required property string modelData

                                width: 27
                                height: 27
                                radius: 14
                                color: modelData

                                border.width:
                                    textColor.chosenColor.toString().toUpperCase()
                                    === modelData ? 3 : 1

                                border.color: editorWindow.arnText

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked:
                                        textColor.chosenColor = parent.color
                                }
                            }
                        }
                    }

                    RowLayout {
                        CheckBox {
                            id: textBold
                            text: "Negrito"
                        }

                        CheckBox {
                            id: textItalic
                            text: "Itálico"
                        }
                    }

                    CheckBox {
                        id: textOutline
                        text: "Contorno"
                    }

                    ColumnLayout {
                        visible: textOutline.checked
                        Layout.fillWidth: true

                        Label {
                            text: "Espessura do contorno  "
                                  + Math.round(outlineSize.value)
                        }

                        Slider {
                            id: outlineSize
                            from: 1
                            to: 40
                            value: 4
                            Layout.fillWidth: true
                        }
                    }

                    CheckBox {
                        id: textShadow
                        text: "Sombra"
                    }

                    Item {
                        id: shadowColor
                        property color chosenColor: "#000000"
                        width: 1
                        height: 1
                    }

                    ColumnLayout {
                        visible: textShadow.checked
                        Layout.fillWidth: true

                        Label {
                            text: "Distância  "
                                  + Math.round(shadowDistance.value)
                        }

                        Slider {
                            id: shadowDistance
                            from: 0
                            to: 150
                            value: 12
                            Layout.fillWidth: true
                        }

                        Label {
                            text: "Ângulo  "
                                  + Math.round(shadowAngle.value)
                                  + "°"
                        }

                        Slider {
                            id: shadowAngle
                            from: 0
                            to: 360
                            value: 45
                            Layout.fillWidth: true
                        }

                        Label {
                            text: "Expansão  "
                                  + Math.round(shadowSize.value)
                        }

                        Slider {
                            id: shadowSize
                            from: 0
                            to: 100
                            value: 8
                            Layout.fillWidth: true
                        }

                        Label {
                            text: "Opacidade da sombra  "
                                  + Math.round(shadowOpacity.value)
                                  + "%"
                        }

                        Slider {
                            id: shadowOpacity
                            from: 0
                            to: 100
                            value: 60
                            Layout.fillWidth: true
                        }
                    }

                    Label {
                        text: "Opacidade  "
                              + Math.round(textOpacity.value)
                              + "%"
                    }

                    Slider {
                        id: textOpacity
                        from: 10
                        to: 100
                        value: 100
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "Rotação  "
                              + Math.round(textRotation.value)
                              + "°"
                    }

                    Slider {
                        id: textRotation
                        from: -180
                        to: 180
                        value: 0
                        Layout.fillWidth: true
                    }

                    GlassButton {
                        text: "Centralizar"
                        Layout.fillWidth: true

                        onClicked: {
                            editorWindow.textX =
                                Math.max(
                                    0,
                                    (imageController.imageWidth
                                     - editorWindow.textBoxWidth) / 2
                                )

                            editorWindow.textY =
                                Math.max(
                                    0,
                                    (imageController.imageHeight
                                     - editorWindow.textBoxHeight) / 2
                                )
                        }
                    }

                    GlassButton {
                        text: "Aplicar texto"
                        Layout.fillWidth: true

                        enabled:
                            textInput.text.trim().length > 0

                        onClicked: {
                            imageController.addText(
                                textInput.text,
                                fontCombo.currentText,
                                Math.round(textSize.value),
                                textColor.chosenColor.toString(),
                                textBold.checked,
                                textItalic.checked,
                                textOutline.checked,
                                Math.round(outlineSize.value),
                                textShadow.checked,
                                shadowColor.chosenColor.toString(),
                                Math.round(shadowDistance.value),
                                Math.round(shadowAngle.value),
                                Math.round(shadowOpacity.value),
                                Math.round(shadowSize.value),
                                Math.round(editorWindow.textX),
                                Math.round(editorWindow.textY),
                                Math.round(editorWindow.textBoxWidth),
                                Math.round(editorWindow.textBoxHeight),
                                textRotation.value,
                                Math.round(textOpacity.value)
                            )

                            textInput.text = ""
                        }
                    }
                }

                // =================================================
                // REMOVER OBJETOS
                // =================================================



                // =================================================
                // FUNDO
                // =================================================



                // =================================================
                // IA
                // =================================================


                ColumnLayout {
                    visible: editorWindow.activeTool === "ia-remover"
                    Layout.fillWidth: true
                    spacing: 7

                    Label {
                        text: "REMOVER OBJETO"
                        color: editorWindow.arnTheme === "light" ? "#247A3E" : "#79E08B"
                        font.bold: true
                        font.pixelSize: 18
                    }

                    GlassButton {
                        text: "← Voltar para IA"
                        Layout.fillWidth: true

                        onClicked: {
                            editorWindow.activeTool = "ia"
                            editorWindow.lamaBrushMode = false
                        }
                    }

                    Label {
                        text:
                            "Pinte de vermelho sobre aquilo que deseja remover."
                        color: editorWindow.arnMutedText
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Label {
                        text:
                            "Pincel  "
                            + Math.round(
                                editorWindow.lamaBrushSize
                            )
                            + " px"
                        color: editorWindow.arnText
                    }

                    Slider {
                        from: 6
                        to: 180
                        value: editorWindow.lamaBrushSize
                        Layout.fillWidth: true

                        onMoved:
                            editorWindow.lamaBrushSize =
                                value
                    }

                    GlassButton {
                        text: "Limpar seleção"
                        Layout.fillWidth: true

                        onClicked: {
                            imageController.clearLamaMask()
                            lamaPaint.clearMask()
                        }
                    }

                    GlassButton {
                        text: imageController.aiBusy
                              ? "Processando…"
                              : "Remover seleção"

                        Layout.fillWidth: true

                        enabled:
                            imageController.hasImage
                            && !imageController.aiBusy

                        onClicked:
                            imageController.runLamaMask()
                    }
                }


                ColumnLayout {
                    visible: editorWindow.activeTool === "recorte"
                    Layout.fillWidth: true
                    spacing: 7

                    Label {
                        text: "RECORTE INTELIGENTE"
                        color: editorWindow.arnGold
                        font.bold: true
                        font.pixelSize: 18
                    }

                    Label {
                        text:
                            "O ArnView procura o rosto principal e enquadra automaticamente."
                        color: editorWindow.arnMutedText
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    GlassButton {
                        text: "Retrato 4:5"
                        Layout.fillWidth: true
                        enabled: !imageController.aiBusy

                        onClicked:
                            imageController.runVisionAi(
                                "crop",
                                "4:5"
                            )
                    }

                    GlassButton {
                        text: "Quadrado 1:1"
                        Layout.fillWidth: true
                        enabled: !imageController.aiBusy

                        onClicked:
                            imageController.runVisionAi(
                                "crop",
                                "1:1"
                            )
                    }

                    GlassButton {
                        text: "Paisagem 16:9"
                        Layout.fillWidth: true
                        enabled: !imageController.aiBusy

                        onClicked:
                            imageController.runVisionAi(
                                "crop",
                                "16:9"
                            )
                    }

                    GlassButton {
                        text: "Stories / Reels 9:16"
                        Layout.fillWidth: true
                        enabled: !imageController.aiBusy

                        onClicked:
                            imageController.runVisionAi(
                                "crop",
                                "9:16"
                            )
                    }
                }

                ColumnLayout {
                    visible: editorWindow.activeTool === "ia"
                    Layout.fillWidth: true
                    spacing: 7

                    Label {
                        text: "INTELIGÊNCIA ARTIFICIAL"
                        color: editorWindow.arnTheme === "light" ? "#247A3E" : "#79E08B"
                        font.bold: true
                        font.pixelSize: 18
                    }

                    Label {
                        text: "Local • Offline • Sem créditos"
                        color: editorWindow.arnMutedText
                    }

                    MenuSeparator {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "Remoção"
                        color: editorWindow.arnText
                        font.bold: true
                    }

                    GlassButton {
                        text: "Remover objeto"
                        Layout.fillWidth: true

                        onClicked: {
                            editorWindow.activeTool =
                                "ia-remover"

                            editorWindow.lamaBrushMode =
                                true
                        }
                    }

                    GlassButton {
                        text: imageController.aiBusy
                              ? "Processando…"
                              : "Remover fundo"

                        Layout.fillWidth: true

                        enabled:
                            imageController.hasImage
                            && !imageController.aiBusy

                        onClicked:
                            imageController.runRemoveBackground()
                    }

                    MenuSeparator {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "Melhorar imagem"
                        color: editorWindow.arnText
                        font.bold: true
                    }

                    GlassButton {
                        text: "Melhoria inteligente"
                        Layout.fillWidth: true
                        enabled: !imageController.aiBusy

                        onClicked:
                            imageController.runVisionAi(
                                "auto",
                                ""
                            )
                    }

                    GlassButton {
                        text: "Reduzir ruído"
                        Layout.fillWidth: true
                        enabled: !imageController.aiBusy

                        onClicked:
                            imageController.runVisionAi(
                                "denoise",
                                ""
                            )
                    }

                    GlassButton {
                        text: "Clarear foto escura"
                        Layout.fillWidth: true
                        enabled: !imageController.aiBusy

                        onClicked:
                            imageController.runVisionAi(
                                "lowlight",
                                ""
                            )
                    }

                    GlassButton {
                        text: "Restaurar fotografia"
                        Layout.fillWidth: true
                        enabled: !imageController.aiBusy

                        onClicked:
                            imageController.runVisionAi(
                                "restore",
                                ""
                            )
                    }

                    MenuSeparator {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "Rostos"
                        color: editorWindow.arnText
                        font.bold: true
                    }

                    GlassButton {
                        text: "Melhorar rostos"
                        Layout.fillWidth: true
                        enabled: !imageController.aiBusy

                        onClicked:
                            imageController.runVisionAi(
                                "face",
                                ""
                            )
                    }

                    GlassButton {
                        text: "Desfocar rostos"
                        Layout.fillWidth: true
                        enabled: !imageController.aiBusy

                        onClicked:
                            imageController.runVisionAi(
                                "blurfaces",
                                ""
                            )
                    }

                    MenuSeparator {
                        Layout.fillWidth: true
                    }

                    MenuSeparator {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "Texto e organização"
                        color: editorWindow.arnText
                        font.bold: true
                    }

                    GlassButton {
                        text: imageController.aiBusy
                              ? "Processando…"
                              : "Extrair texto da imagem (OCR)"

                        Layout.fillWidth: true
                        enabled: !imageController.aiBusy

                        onClicked:
                            imageController.runVisionText(
                                "ocr",
                                ""
                            )
                    }

                    GlassButton {
                        text: "Buscar imagens semelhantes"
                        Layout.fillWidth: true
                        enabled: !imageController.aiBusy

                        onClicked:
                            similarFolderDialog.open()
                    }

                    Label {
                        visible:
                            imageController.aiTextResult.length > 0

                        text:
                            "RESULTADO"

                        color: editorWindow.arnGold
                        font.bold: true
                    }

                    TextArea {
                        id: aiResultBox

                        visible:
                            imageController.aiTextResult.length > 0

                        Layout.fillWidth: true
                        Layout.preferredHeight: 180

                        readOnly: true
                        wrapMode: TextEdit.Wrap

                        text:
                            imageController.aiTextResult

                        selectByMouse: true
                    }

                    RowLayout {
                        visible:
                            imageController.aiTextResult.length > 0

                        Layout.fillWidth: true

                        GlassButton {
                            text: "Copiar"
                            Layout.fillWidth: true

                            onClicked: {
                                aiResultBox.selectAll()
                                aiResultBox.copy()
                                aiResultBox.deselect()
                            }
                        }

                        GlassButton {
                            text: "Limpar"

                            onClicked:
                                imageController.clearAiTextResult()
                        }
                    }

                    Label {
                        text: "Super-resolução"
                        color: editorWindow.arnText
                        font.bold: true
                    }

                    GlassButton {
                        text: "Aumentar resolução 2×"
                        Layout.fillWidth: true
                        enabled: !imageController.aiBusy

                        onClicked:
                            imageController.runVisionAi(
                                "upscale",
                                "2"
                            )
                    }

                    GlassButton {
                        text: "Aumentar resolução 4×"
                        Layout.fillWidth: true
                        enabled: !imageController.aiBusy

                        onClicked:
                            imageController.runVisionAi(
                                "upscale",
                                "4"
                            )
                    }
                }
            }
        }
    }

    // ========================================================
    // CANVAS
    // ========================================================

    Rectangle {
        id: canvas

        anchors.top: topBar.bottom
        anchors.bottom: bottomBar.top
        anchors.left: toolsPanel.right
        anchors.right: propertiesPanel.left

        color: "#0B0B0B"
        clip: true

        Item {
            id: imageArea

            anchors.centerIn: parent

            property real scaleFactor:
                Math.min(
                    (canvas.width - 50)
                    / Math.max(1, imageController.imageWidth),

                    (canvas.height - 50)
                    / Math.max(1, imageController.imageHeight),

                    1.0
                ) * editorWindow.editorZoom

            width:
                Math.max(
                    1,
                    imageController.imageWidth * scaleFactor
                )

            height:
                Math.max(
                    1,
                    imageController.imageHeight * scaleFactor
                )

            Image {
                id: editorImage

                anchors.fill: parent

                source: imageController.displayUrl

                cache: false
                asynchronous: false

                fillMode: Image.Stretch
            }

            // ------------------------------------------------
            // PINCEL LAMA
            // ------------------------------------------------

            Canvas {
                id: lamaPaint

                anchors.fill: parent

                visible:
                    editorWindow.activeTool === "ia-remover"

                property real previousX: -1
                property real previousY: -1

                function clearMask() {
                    var ctx = getContext("2d")
                    ctx.reset()
                    requestPaint()
                }

                MouseArea {
                    anchors.fill: parent

                    enabled:
                        editorWindow.activeTool === "ia-remover"
                        && !imageController.aiBusy

                    acceptedButtons: Qt.LeftButton

                    onPressed: function(mouse) {
                        lamaPaint.previousX = mouse.x
                        lamaPaint.previousY = mouse.y
                    }

                    onPositionChanged: function(mouse) {
                        if (!(mouse.buttons & Qt.LeftButton))
                            return

                        var ctx = lamaPaint.getContext("2d")

                        ctx.strokeStyle = "rgba(255,0,0,0.55)"
                        ctx.lineWidth =
                            editorWindow.lamaBrushSize
                            * imageArea.scaleFactor

                        ctx.lineCap = "round"
                        ctx.lineJoin = "round"

                        ctx.beginPath()
                        ctx.moveTo(
                            lamaPaint.previousX,
                            lamaPaint.previousY
                        )

                        ctx.lineTo(mouse.x, mouse.y)
                        ctx.stroke()

                        var x1 =
                            lamaPaint.previousX
                            / imageArea.scaleFactor

                        var y1 =
                            lamaPaint.previousY
                            / imageArea.scaleFactor

                        var x2 =
                            mouse.x
                            / imageArea.scaleFactor

                        var y2 =
                            mouse.y
                            / imageArea.scaleFactor

                        imageController.lamaMaskStroke(
                            x1,
                            y1,
                            x2,
                            y2,
                            editorWindow.lamaBrushSize
                        )

                        lamaPaint.previousX = mouse.x
                        lamaPaint.previousY = mouse.y

                        lamaPaint.requestPaint()
                    }
                }
            }

            // ------------------------------------------------
            // CAIXA DE TEXTO
            // ------------------------------------------------

            Rectangle {
                id: textOverlay

                visible:
                    editorWindow.activeTool === "texto"

                x:
                    editorWindow.textX
                    * imageArea.scaleFactor

                y:
                    editorWindow.textY
                    * imageArea.scaleFactor

                width:
                    editorWindow.textBoxWidth
                    * imageArea.scaleFactor

                height:
                    editorWindow.textBoxHeight
                    * imageArea.scaleFactor

                color: "#20000000"

                border.color: editorWindow.arnGold
                border.width: 2

                TextArea {
                    id: textInput

                    anchors.fill: parent
                    anchors.margins: 5

                    placeholderText: "Digite aqui..."

                    color: textColor.chosenColor
                    selectionColor: "#8060A5FA"

                    background: null

                    wrapMode: TextEdit.Wrap

                    font.family: fontCombo.currentText
                    font.pixelSize:
                        textSize.value
                        * imageArea.scaleFactor

                    font.bold: textBold.checked
                    font.italic: textItalic.checked

                    opacity:
                        textOpacity.value / 100

                    horizontalAlignment:
                        Text.AlignHCenter

                    verticalAlignment:
                        Text.AlignVCenter
                }

                Rectangle {
                    id: dragHandle

                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right

                    height: 18

                    color: "#80E6C56A"

                    MouseArea {
                        anchors.fill: parent

                        property real startMouseX
                        property real startMouseY
                        property real startBoxX
                        property real startBoxY

                        onPressed: function(mouse) {
                            startMouseX = mouse.x
                            startMouseY = mouse.y
                            startBoxX = editorWindow.textX
                            startBoxY = editorWindow.textY
                        }

                        onPositionChanged: function(mouse) {
                            if (!(mouse.buttons & Qt.LeftButton))
                                return

                            editorWindow.textX =
                                Math.max(
                                    0,
                                    startBoxX
                                    + (mouse.x - startMouseX)
                                    / imageArea.scaleFactor
                                )

                            editorWindow.textY =
                                Math.max(
                                    0,
                                    startBoxY
                                    + (mouse.y - startMouseY)
                                    / imageArea.scaleFactor
                                )
                        }
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    width: 18
                    height: 18

                    color: editorWindow.arnGold

                    MouseArea {
                        anchors.fill: parent

                        property real lastX
                        property real lastY

                        onPressed: function(mouse) {
                            lastX = mouse.x
                            lastY = mouse.y
                        }

                        onPositionChanged: function(mouse) {
                            if (!(mouse.buttons & Qt.LeftButton))
                                return

                            editorWindow.textBoxWidth =
                                Math.max(
                                    100,
                                    editorWindow.textBoxWidth
                                    + (mouse.x - lastX)
                                    / imageArea.scaleFactor
                                )

                            editorWindow.textBoxHeight =
                                Math.max(
                                    50,
                                    editorWindow.textBoxHeight
                                    + (mouse.y - lastY)
                                    / imageArea.scaleFactor
                                )

                            lastX = mouse.x
                            lastY = mouse.y
                        }
                    }
                }
            }
        }

        WheelHandler {
            onWheel: function(event) {
                if (event.angleDelta.y > 0)
                    editorWindow.editorZoom =
                        Math.min(
                            6,
                            editorWindow.editorZoom * 1.12
                        )
                else
                    editorWindow.editorZoom =
                        Math.max(
                            0.2,
                            editorWindow.editorZoom / 1.12
                        )
            }
        }
    }

    FolderDialog {
        id: similarFolderDialog

        title:
            "Escolher pasta para buscar imagens semelhantes"

        onAccepted: {
            imageController.runVisionText(
                "similar",
                selectedFolder.toString()
            )
        }
    }

    // ========================================================
    // RODAPÉ
    // ========================================================

    Rectangle {
        id: bottomBar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 58
        color: editorWindow.arnChromeBottom

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            spacing: 10

            Label {
                text:
                    imageController.imageWidth
                    + " × "
                    + imageController.imageHeight

                color: editorWindow.arnMutedText
            }

            Item {
                Layout.fillWidth: true
            }

            GlassButton {
                text: "−"
                onClicked:
                    editorWindow.editorZoom =
                        Math.max(
                            0.2,
                            editorWindow.editorZoom / 1.2
                        )
            }

            Label {
                text:
                    Math.round(
                        editorWindow.editorZoom * 100
                    )
                    + "%"

                color: editorWindow.arnText
                Layout.minimumWidth: 58
                horizontalAlignment: Text.AlignHCenter
            }

            GlassButton {
                text: "+"
                onClicked:
                    editorWindow.editorZoom =
                        Math.min(
                            6,
                            editorWindow.editorZoom * 1.2
                        )
            }

            GlassButton {
                text: "Salvar"
                onClicked: imageController.save()
            }

            GlassButton {
                text: "Fechar editor"
                onClicked: editorWindow.closeEditor()
            }
        }
    }
}
