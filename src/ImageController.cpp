#include "ImageController.h"
#include <QFontMetrics>
#include <QtMath>
#include <QPen>
#include <QFont>
#include <QPainterPath>
#include <QColor>
#include <QCoreApplication>
#include <QDir>
#include <QEvent>
#include <QFile>
#include <QFileInfo>
#include <QFileOpenEvent>
#include <QImageReader>
#include <QImageWriter>
#include <QProcess>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonParseError>
#include <QPainter>

namespace {
QImage g_lamaMask;
bool g_lamaMaskDirty = false;
}

#include <QTransform>
#include <QUuid>

ImageController::ImageController(QObject *parent)
    : QObject(parent) {}

QUrl ImageController::displayUrl() const { return m_image.isNull() ? QUrl() : QUrl(QStringLiteral("image://arnview/current?r=%1").arg(m_revision)); }

QStringList ImageController::folderImageUrls() const
{
    QStringList urls;
    urls.reserve(m_folderImages.size());

    for (const QString &path : m_folderImages)
        urls.append(QUrl::fromLocalFile(path).toString());

    return urls;
}

int ImageController::currentIndex() const
{
    return m_currentIndex;
}

QString ImageController::currentName() const { return QFileInfo(m_currentPath).fileName(); }
bool ImageController::hasImage() const { return !m_image.isNull(); }
int ImageController::imageWidth() const { return m_adjustmentBase.isNull() ? m_image.width() : m_adjustmentBase.width(); }
int ImageController::imageHeight() const { return m_adjustmentBase.isNull() ? m_image.height() : m_adjustmentBase.height(); }
bool ImageController::canUndo() const { return m_historyIndex > 0; }
bool ImageController::canRedo() const { return m_historyIndex >= 0 && m_historyIndex + 1 < m_history.size(); }
bool ImageController::aiBusy() const { return m_aiBusy; }
QString ImageController::aiStatus() const { return m_aiStatus; }
QImage ImageController::currentImage() const { return m_image; }

void ImageController::openUrl(const QUrl &url)
{
    const QString path = url.isLocalFile() ? url.toLocalFile() : url.toString();
    if (QFileInfo(path).isFile()) { rebuildFolderList(path); loadPath(path); }
}
void ImageController::loadPath(const QString &path)
{
    QImageReader reader(path); reader.setAutoTransform(true);
    const QImage loaded = reader.read();
    if (loaded.isNull()) { emit errorOccurred(QStringLiteral("Não foi possível abrir esta imagem: %1").arg(reader.errorString())); return; }
    m_currentPath = QFileInfo(path).absoluteFilePath();

    // Arquivo aberto pelo usuário = original protegido.
    m_sourcePath = m_currentPath;
    m_original = loaded.convertToFormat(QImage::Format_ARGB32);
    m_image = m_original; m_adjustmentBase = QImage(); m_history = {m_image}; m_historyIndex = 0; ++m_revision;
    m_currentIndex = m_folderImages.indexOf(m_currentPath);
    emit fileChanged();
    emit imageChanged();
    emit historyChanged();
    emit folderChanged();
}
void ImageController::next() { if (!m_folderImages.isEmpty()) { m_currentIndex = (m_currentIndex + 1) % m_folderImages.size(); loadPath(m_folderImages.at(m_currentIndex)); } }
void ImageController::previous() { if (!m_folderImages.isEmpty()) { m_currentIndex = (m_currentIndex - 1 + m_folderImages.size()) % m_folderImages.size(); loadPath(m_folderImages.at(m_currentIndex)); } }

void ImageController::openFolderImage(int index)
{
    if (index < 0 || index >= m_folderImages.size())
        return;

    m_currentIndex = index;
    loadPath(m_folderImages.at(index));
}

