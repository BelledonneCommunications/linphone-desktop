#include "AbstractNotificationBackend.hpp"

#include <QFileInfo>
#include <QPainter>
#include <QStandardPaths>
#include <QSvgRenderer>

DEFINE_ABSTRACT_OBJECT(AbstractNotificationBackend)

const QHash<int, AbstractNotificationBackend::Notification> AbstractNotificationBackend::Notifications = {
    {AbstractNotificationBackend::ReceivedMessage, Notification(AbstractNotificationBackend::ReceivedMessage, 10)},
    {AbstractNotificationBackend::ReceivedCall, Notification(AbstractNotificationBackend::ReceivedCall, 30)}};

AbstractNotificationBackend::AbstractNotificationBackend(QObject *parent) : QObject(parent) {
}

QString AbstractNotificationBackend::getIconAsPng(const QString &imagePath, const QSize &size) {
	// Convertit "image://internal/phone-disconnect.svg" en ":/data/image/phone-disconnect.svg"
	QString resourcePath = imagePath;
	if (imagePath.startsWith("image://internal/"))
		resourcePath = ":/data/image/" + imagePath.mid(QString("image://internal/").length());

	QSvgRenderer renderer(resourcePath);
	if (!renderer.isValid()) return QString();

	QImage image(size, QImage::Format_ARGB32_Premultiplied);
	image.fill(Qt::transparent);
	QPainter painter(&image);
	renderer.render(&painter);
	painter.end();

	QString outPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/linphone_" +
	                  QFileInfo(resourcePath).baseName() + ".png";

	if (!QFile::exists(outPath)) image.save(outPath, "PNG");

	return outPath;
}