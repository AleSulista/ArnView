#include "ImageController.h"
#include "ArnViewImageProvider.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFileInfo>
#include <QQuickWindow>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName("ArnView");
    QGuiApplication::setApplicationDisplayName("ArnView");
    QGuiApplication::setOrganizationName("Studio Arn");
    QQuickWindow::setDefaultAlphaBuffer(true);

    ImageController controller;
    app.installEventFilter(&controller);
    if (argc > 1) {
        const QString candidate = QString::fromLocal8Bit(argv[1]);
        if (QFileInfo(candidate).isFile())
            controller.openUrl(QUrl::fromLocalFile(QFileInfo(candidate).absoluteFilePath()));
    }

    QQmlApplicationEngine engine;
    engine.addImageProvider("arnview", new ArnViewImageProvider(&controller));
    engine.rootContext()->setContextProperty("imageController", &controller);
    engine.loadFromModule("ArnView", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;
    return app.exec();
}