void ImageController::applyImage(const QImage &image, bool addToHistory)
{
    if (image.isNull()) return;
    m_image = image.convertToFormat(QImage::Format_ARGB32);
    if (addToHistory) {
        while (m_history.size() > m_historyIndex + 1) m_history.removeLast();
        m_history.append(m_image); m_historyIndex = m_history.size() - 1;
    }
    ++m_revision; emit imageChanged(); emit historyChanged();
}
void ImageController::rotateLeft() { applyImage(m_image.transformed(QTransform().rotate(-90))); }
void ImageController::rotateRight() { applyImage(m_image.transformed(QTransform().rotate(90))); }
void ImageController::flipHorizontal() { applyImage(m_image.mirrored(true, false)); }
void ImageController::flipVertical() { applyImage(m_image.mirrored(false, true)); }
void ImageController::grayscale() { applyImage(m_image.convertToFormat(QImage::Format_Grayscale8).convertToFormat(QImage::Format_ARGB32)); }
void ImageController::sepia()
{
    QImage out = m_image.convertToFormat(QImage::Format_ARGB32);
    for (int y=0; y<out.height(); ++y) { auto *line=reinterpret_cast<QRgb*>(out.scanLine(y)); for (int x=0; x<out.width(); ++x) {
        QColor c=QColor::fromRgba(line[x]); int r=qMin(255,int(.393*c.red()+.769*c.green()+.189*c.blue()));
        int g=qMin(255,int(.349*c.red()+.686*c.green()+.168*c.blue())); int b=qMin(255,int(.272*c.red()+.534*c.green()+.131*c.blue()));
        line[x]=qRgba(r,g,b,c.alpha()); }} applyImage(out);
}
void ImageController::adjustBrightness(int delta)
{
    QImage out=m_image.convertToFormat(QImage::Format_ARGB32);
    for(int y=0;y<out.height();++y){auto *line=reinterpret_cast<QRgb*>(out.scanLine(y));for(int x=0;x<out.width();++x)
        line[x]=qRgba(qBound(0,qRed(line[x])+delta,255),qBound(0,qGreen(line[x])+delta,255),qBound(0,qBlue(line[x])+delta,255),qAlpha(line[x]));} applyImage(out);
}
void ImageController::adjustContrast(double factor)
{
    QImage out=m_image.convertToFormat(QImage::Format_ARGB32);
    for(int y=0;y<out.height();++y){auto *line=reinterpret_cast<QRgb*>(out.scanLine(y));for(int x=0;x<out.width();++x){
        auto channel=[factor](int v){return qBound(0,int((v-128)*factor+128),255);}; line[x]=qRgba(channel(qRed(line[x])),channel(qGreen(line[x])),channel(qBlue(line[x])),qAlpha(line[x]));}} applyImage(out);
}
void ImageController::autoImprove() { adjustContrast(1.08); adjustBrightness(4); }
void ImageController::beginAdjustments()
{
    if (!m_image.isNull()) {
        m_adjustmentBase = m_image;
        m_adjBrightness=m_adjContrast=m_adjSaturation=m_adjTemperature=m_adjTint=m_adjMonochrome=m_adjSepia=0;
    }
}
QImage ImageController::renderAdjustments(const QImage &source) const
{
    QImage out = source.convertToFormat(QImage::Format_ARGB32);
    const double contrastFactor = 1.0 + m_adjContrast / 100.0;
    const double saturationFactor = 1.0 + m_adjSaturation / 100.0;
    const double monoMix = qBound(0.0, m_adjMonochrome / 100.0, 1.0);
    const double sepiaMix = qBound(0.0, m_adjSepia / 100.0, 1.0);
    for (int y = 0; y < out.height(); ++y) {
        auto *line = reinterpret_cast<QRgb *>(out.scanLine(y));
        for (int x = 0; x < out.width(); ++x) {
            const QRgb px = line[x];
            double r = (qRed(px) - 128.0) * contrastFactor + 128.0 + m_adjBrightness;
            double g = (qGreen(px) - 128.0) * contrastFactor + 128.0 + m_adjBrightness;
            double b = (qBlue(px) - 128.0) * contrastFactor + 128.0 + m_adjBrightness;
            const double lum = 0.2126*r + 0.7152*g + 0.0722*b;
            r = lum + (r-lum)*saturationFactor; g = lum + (g-lum)*saturationFactor; b = lum + (b-lum)*saturationFactor;
            r += m_adjTemperature*0.55 + m_adjTint*0.28; g -= m_adjTint*0.35; b -= m_adjTemperature*0.55 + m_adjTint*0.08;
            const double gray = 0.2126*r + 0.7152*g + 0.0722*b;
            r = r*(1.0-monoMix)+gray*monoMix; g = g*(1.0-monoMix)+gray*monoMix; b = b*(1.0-monoMix)+gray*monoMix;
            const double sr = qMin(255.0, .393*r+.769*g+.189*b);
            const double sg = qMin(255.0, .349*r+.686*g+.168*b);
            const double sb = qMin(255.0, .272*r+.534*g+.131*b);
            r = r*(1.0-sepiaMix)+sr*sepiaMix; g = g*(1.0-sepiaMix)+sg*sepiaMix; b = b*(1.0-sepiaMix)+sb*sepiaMix;
            line[x] = qRgba(qBound(0,int(r),255),qBound(0,int(g),255),qBound(0,int(b),255),qAlpha(px));
        }
    }
    return out;
}
void ImageController::previewAdjustments(int brightness, int contrast, int saturation,
                                         int temperature, int tint, int monochrome, int sepiaAmount)
{
    if (m_adjustmentBase.isNull()) beginAdjustments();
    if (m_adjustmentBase.isNull()) return;
    m_adjBrightness=brightness; m_adjContrast=contrast; m_adjSaturation=saturation;
    m_adjTemperature=temperature; m_adjTint=tint; m_adjMonochrome=monochrome; m_adjSepia=sepiaAmount;
    QImage previewBase = m_adjustmentBase;
    constexpr int previewLimit = 1280;
    if (qMax(previewBase.width(), previewBase.height()) > previewLimit)
        previewBase = previewBase.scaled(previewLimit, previewLimit, Qt::KeepAspectRatio, Qt::FastTransformation);
    m_image = renderAdjustments(previewBase); ++m_revision; emit imageChanged();
}
void ImageController::commitAdjustments()
{
    if (m_adjustmentBase.isNull()) return;
    const bool unchanged = m_adjBrightness==0 && m_adjContrast==0 && m_adjSaturation==0 && m_adjTemperature==0 &&
                           m_adjTint==0 && m_adjMonochrome==0 && m_adjSepia==0;
    if (unchanged) { m_image=m_adjustmentBase; m_adjustmentBase=QImage(); ++m_revision; emit imageChanged(); return; }
    m_image = renderAdjustments(m_adjustmentBase);
    while (m_history.size() > m_historyIndex + 1) m_history.removeLast();
    m_history.append(m_image); m_historyIndex = m_history.size() - 1; m_adjustmentBase = QImage(); ++m_revision; emit imageChanged(); emit historyChanged();
}
void ImageController::cancelAdjustments()
{
    if (m_adjustmentBase.isNull()) return;
    m_image = m_adjustmentBase; m_adjustmentBase = QImage(); ++m_revision; emit imageChanged();
}
void ImageController::undo() { if(canUndo()){m_image=m_history.at(--m_historyIndex);++m_revision;emit imageChanged();emit historyChanged();} }
void ImageController::redo() { if(canRedo()){m_image=m_history.at(++m_historyIndex);++m_revision;emit imageChanged();emit historyChanged();} }
void ImageController::reset() { if(!m_original.isNull()) applyImage(m_original); }
bool ImageController::save()
{
    if (m_image.isNull() || m_sourcePath.isEmpty())
        return false;

    QFileInfo originalInfo(m_sourcePath);

    const QString dir =
        originalInfo.absolutePath();

    QString base =
        originalInfo.completeBaseName();

    QString suffix =
        originalInfo.suffix();

    if (suffix.isEmpty())
        suffix = QStringLiteral("png");

    QString candidate =
        dir + QLatin1Char('/')
        + base
        + QStringLiteral("-editado.")
        + suffix;

    int number = 2;

    while (QFileInfo::exists(candidate)) {
        candidate =
            dir + QLatin1Char('/')
            + base
            + QStringLiteral("-editado-%1.").arg(number++)
            + suffix;
    }

    return saveAs(
        QUrl::fromLocalFile(candidate)
    );
}
bool ImageController::saveAs(const QUrl &url)
{
    if (m_image.isNull() || !url.isLocalFile())
        return false;

    QString requested =
        QFileInfo(url.toLocalFile()).absoluteFilePath();

    if (QFileInfo(requested).suffix().isEmpty())
        requested += QStringLiteral(".png");

    QString path = requested;

    // NUNCA sobrescrever o original aberto.
    if (!m_sourcePath.isEmpty()) {
        const QString source =
            QFileInfo(m_sourcePath).absoluteFilePath();

        if (QFileInfo(path).absoluteFilePath() ==
            QFileInfo(source).absoluteFilePath()) {

            QFileInfo info(source);

            QString suffix = info.suffix();

            if (suffix.isEmpty())
                suffix = QStringLiteral("png");

            path =
                info.absolutePath()
                + QLatin1Char('/')
                + info.completeBaseName()
                + QStringLiteral("-editado.")
                + suffix;

            int number = 2;

            while (QFileInfo::exists(path)) {
                path =
                    info.absolutePath()
                    + QLatin1Char('/')
                    + info.completeBaseName()
                    + QStringLiteral("-editado-%1.").arg(number++)
                    + suffix;
            }
        }
    }

    QImageWriter writer(path);
    writer.setQuality(95);

    if (!writer.write(m_image)) {
        emit errorOccurred(
            QStringLiteral(
                "Não foi possível salvar: %1"
            ).arg(writer.errorString())
        );
        return false;
    }

    // IMPORTANTE:
    // não mudamos m_sourcePath.
    // O original continua permanentemente protegido.
    m_currentPath =
        QFileInfo(path).absoluteFilePath();

    emit fileChanged();

    return true;
}
QString ImageController::aiTextResult() const
{
    return m_aiTextResult;
}

