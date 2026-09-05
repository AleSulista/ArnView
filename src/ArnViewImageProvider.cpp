#include "ArnViewImageProvider.h"
#include "ImageController.h"
ArnViewImageProvider::ArnViewImageProvider(ImageController *controller):QQuickImageProvider(QQuickImageProvider::Image),m_controller(controller){}
QImage ArnViewImageProvider::requestImage(const QString &,QSize *size,const QSize &requestedSize)
{
    Q_UNUSED(requestedSize);
    QImage image=m_controller->currentImage();
    if(size)*size=QSize(m_controller->imageWidth(),m_controller->imageHeight());
    return image;
}
