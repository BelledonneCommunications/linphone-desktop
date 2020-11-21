/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linphone-desktop
 * (see https://www.linphone.org).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQuickWindow>
#include <QQuickItem>
#include <QQuickView>
#include <QScreen>
#include <QTimer>

#include "app/App.hpp"
#include "components/call/CallModel.hpp"
#include "components/core/CoreManager.hpp"
#include "utils/Utils.hpp"

#include "Notifier.hpp"

// =============================================================================

using namespace std;

namespace {
  constexpr char NotificationsPath[] = "qrc:/ui/modules/Linphone/Notifications/";

  // ---------------------------------------------------------------------------
  // Notifications QML properties/methods.
  // ---------------------------------------------------------------------------

  constexpr char NotificationShowMethodName[] = "open";

  constexpr char NotificationPropertyData[] = "notificationData";

  constexpr char NotificationPropertyX[] = "popupX";
  constexpr char NotificationPropertyY[] = "popupY";

  constexpr char NotificationPropertyWindow[] = "__internalWindow";

  constexpr char NotificationPropertyTimer[] = "__timer";

  // ---------------------------------------------------------------------------
  // Arbitrary hardcoded values.
  // ---------------------------------------------------------------------------

  constexpr int NotificationSpacing = 10;
  constexpr int MaxNotificationsNumber = 5;
  constexpr int MaxTimeout = 30000;
}

// =============================================================================

template<class T>
void setProperty (QObject &object, const char *property, const T &value) {
  if (!object.setProperty(property, QVariant(value))) {
    qWarning() << QStringLiteral("Unable to set property: `%1`.").arg(property);
    abort();
  }
}

// =============================================================================
// Available notifications.
// =============================================================================

const QHash<int, Notifier::Notification> Notifier::Notifications = {
  { Notifier::ReceivedMessage, { "NotificationReceivedMessage.qml", 10 } },
  { Notifier::ReceivedFileMessage, { "NotificationReceivedFileMessage.qml", 10 } },
  { Notifier::ReceivedCall, { "NotificationReceivedCall.qml", 30 } },
  { Notifier::NewVersionAvailable, { "NotificationNewVersionAvailable.qml", 30 } },
  { Notifier::SnapshotWasTaken, { "NotificationSnapshotWasTaken.qml", 10 } },
  { Notifier::RecordingCompleted, { "NotificationRecordingCompleted.qml", 10 } }
};

// -----------------------------------------------------------------------------

Notifier::Notifier (QObject *parent) : QObject(parent) {
  const int nComponents = Notifications.size();
  mComponents = new QQmlComponent *[nComponents];

  QQmlEngine *engine = App::getInstance()->getEngine();
  for (const auto &key : Notifications.keys()) {
    QQmlComponent *component = new QQmlComponent(engine, QUrl(NotificationsPath + Notifier::Notifications[key].filename));
    if (Q_UNLIKELY(component->isError())) {
      qWarning() << QStringLiteral("Errors found in `Notification` component %1:").arg(key) << component->errors();
      abort();
    }
    mComponents[key] = component;
  }

  mMutex = new QMutex();
}

Notifier::~Notifier () {
  delete mMutex;

  const int nComponents = Notifications.size();
  for (int i = 0; i < nComponents; ++i)
    delete mComponents[i];
  delete[] mComponents;
}

// -----------------------------------------------------------------------------

QObject *Notifier::createNotification (Notifier::NotificationType type, QVariantMap data) {
	QQuickItem *wrapperItem = nullptr;
	mMutex->lock();
	Q_ASSERT(mInstancesNumber <= MaxNotificationsNumber);
	if (mInstancesNumber == MaxNotificationsNumber) {	// Check existing instances.
		qWarning() << QStringLiteral("Unable to create another notification.");
		mMutex->unlock();
		return nullptr;
	}
	QList<QScreen *> allScreens = QGuiApplication::screens();
	if(allScreens.size() > 0){	// Ensure to have a screen to avoid errors
		QQuickItem * previousWrapper = nullptr;
		++mInstancesNumber;
		bool showAsTool = false;
#ifdef Q_OS_MACOS
		for(auto w : QGuiApplication::topLevelWindows()){
			if( (w->windowState()&Qt::WindowFullScreen)==Qt::WindowFullScreen){
				showAsTool = true;
				w->raise();// Used to get focus on Mac (On Mac, A Tool is hidden if the app has not focus and the only way to rid it is to use Widget Attributes(Qt::WA_MacAlwaysShowToolWindow) that is not available)
			}
		}
#endif
		for(int i = 0 ; i < allScreens.size() ; ++i){
			QQuickView *view = new QQuickView(App::getInstance()->getEngine(), nullptr);	// Use QQuickView to create a visual root object that is independant from current application Window
			QScreen *screen = allScreens[i];
			QObject::connect(view, &QQuickView::statusChanged, [allScreens](QQuickView::Status status){	// Debug handler : show screens descriptions on Error
				if( status == QQuickView::Error){
					QScreen * primaryScreen = QGuiApplication::primaryScreen();
					qInfo() << "Primary screen : " << primaryScreen->geometry() << primaryScreen->availableGeometry() <<  primaryScreen->virtualGeometry() <<  primaryScreen->availableVirtualGeometry();
					for(int i = 0 ; i < allScreens.size() ; ++i){
						QScreen *screen = allScreens[i];
						qInfo() << QString("Screen [")+QString::number(i)+"] (hdpi, Geometry, Available, Virtual, AvailableGeometry) :" 
							<< screen->devicePixelRatio() << screen->geometry() << screen->availableGeometry() << screen->virtualGeometry() << screen->availableVirtualGeometry();
					}
				}
			});
			view->setScreen(screen);	// Bind the visual root object to the screen
			view->setProperty("flags", QVariant(Qt::BypassWindowManagerHint | Qt::WindowStaysOnBottomHint | Qt::CustomizeWindowHint | Qt::X11BypassWindowManagerHint));	// Set the visual ghost window
			view->setSource(QString(NotificationsPath)+Notifier::Notifications[type].filename);

			QQuickWindow *subWindow = view->findChild<QQuickWindow *>("__internalWindow");
			QObject::connect(subWindow, &QObject::destroyed, view, &QObject::deleteLater);	// When destroying window, detroy visual root object too

			int * screenHeightOffset = &mScreenHeightOffset[screen->name()];	// Access optimization
			QRect availableGeometry = screen->availableGeometry();
			int heightOffset = availableGeometry.y() + (availableGeometry.height() - subWindow->height());//*screen->devicePixelRatio(); when using manual scaler
			if(showAsTool)
				subWindow->setProperty("showAsTool",true);
			subWindow->setX(availableGeometry.x()+ (availableGeometry.width()-subWindow->property("width").toInt()));//*screen->devicePixelRatio()); when using manual scaler
			subWindow->setY(heightOffset-(*screenHeightOffset % heightOffset));

			*screenHeightOffset = (subWindow->height() + *screenHeightOffset) + NotificationSpacing;
			if (*screenHeightOffset - heightOffset + availableGeometry.y() >= 0)
				*screenHeightOffset = 0;

//			if(primaryScreen != screen){	//Useful when doing manual scaling jobs. Need to implement scaler in GUI objects
//				//subwindow->setProperty("xScale", (double)screen->availableVirtualGeometry().width()/availableGeometry.width() );
//				//subwindow->setProperty("yScale", (double)screen->availableVirtualGeometry().height()/availableGeometry.height());
//			}
			wrapperItem = view->findChild<QQuickItem *>("__internalWrapper");
			::setProperty(*wrapperItem, NotificationPropertyData,data);
			view->setGeometry(subWindow->geometry());	// Ensure to have sufficient space to both let painter do job without error, and stay behind popup

			if(previousWrapper!=nullptr){	// Link objects in order to propagate events without having to store them
				QObject::connect(previousWrapper, SIGNAL(deleteNotification(QVariant)), wrapperItem,SLOT(deleteNotificationSlot()));
				QObject::connect(wrapperItem, SIGNAL(isOpened()), previousWrapper,SLOT(open()));
				QObject::connect(wrapperItem, SIGNAL(isClosed()), previousWrapper,SLOT(close()));
				QObject::connect(wrapperItem, &QObject::destroyed, previousWrapper, &QObject::deleteLater);
			}
			previousWrapper = wrapperItem;	// The last one is used as a point of start when deleting and openning

			view->show();
		}
		qInfo() << QStringLiteral("Create notifications:") << wrapperItem;
	}
	
	mMutex->unlock();
	return wrapperItem;
}

// -----------------------------------------------------------------------------

void Notifier::showNotification (QObject *notification, int timeout) {
  // Display notification.
  QMetaObject::invokeMethod(notification, NotificationShowMethodName, Qt::DirectConnection);

  QTimer *timer = new QTimer(notification);
  timer->setInterval(timeout > MaxTimeout ? MaxTimeout : timeout);
  timer->setSingleShot(true);
  notification->setProperty(NotificationPropertyTimer, QVariant::fromValue(timer));

  // Destroy it after timeout.
  QObject::connect(timer, &QTimer::timeout, this, [this, notification]() {
    deleteNotification(QVariant::fromValue(notification));
  });

  // Called explicitly (by a click on notification for example)
  QObject::connect(notification, SIGNAL(deleteNotification(QVariant)), this, SLOT(deleteNotification(QVariant)));

  timer->start();
}

// -----------------------------------------------------------------------------

void Notifier::deleteNotification (QVariant notification) {
  mMutex->lock();

  QObject *instance = notification.value<QObject *>();

  // Notification marked destroyed.
  if (instance->property("__valid").isValid()) {
    mMutex->unlock();
    return;
  }

  qInfo() << QStringLiteral("Delete notification:") << instance;

  instance->setProperty("__valid", true);
  instance->property(NotificationPropertyTimer).value<QTimer *>()->stop();

  mInstancesNumber--;
  Q_ASSERT(mInstancesNumber >= 0);

  if (mInstancesNumber == 0)
	mScreenHeightOffset.clear();

  mMutex->unlock();

  instance->deleteLater();
}

// =============================================================================

#define CREATE_NOTIFICATION(TYPE, DATA) \
  QObject * notification = createNotification(TYPE, DATA); \
  if (!notification) \
    return; \
  const int timeout = Notifications[TYPE].timeout * 1000; \
  showNotification(notification, timeout);

// -----------------------------------------------------------------------------
// Notification functions.
// -----------------------------------------------------------------------------

void Notifier::notifyReceivedMessage (const shared_ptr<linphone::ChatMessage> &message) {
  QVariantMap map;
  QString txt;
  if(! message->getFileTransferInformation() ){
	  foreach(auto content, message->getContents()){
		  if(content->isText())
			  txt += content->getStringBuffer().c_str();
	  }
  }else
	  txt = tr("newFileMessage");
  map["message"] = txt;
  shared_ptr<linphone::ChatRoom> chatRoom(message->getChatRoom());
  map["peerAddress"] = Utils::coreStringToAppString(chatRoom->getPeerAddress()->asStringUriOnly());
  map["localAddress"] = Utils::coreStringToAppString(chatRoom->getLocalAddress()->asStringUriOnly());
  map["fullPeerAddress"] = QString::fromStdString(chatRoom->getPeerAddress()->asString());
  map["fullLocalAddress"] = QString::fromStdString(chatRoom->getLocalAddress()->asString());
  map["window"].setValue(App::getInstance()->getMainWindow());
  CREATE_NOTIFICATION(Notifier::ReceivedMessage, map)
}

void Notifier::notifyReceivedFileMessage (const shared_ptr<linphone::ChatMessage> &message) {
  QVariantMap map;
  map["fileUri"] = Utils::coreStringToAppString(message->getFileTransferInformation()->getFilePath());
  if( Utils::getImage(map["fileUri"].toString()).isNull())
    map["imageUri"] = "";
  else
    map["imageUri"] = map["fileUri"];
  map["fileSize"] = quint64(message->getFileTransferInformation()->getSize() +message->getFileTransferInformation()->getFileSize());
  CREATE_NOTIFICATION(Notifier::ReceivedFileMessage, map)
}

void Notifier::notifyReceivedCall (const shared_ptr<linphone::Call> &call) {
  CallModel *callModel = &call->getData<CallModel>("call-model");
  QVariantMap map;
  map["call"].setValue(callModel);
  CREATE_NOTIFICATION(Notifier::ReceivedCall, map)

  QObject::connect(callModel, &CallModel::statusChanged, notification, [this, notification](CallModel::CallStatus status) {
      if (status == CallModel::CallStatusEnded || status == CallModel::CallStatusConnected)
        deleteNotification(QVariant::fromValue(notification));
    });

}

void Notifier::notifyNewVersionAvailable (const QString &version, const QString &url) {
  QVariantMap map;
  map["message"] = tr("newVersionAvailable").arg(version);
  map["url"] = url;
  CREATE_NOTIFICATION(Notifier::NewVersionAvailable, map)
}

void Notifier::notifySnapshotWasTaken (const QString &filePath) {
  QVariantMap map;
  map["filePath"] = filePath;
  CREATE_NOTIFICATION(Notifier::SnapshotWasTaken, map)
}

void Notifier::notifyRecordingCompleted (const QString &filePath) {
  QVariantMap map;
  map["filePath"] = filePath;
  CREATE_NOTIFICATION(Notifier::RecordingCompleted, map)
}

#undef SHOW_NOTIFICATION
#undef CREATE_NOTIFICATION