void ImageController::clearAiTextResult()
{
    if (m_aiTextResult.isEmpty())
        return;

    m_aiTextResult.clear();
    emit aiTextResultChanged();
}

void ImageController::setAiState(bool busy,const QString &status)
{
    m_aiBusy = busy;
    m_aiStatus = status;
    emit aiStateChanged();
}

void ImageController::clearLamaMask()
{
    g_lamaMask = QImage();
    g_lamaMaskDirty = false;
    emit lamaMaskCleared();
}

void ImageController::lamaMaskStroke(double x1, double y1,
                                     double x2, double y2,
                                     double width)
{
    if (m_image.isNull())
        return;

    if (g_lamaMask.size() != m_image.size()) {
        g_lamaMask = QImage(
            m_image.size(),
            QImage::Format_Grayscale8
        );
        g_lamaMask.fill(0);
        g_lamaMaskDirty = false;
    }

    QPainter painter(&g_lamaMask);
    painter.setRenderHint(QPainter::Antialiasing, true);

    QPen pen(
        Qt::white,
        qMax(1.0, width),
        Qt::SolidLine,
        Qt::RoundCap,
        Qt::RoundJoin
    );

    painter.setPen(pen);
    painter.drawLine(
        QPointF(x1, y1),
        QPointF(x2, y2)
    );

    g_lamaMaskDirty = true;
}

