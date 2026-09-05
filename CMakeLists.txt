cmake_minimum_required(VERSION 3.21)

project(ArnView VERSION 0.4.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick QuickControls2)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(ArnView
    src/main.cpp
    src/ImageController.cpp
    src/ImageController.h
    src/ArnViewImageProvider.cpp
    src/ArnViewImageProvider.h
    assets/ArnView.icns
)

set_source_files_properties(assets/ArnView.icns PROPERTIES
    MACOSX_PACKAGE_LOCATION "Resources"
)

qt_add_qml_module(ArnView
    URI ArnView
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/EditorWindow.qml
        qml/GlassToolButton.qml
        qml/GlassButton.qml
)

set_target_properties(ArnView PROPERTIES
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_GUI_IDENTIFIER "studio.arn.arnview"
    MACOSX_BUNDLE_BUNDLE_NAME "ArnView"
    MACOSX_BUNDLE_ICON_FILE "ArnView.icns"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}"
    MACOSX_BUNDLE_BUNDLE_VERSION "1"
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/packaging/Info.plist.in"
)

target_link_libraries(ArnView PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
)

install(TARGETS ArnView
    BUNDLE DESTINATION .
    RUNTIME DESTINATION bin
)
