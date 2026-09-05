#pragma once
#include <QObject>
#include <QImage>
#include <QUrl>
#include <QStringList>
#include <QVector>
class QEvent;
class ImageController final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl displayUrl READ displayUrl NOTIFY imageChanged)
    Q_PROPERTY(QStringList folderImageUrls READ folderImageUrls NOTIFY folderChanged)
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY folderChanged)
    Q_PROPERTY(QString currentName READ currentName NOTIFY fileChanged)
    Q_PROPERTY(bool hasImage READ hasImage NOTIFY imageChanged)
    Q_PROPERTY(int imageWidth READ imageWidth NOTIFY imageChanged)
    Q_PROPERTY(int imageHeight READ imageHeight NOTIFY imageChanged)
    Q_PROPERTY(bool canUndo READ canUndo NOTIFY historyChanged)
    Q_PROPERTY(bool canRedo READ canRedo NOTIFY historyChanged)
    Q_PROPERTY(bool aiBusy READ aiBusy NOTIFY aiStateChanged)
    Q_PROPERTY(QString aiStatus READ aiStatus NOTIFY aiStateChanged)
    Q_PROPERTY(QString aiTextResult READ aiTextResult NOTIFY aiTextResultChanged)
public:
    explicit ImageController(QObject *parent = nullptr);
    QUrl displayUrl() const;
    QStringList folderImageUrls() const;
    int currentIndex() const;
    QString currentName() const;
    bool hasImage() const;
    int imageWidth() const;
    int imageHeight() const;
    bool canUndo() const;
    bool canRedo() const;
    bool aiBusy() const;
    QString aiStatus() const;
    QString aiTextResult() const;
    QImage currentImage() const;
    Q_INVOKABLE void openUrl(const QUrl &url);
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();
    Q_INVOKABLE void openFolderImage(int index);
    Q_INVOKABLE void rotateLeft();
    Q_INVOKABLE void rotateRight();
    Q_INVOKABLE void flipHorizontal();
    Q_INVOKABLE void flipVertical();
    Q_INVOKABLE void grayscale();
    Q_INVOKABLE void sepia();
    Q_INVOKABLE void adjustBrightness(int delta);
    Q_INVOKABLE void adjustContrast(double factor);
    Q_INVOKABLE void autoImprove();
    Q_INVOKABLE void beginAdjustments();
    Q_INVOKABLE void previewAdjustments(int brightness, int contrast, int saturation,
                                        int temperature, int tint, int monochrome, int sepiaAmount);
    Q_INVOKABLE void commitAdjustments();
    Q_INVOKABLE void cancelAdjustments();
    Q_INVOKABLE void undo();
    Q_INVOKABLE void redo();
    Q_INVOKABLE void reset();
    Q_INVOKABLE bool save();
    Q_INVOKABLE bool saveAs(const QUrl &url);
    Q_INVOKABLE void clearLamaMask();
    Q_INVOKABLE void lamaMaskStroke(double x1, double y1,
                                     double x2, double y2,
                                     double width);
    Q_INVOKABLE void runLamaMask();
    Q_INVOKABLE void runRemoveBackground();
    Q_INVOKABLE void runVisionAi(const QString &action,
                                 const QString &param = QString());
    Q_INVOKABLE void runVisionText(const QString &action,
                                   const QString &param = QString());
    Q_INVOKABLE void clearAiTextResult();
    Q_INVOKABLE void addText(
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
        int opacity
    );

signals:
    void imageChanged();
    void fileChanged();
    void folderChanged();
    void historyChanged();
    void aiStateChanged();
    void aiTextResultChanged();
    void errorOccurred(const QString &message);
    void lamaMaskCleared();
protected:
    bool eventFilter(QObject *watched, QEvent *event) override;
private:
    void rebuildFolderList(const QString &path);
    void loadPath(const QString &path);
    void applyImage(const QImage &image, bool addToHistory = true);
    void setAiState(bool busy, const QString &status);
    QImage renderAdjustments(const QImage &source) const;
    QString m_currentPath;
    QString m_sourcePath;
    QStringList m_folderImages;
    int m_currentIndex = -1;
    QImage m_original;
    QImage m_image;
    QImage m_adjustmentBase;
    int m_adjBrightness = 0;
    int m_adjContrast = 0;
    int m_adjSaturation = 0;
    int m_adjTemperature = 0;
    int m_adjTint = 0;
    int m_adjMonochrome = 0;
    int m_adjSepia = 0;
    QVector<QImage> m_history;
    int m_historyIndex = -1;
    quint64 m_revision = 0;
    bool m_aiBusy = false;
    QString m_aiStatus;
    QString m_aiTextResult;
};