void ImageController::runLamaMask()
{
    if (m_image.isNull() || m_aiBusy)
        return;

    if (!g_lamaMaskDirty || g_lamaMask.isNull()) {
        emit errorOccurred(
            QStringLiteral(
                "Pinte primeiro sobre a área que deseja remover."
            )
        );
        return;
    }

    const QString id =
        QUuid::createUuid().toString(QUuid::WithoutBraces);

    const QString base =
        QDir::tempPath()
        + QStringLiteral("/arnview-lama-")
        + id;

    const QString input  = base + QStringLiteral("-input.png");
    const QString mask   = base + QStringLiteral("-mask.png");
    const QString output = base + QStringLiteral("-output.png");

    if (!m_image.save(input, "PNG")
        || !g_lamaMask.save(mask, "PNG")) {

        QFile::remove(input);
        QFile::remove(mask);

        emit errorOccurred(
            QStringLiteral(
                "Não foi possível preparar imagem e máscara para o LaMa."
            )
        );
        return;
    }

    QString lamaProgram;
    QStringList lamaArgs;

    const QString bundledLama =
        QDir(QCoreApplication::applicationDirPath())
            .absoluteFilePath(
                QStringLiteral("../Resources/ArnViewAI/run_lama.sh")
            );

    if (QFileInfo::exists(bundledLama)) {
        lamaProgram = bundledLama;
        lamaArgs << input << mask << output;
    } else {
        QDir dir(QCoreApplication::applicationDirPath());
        QString projectRoot;

        while (dir.cdUp()) {
            const QString helper =
                dir.absoluteFilePath(
                    QStringLiteral("local_lama.py")
                );

            const QString python =
                dir.absoluteFilePath(
                    QStringLiteral(".venv-localai/bin/python")
                );

            if (QFileInfo::exists(helper)
                && QFileInfo::exists(python)) {
                projectRoot = dir.absolutePath();
                break;
            }
        }

        if (projectRoot.isEmpty()) {
            QFile::remove(input);
            QFile::remove(mask);

            emit errorOccurred(
                QStringLiteral(
                    "Motor de remoção de objetos não encontrado."
                )
            );
            return;
        }

        lamaProgram =
            QDir(projectRoot).absoluteFilePath(
                QStringLiteral(".venv-localai/bin/python")
            );

        lamaArgs
            << QDir(projectRoot).absoluteFilePath(
                   QStringLiteral("local_lama.py")
               )
            << input
            << mask
            << output;
    }

    auto *process = new QProcess(this);

    setAiState(
        true,
        QStringLiteral(
            "Removendo o objeto…"
        )
    );

    connect(
        process,
        qOverload<int, QProcess::ExitStatus>(
            &QProcess::finished
        ),
        this,
        [this, process, input, mask, output]
        (int exitCode, QProcess::ExitStatus status) {

            const QString stdErr =
                QString::fromUtf8(
                    process->readAllStandardError()
                ).trimmed();

            const QString stdOut =
                QString::fromUtf8(
                    process->readAllStandardOutput()
                ).trimmed();

            if (status != QProcess::NormalExit
                || exitCode != 0) {

                setAiState(
                    false,
                    QStringLiteral(
                        "Falha no LaMa Local"
                    )
                );

                emit errorOccurred(
                    stdErr.isEmpty()
                    ? QStringLiteral(
                        "O LaMa Local terminou com erro.\n\n%1"
                      ).arg(stdOut)
                    : stdErr
                );

            } else {

                QImage result(output);

                if (result.isNull()) {

                    setAiState(
                        false,
                        QStringLiteral(
                            "Resultado LaMa inválido"
                        )
                    );

                    emit errorOccurred(
                        QStringLiteral(
                            "O LaMa terminou, mas não gerou "
                            "uma imagem válida."
                        )
                    );

                } else {

                    applyImage(
                        result.convertToFormat(
                            QImage::Format_ARGB32
                        )
                    );

                    clearLamaMask();

                    setAiState(
                        false,
                        QStringLiteral(
                            "Objeto removido com sucesso."
                        )
                    );
                }
            }

            QFile::remove(input);
            QFile::remove(mask);
            QFile::remove(output);

            process->deleteLater();
        }
    );

    connect(
        process,
        &QProcess::errorOccurred,
        this,
        [this, process, input, mask, output]
        (QProcess::ProcessError error) {

            if (error != QProcess::FailedToStart)
                return;

            setAiState(
                false,
                QStringLiteral(
                    "Não foi possível iniciar o LaMa Local"
                )
            );

            emit errorOccurred(
                QStringLiteral(
                    "Falha ao iniciar o Python da IA local."
                )
            );

            QFile::remove(input);
            QFile::remove(mask);
            QFile::remove(output);

            process->deleteLater();
        }
    );

    process->start(
        lamaProgram,
        lamaArgs
    );
}


