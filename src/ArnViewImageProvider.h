#pragma once
#include <QQuickImageProvider>
class ImageController;
class ArnViewImageProvider final : public QQuickImageProvider
{
public:
    explicit ArnViewImageProvider(ImageController *controller);
    QImage requestImage(const QString &id,QSize *size,const QSize &requestedSize) override;
private:
    ImageController *m_controller;
};