void ImageController::runRemoveBackground()
{
    if (m_image.isNull() || m_aiBusy)
        return;

    const QString id =
        QUuid::createUuid().toString(QUuid::WithoutBraces);

    const QString base =
        QDir::tempPath()
        + QStringLiteral("/arnview-rembg-")
        + id;

    const QString input =
        base + QStringLiteral("-input.png");

    const QString output =
        base + QStringLiteral("-output.png");

    if (!m_image.save(input, "PNG")) {
        emit errorOccurred(
            QStringLiteral("Não foi possível preparar a imagem.")
        );
        return;
    }

    QString rembgProgram;
    QStringList rembgArgs;

    const QString bundledRembg =
        QDir(QCoreApplication::applicationDirPath())
            .absoluteFilePath(
                QStringLiteral("../Resources/ArnViewAI/run_rembg.sh")
            );

    if (QFileInfo::exists(bundledRembg)) {
        rembgProgram = bundledRembg;
        rembgArgs << input << output;
    } else {
        QDir dir(QCoreApplication::applicationDirPath());
        QString projectRoot;

        while (dir.cdUp()) {
            const QString helper =
                dir.absoluteFilePath(
                    QStringLiteral("remove_bg.py")
                );

            const QString python =
                dir.absoluteFilePath(
                    QStringLiteral(".venv-rembg/bin/python")
                );

            if (QFileInfo::exists(helper)
                && QFileInfo::exists(python)) {
                projectRoot = dir.absolutePath();
                break;
            }
        }

        if (projectRoot.isEmpty()) {
            QFile::remove(input);

            emit errorOccurred(
                QStringLiteral(
                    "Motor de remoção de fundo não encontrado."
                )
            );
            return;
        }

        rembgProgram =
            QDir(projectRoot).absoluteFilePath(
                QStringLiteral(".venv-rembg/bin/python")
            );

        rembgArgs
            << QDir(projectRoot).absoluteFilePath(
                   QStringLiteral("remove_bg.py")
               )
            << input
            << output;
    }

    auto *process = new QProcess(this);

    setAiState(
        true,
        QStringLiteral("Removendo o fundo…")
    );

    connect(
        process,
        qOverload<int, QProcess::ExitStatus>(
            &QProcess::finished
        ),
        this,
        [this, process, input, output]
        (int exitCode, QProcess::ExitStatus status) {

            const QString err =
                QString::fromUtf8(
                    process->readAllStandardError()
                ).trimmed();

            if (
                status != QProcess::NormalExit
                || exitCode != 0
            ) {
                setAiState(false, "Falha ao remover fundo");

                emit errorOccurred(
                    err.isEmpty()
                    ? QStringLiteral(
                        "A IA local não conseguiu remover o fundo."
                      )
                    : err
                );
            } else {

                QImage result(output);

                if (result.isNull()) {
                    setAiState(false, "Resultado inválido");

                    emit errorOccurred(
                        QStringLiteral(
                            "A IA não gerou uma imagem válida."
                        )
                    );
                } else {
                    applyImage(
                        result.convertToFormat(
                            QImage::Format_ARGB32
                        )
                    );

                    clearLamaMask();

                    setAiState(
                        false,
                        QStringLiteral(
                            "Fundo removido com sucesso."
                        )
                    );
                }
            }

            QFile::remove(input);
            QFile::remove(output);
            process->deleteLater();
        }
    );

    process->start(
        rembgProgram,
        rembgArgs
    );
}



void ImageController::runVisionAi(
    const QString &action,
    const QString &param)
{
    if (m_image.isNull() || m_aiBusy)
        return;

    static const QStringList allowed = {
        QStringLiteral("auto"),
        QStringLiteral("denoise"),
        QStringLiteral("lowlight"),
        QStringLiteral("restore"),
        QStringLiteral("face"),
        QStringLiteral("blurfaces"),
        QStringLiteral("crop"),
        QStringLiteral("upscale")
    };

    const QString normalized =
        action.trimmed().toLower();

    if (!allowed.contains(normalized)) {
        emit errorOccurred(
            QStringLiteral(
                "Recurso Vision desconhecido: %1"
            ).arg(action)
        );
        return;
    }

    const QString id =
        QUuid::createUuid().toString(
            QUuid::WithoutBraces
        );

    const QString base =
        QDir::tempPath()
        + QStringLiteral("/arnview-vision-")
        + id;

    const QString input =
        base + QStringLiteral("-input.png");

    const QString output =
        base + QStringLiteral("-output.png");

    if (!m_image.save(input, "PNG")) {
        emit errorOccurred(
            QStringLiteral(
                "Não foi possível preparar a imagem para o Vision."
            )
        );
        return;
    }

    QString visionProgram;
    QString visionScript;

    const QString bundledVision =
        QDir(QCoreApplication::applicationDirPath())
            .absoluteFilePath(
                QStringLiteral("../Resources/ArnViewAI/run_vision.sh")
            );

    if (QFileInfo::exists(bundledVision)) {
        visionProgram = bundledVision;
    } else {
        QDir dir(QCoreApplication::applicationDirPath());
        QString projectRoot;

        while (dir.cdUp()) {
            const QString script =
                dir.absoluteFilePath(
                    QStringLiteral("vision_ai.py")
                );

            const QString python =
                dir.absoluteFilePath(
                    QStringLiteral(".venv-vision/bin/python")
                );

            if (QFileInfo::exists(script)
                && QFileInfo::exists(python)) {
                projectRoot = dir.absolutePath();
                break;
            }
        }

        if (projectRoot.isEmpty()) {
            QFile::remove(input);

            emit errorOccurred(
                QStringLiteral(
                    "Motor de inteligência de imagem não encontrado."
                )
            );
            return;
        }

        visionProgram =
            QDir(projectRoot).absoluteFilePath(
                QStringLiteral(".venv-vision/bin/python")
            );

        visionScript =
            QDir(projectRoot).absoluteFilePath(
                QStringLiteral("vision_ai.py")
            );
    }

    QStringList args;

    if (!visionScript.isEmpty())
        args << visionScript;

    args
        << normalized
        << input
        << output;

    if (!param.trimmed().isEmpty())
        args << param.trimmed();

    QString description;

    if (normalized == "auto")
        description =
            QStringLiteral(
                "Melhorando a imagem…"
            );

    else if (normalized == "denoise")
        description =
            QStringLiteral(
                "Reduzindo o ruído…"
            );

    else if (normalized == "lowlight")
        description =
            QStringLiteral(
                "Corrigindo foto escura…"
            );

    else if (normalized == "restore")
        description =
            QStringLiteral(
                "Restaurando a fotografia…"
            );

    else if (normalized == "face")
        description =
            QStringLiteral(
                "Aprimorando rostos…"
            );

    else if (normalized == "blurfaces")
        description =
            QStringLiteral(
                "Desfocando rostos…"
            );

    else if (normalized == "crop")
        description =
            QStringLiteral(
                "Calculando recorte inteligente…"
            );

    else if (normalized == "upscale")
        description =
            QStringLiteral(
                "Ampliando a imagem…"
            );

    else
        description =
            QStringLiteral(
                "Processando com ArnView Vision…"
            );

    auto *process =
        new QProcess(this);

    setAiState(
        true,
        description
    );

    connect(
        process,

        qOverload<
            int,
            QProcess::ExitStatus
        >(
            &QProcess::finished
        ),

        this,

        [this,
         process,
         input,
         output,
         normalized]
        (int exitCode,
         QProcess::ExitStatus status)
        {
            const QString stdOut =
                QString::fromUtf8(
                    process->readAllStandardOutput()
                ).trimmed();

            const QString stdErr =
                QString::fromUtf8(
                    process->readAllStandardError()
                ).trimmed();

            if (
                status != QProcess::NormalExit
                || exitCode != 0
            ) {

                setAiState(
                    false,
                    QStringLiteral(
                        "Falha no ArnView Vision"
                    )
                );

                QString message =
                    stdErr.isEmpty()
                    ? stdOut
                    : stdErr;

                if (message.isEmpty())
                    message =
                        QStringLiteral(
                            "O processamento Vision terminou com erro."
                        );

                emit errorOccurred(message);

            } else {

                QImage result(output);

                if (result.isNull()) {

                    setAiState(
                        false,
                        QStringLiteral(
                            "Resultado Vision inválido"
                        )
                    );

                    emit errorOccurred(
                        QStringLiteral(
                            "O Vision terminou, mas não gerou uma imagem válida."
                        )
                    );

                } else {

                    applyImage(
                        result.convertToFormat(
                            QImage::Format_ARGB32
                        )
                    );

                    QString finished =
                        QStringLiteral(
                            "Processamento concluído"
                        );

                    if (normalized == "upscale")
                        finished =
                            QStringLiteral(
                                "Imagem ampliada com sucesso."
                            );

                    else if (normalized == "restore")
                        finished =
                            QStringLiteral(
                                "Restauração concluída"
                            );

                    else if (normalized == "denoise")
                        finished =
                            QStringLiteral(
                                "Redução de ruído concluída"
                            );

                    else if (normalized == "face")
                        finished =
                            QStringLiteral(
                                "Melhoria de rosto concluída"
                            );

                    else if (normalized == "crop")
                        finished =
                            QStringLiteral(
                                "Recorte inteligente concluído"
                            );

                    setAiState(
                        false,
                        finished
                    );
                }
            }

            QFile::remove(input);
            QFile::remove(output);

            process->deleteLater();
        }
    );

    connect(
        process,
        &QProcess::errorOccurred,
        this,

        [this,
         process,
         input,
         output]
        (QProcess::ProcessError error)
        {
            if (
                error
                != QProcess::FailedToStart
            )
                return;

            setAiState(
                false,
                QStringLiteral(
                    "Falha ao iniciar ArnView Vision"
                )
            );

            emit errorOccurred(
                QStringLiteral(
                    "Não foi possível iniciar o motor Vision."
                )
            );

            QFile::remove(input);
            QFile::remove(output);

            process->deleteLater();
        }
    );

    process->start(
        visionProgram,
        args
    );
}



void ImageController::runVisionText(
    const QString &action,
    const QString &param)
{
    if (m_image.isNull() || m_aiBusy)
        return;

    const QString normalized =
        action.trimmed().toLower();

    if (normalized != QStringLiteral("ocr")
        && normalized != QStringLiteral("similar")) {

        emit errorOccurred(
            QStringLiteral(
                "Ação Vision de texto desconhecida: %1"
            ).arg(action)
        );

        return;
    }

    const QString id =
        QUuid::createUuid().toString(
            QUuid::WithoutBraces
        );

    const QString input =
        QDir::tempPath()
        + QStringLiteral("/arnview-vision-text-")
        + id
        + QStringLiteral("-input.png");

    if (!m_image.save(input, "PNG")) {
        emit errorOccurred(
            QStringLiteral(
                "Não foi possível preparar a imagem."
            )
        );
        return;
    }

    QString visionProgram;
    QString visionScript;

    const QString bundledVision =
        QDir(QCoreApplication::applicationDirPath())
            .absoluteFilePath(
                QStringLiteral("../Resources/ArnViewAI/run_vision.sh")
            );

    if (QFileInfo::exists(bundledVision)) {
        visionProgram = bundledVision;
    } else {
        QDir dir(QCoreApplication::applicationDirPath());
        QString projectRoot;

        while (dir.cdUp()) {
            const QString script =
                dir.absoluteFilePath(
                    QStringLiteral("vision_ai.py")
                );

            const QString python =
                dir.absoluteFilePath(
                    QStringLiteral(".venv-vision/bin/python")
                );

            if (QFileInfo::exists(script)
                && QFileInfo::exists(python)) {
                projectRoot = dir.absolutePath();
                break;
            }
        }

        if (projectRoot.isEmpty()) {
            QFile::remove(input);

            emit errorOccurred(
                QStringLiteral(
                    "Motor de leitura de imagem não encontrado."
                )
            );
            return;
        }

        visionProgram =
            QDir(projectRoot).absoluteFilePath(
                QStringLiteral(".venv-vision/bin/python")
            );

        visionScript =
            QDir(projectRoot).absoluteFilePath(
                QStringLiteral("vision_ai.py")
            );
    }

    QStringList args;

    if (!visionScript.isEmpty())
        args << visionScript;

    args
        << normalized
        << input;

    if (normalized == QStringLiteral("similar")) {

        QString folder =
            param.trimmed();

        const QUrl url(folder);

        if (url.isValid()
            && url.isLocalFile()) {

            folder = url.toLocalFile();
        }

        if (folder.isEmpty()
            || !QDir(folder).exists()) {

            QFile::remove(input);

            emit errorOccurred(
                QStringLiteral(
                    "Selecione uma pasta válida."
                )
            );

            return;
        }

        args << folder;
    }

    auto *process =
        new QProcess(this);

    setAiState(
        true,
        normalized == QStringLiteral("ocr")
        ? QStringLiteral(
            "Lendo texto da imagem…"
          )
        : QStringLiteral(
            "Procurando imagens semelhantes…"
          )
    );

    clearAiTextResult();

    connect(
        process,

        qOverload<
            int,
            QProcess::ExitStatus
        >(
            &QProcess::finished
        ),

        this,

        [this,
         process,
         input,
         normalized]
        (int exitCode,
         QProcess::ExitStatus status)
        {
            const QString out =
                QString::fromUtf8(
                    process->readAllStandardOutput()
                ).trimmed();

            const QString err =
                QString::fromUtf8(
                    process->readAllStandardError()
                ).trimmed();

            QFile::remove(input);

            if (status != QProcess::NormalExit
                || exitCode != 0) {

                setAiState(
                    false,
                    QStringLiteral(
                        "Falha no Vision"
                    )
                );

                emit errorOccurred(
                    err.isEmpty()
                    ? (
                        out.isEmpty()
                        ? QStringLiteral(
                            "O Vision terminou com erro."
                          )
                        : out
                      )
                    : err
                );

                process->deleteLater();
                return;
            }

            QString result = out;

            // Busca semelhante retorna JSON.
            // Formata para ficar legível no ArnView.
            if (normalized
                == QStringLiteral("similar")) {

                QJsonParseError parseError;

                const QJsonDocument doc =
                    QJsonDocument::fromJson(
                        out.toUtf8(),
                        &parseError
                    );

                if (parseError.error
                    == QJsonParseError::NoError
                    && doc.isArray()) {

                    QString formatted;

                    const QJsonArray array =
                        doc.array();

                    int position = 1;

                    for (const QJsonValue &value
                         : array) {

                        const QJsonObject object =
                            value.toObject();

                        const QString path =
                            object.value(
                                QStringLiteral("path")
                            ).toString();

                        const int distance =
                            object.value(
                                QStringLiteral("distance")
                            ).toInt();

                        formatted +=
                            QStringLiteral(
                                "%1. %2\n"
                                "   diferença visual: %3\n\n"
                            )
                            .arg(position++)
                            .arg(path)
                            .arg(distance);
                    }

                    result =
                        formatted.trimmed();

                    if (result.isEmpty())
                        result =
                            QStringLiteral(
                                "Nenhuma imagem semelhante encontrada."
                            );
                }
            }

            m_aiTextResult = result;
            emit aiTextResultChanged();

            setAiState(
                false,
                normalized == QStringLiteral("ocr")
                ? QStringLiteral(
                    "Texto extraído com sucesso."
                  )
                : QStringLiteral(
                    "Busca por imagens semelhantes concluída."
                  )
            );

            process->deleteLater();
        }
    );

    connect(
        process,
        &QProcess::errorOccurred,
        this,

        [this,
         process,
         input]
        (QProcess::ProcessError error)
        {
            if (error
                != QProcess::FailedToStart)
                return;

            QFile::remove(input);

            setAiState(
                false,
                QStringLiteral(
                    "Falha ao iniciar o Vision"
                )
            );

            emit errorOccurred(
                QStringLiteral(
                    "Não foi possível iniciar o motor Vision."
                )
            );

            process->deleteLater();
        }
    );

    process->start(
        visionProgram,
        args
    );
}


void ImageController::addText(
    const QString &text,
    const QString &fontFamily,
    int pixelSize,
    const QString &colorHex,
    bool bold,
    bool italic,
    bool outline,
    int outlineSize,
    bool shadow,
    const QString &shadowColorHex,
    int shadowDistance,
    int shadowAngle,
    int shadowOpacity,
    int shadowSize,
    int x,
    int y,
    int boxWidth,
    int boxHeight,
    double rotation,
    int opacity)
{
    if (m_image.isNull() || text.trimmed().isEmpty())
        return;

    QImage out =
        m_image.convertToFormat(
            QImage::Format_ARGB32
        );

    const int w = qMax(20, boxWidth);
    const int h = qMax(20, boxHeight);

    // Renderiza o texto primeiro numa camada própria.
    QImage textLayer(
        w + 160,
        h + 160,
        QImage::Format_ARGB32_Premultiplied
    );

    textLayer.fill(Qt::transparent);

    QPainter tp(&textLayer);

    tp.setRenderHint(
        QPainter::Antialiasing,
        true
    );

    tp.setRenderHint(
        QPainter::TextAntialiasing,
        true
    );

    QFont font(fontFamily);

    font.setPixelSize(
        qMax(6, pixelSize)
    );

    font.setBold(bold);
    font.setItalic(italic);

    QColor textColor(colorHex);

    if (!textColor.isValid())
        textColor = Qt::white;

    textColor.setAlpha(
        qBound(0, opacity, 100) * 255 / 100
    );

    QColor shadowColor(shadowColorHex);

    if (!shadowColor.isValid())
        shadowColor = Qt::black;

    shadowColor.setAlpha(
        qBound(0, shadowOpacity, 100)
        * 255 / 100
    );

    QRectF area(
        80,
        80,
        w,
        h
    );

    const int flags =
        Qt::AlignCenter
        | Qt::TextWordWrap;

    // ========================================================
    // SOMBRA
    // ========================================================

    if (shadow) {

        const double rad =
            qDegreesToRadians(
                static_cast<double>(shadowAngle)
            );

        const qreal sx =
            qCos(rad) * shadowDistance;

        const qreal sy =
            qSin(rad) * shadowDistance;

        QRectF shadowRect =
            area.translated(sx, sy);

        QColor baseShadow = shadowColor;

        // Agora chega até 100px de expansão.
        const int spread =
            qBound(0, shadowSize, 100);

        if (spread == 0) {

            tp.setPen(baseShadow);

            tp.drawText(
                shadowRect,
                flags,
                text
            );

        } else {

            // Muitas passadas com opacidade distribuída.
            // Fica mais cheio e visualmente mais forte.
            const int step =
                spread <= 12 ? 1 :
                spread <= 35 ? 2 :
                spread <= 60 ? 3 : 4;

            for (int ox = -spread; ox <= spread; ox += step) {
                for (int oy = -spread; oy <= spread; oy += step) {

                    const int d2 =
                        ox * ox + oy * oy;

                    if (d2 > spread * spread)
                        continue;

                    const double distance =
                        qSqrt(static_cast<double>(d2));

                    const double falloff =
                        1.0 -
                        distance /
                        qMax(1.0, static_cast<double>(spread));

                    QColor c = baseShadow;

                    const int alpha =
                        qBound(
                            0,
                            static_cast<int>(
                                baseShadow.alpha()
                                * (0.20 + 0.80 * falloff)
                            ),
                            255
                        );

                    c.setAlpha(alpha);

                    tp.setPen(c);

                    tp.drawText(
                        shadowRect.translated(
                            ox,
                            oy
                        ),
                        flags,
                        text
                    );
                }
            }
        }
    }

    // ========================================================
    // CONTORNO REAL
    // ========================================================

    if (outline) {

        QColor outlineColor =
            textColor.lightness() > 128
            ? QColor(0, 0, 0, textColor.alpha())
            : QColor(255, 255, 255, textColor.alpha());

        // Agora controlado diretamente pelo usuário.
        // Faixa bem maior para títulos e artes.
        const int radius =
            qBound(1, outlineSize, 40);

        // Quanto maior o raio, maior o passo permitido,
        // mantendo bom desempenho sem perder preenchimento.
        const int step =
            radius <= 8 ? 1 :
            radius <= 20 ? 2 : 3;

        for (int ox = -radius; ox <= radius; ox += step) {
            for (int oy = -radius; oy <= radius; oy += step) {

                if (ox == 0 && oy == 0)
                    continue;

                if (ox * ox + oy * oy > radius * radius)
                    continue;

                tp.setPen(outlineColor);

                tp.drawText(
                    area.translated(ox, oy),
                    flags,
                    text
                );
            }
        }
    }

    // TEXTO PRINCIPAL
    tp.setPen(textColor);

    tp.drawText(
        area,
        flags,
        text
    );

    tp.end();

    // ========================================================
    // COLOCA CAMADA NA FOTO
    // ========================================================

    QPainter painter(&out);

    painter.setRenderHint(
        QPainter::Antialiasing,
        true
    );

    painter.setRenderHint(
        QPainter::SmoothPixmapTransform,
        true
    );

    painter.translate(
        x + w / 2.0,
        y + h / 2.0
    );

    painter.rotate(rotation);

    painter.translate(
        -w / 2.0 - 80,
        -h / 2.0 - 80
    );

    painter.drawImage(
        QPointF(0, 0),
        textLayer
    );

    painter.end();

    // Só altera a cópia em memória.
    // Arquivo original no disco NÃO é tocado.
    applyImage(out);
}

bool ImageController::eventFilter(QObject *watched,QEvent *event)
{
    Q_UNUSED(watched) if(event->type()==QEvent::FileOpen){auto *e=static_cast<QFileOpenEvent*>(event);openUrl(e->url().isEmpty()?QUrl::fromLocalFile(e->file()):e->url());return true;}return false;
}
void ImageController::rebuildFolderList(const QString &path)
{
    QFileInfo info(path);QDir dir(info.absolutePath());QStringList filters={"*.jpg","*.jpeg","*.png","*.webp","*.bmp","*.gif","*.tif","*.tiff","*.heic","*.heif"};
    QFileInfoList entries=dir.entryInfoList(filters,QDir::Files|QDir::Readable,QDir::Name|QDir::IgnoreCase);m_folderImages.clear();for(const QFileInfo &entry:entries)m_folderImages.append(entry.absoluteFilePath());m_currentIndex=m_folderImages.indexOf(info.absoluteFilePath());
    emit folderChanged();
}
