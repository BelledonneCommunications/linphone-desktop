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
#include <QFileInfo>
#include <QScreen>
#include <QTimer>

#include "app/App.hpp"
#include "components/call/CallModel.hpp"
#include "components/chat-events/ChatMessageModel.hpp"
#include "components/core/CoreManager.hpp"
#include "components/timeline/TimelineModel.hpp"
#include "components/timeline/TimelineListModel.hpp"
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
	{ Notifier::ReceivedMessage, { Notifier::ReceivedMessage, "NotificationReceivedMessage.qml", 10 } },
	{ Notifier::ReceivedFileMessage, { Notifier::ReceivedFileMessage, "NotificationReceivedFileMessage.qml", 10 } },
	{ Notifier::ReceivedCall, { Notifier::ReceivedCall, "NotificationReceivedCall.qml", 30 } },
	{ Notifier::NewVersionAvailable, { Notifier::NewVersionAvailable, "NotificationNewVersionAvailable.qml", 30 } },
	{ Notifier::SnapshotWasTaken, { Notifier::SnapshotWasTaken, "NotificationSnapshotWasTaken.qml", 10 } },
	{ Notifier::RecordingCompleted, { Notifier::RecordingCompleted, "NotificationRecordingCompleted.qml", 10 } }
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
		mComponents[i]->deleteLater();
	delete[] mComponents;
}

int Notifier::getNotificationOrigin() {
	return CoreManager::getInstance()->getSettingsModel()->getNotificationOrigin();
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
			int heightOffset = availableGeometry.y() + (((getNotificationOrigin() & Top) != Top )
															? (availableGeometry.height() - subWindow->height())//*screen->devicePixelRatio(); when using manual scaler
															: 0);
			if(showAsTool)
				subWindow->setProperty("showAsTool",true);
			subWindow->setX(availableGeometry.x()+ (availableGeometry.width()-subWindow->property("width").toInt()));//*screen->devicePixelRatio()); when using manual scaler
			int newScreenHeightOffset = (subWindow->height() + *screenHeightOffset) + NotificationSpacing;
			if(((getNotificationOrigin() & Top) == Top )){
				subWindow->setY(heightOffset+(*screenHeightOffset));
				if (newScreenHeightOffset + heightOffset > availableGeometry.height())
					newScreenHeightOffset = 0;
			}else{
				subWindow->setY(heightOffset-(*screenHeightOffset % heightOffset));
				if (newScreenHeightOffset - heightOffset + availableGeometry.y() >= 0)
					newScreenHeightOffset = 0;
			}
			*screenHeightOffset = newScreenHeightOffset;
			
			
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
	timer->setInterval(timeout);
	timer->setSingleShot(true);
	notification->setProperty(NotificationPropertyTimer, QVariant::fromValue(timer));
	
	// Destroy it after timeout.
	QObject::connect(timer, &QTimer::timeout, this, [this, notification]() {
		deleteNotificationOnTimeout(QVariant::fromValue(notification));
	});
	
	// Called explicitly (by a click on notification for example)
	QObject::connect(notification, SIGNAL(deleteNotification(QVariant)), this, SLOT(deleteNotification(QVariant)));
	
	timer->start();
}

// -----------------------------------------------------------------------------
void Notifier::deleteNotificationOnTimeout(QVariant notification) {
#ifdef Q_OS_MACOS
	for(auto w : QGuiApplication::topLevelWindows()){
		if( (w->windowState()&Qt::WindowFullScreen)==Qt::WindowFullScreen){
			w->requestActivate();// Used to get focus on fullscreens on Mac in order to avoid screen switching.
		}
	}
#endif
	deleteNotification(notification);
}

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
	const int timeout = Notifications[TYPE].getTimeout() * 1000; \
	showNotification(notification, timeout);

// -----------------------------------------------------------------------------
// Notification functions.
// -----------------------------------------------------------------------------

void Notifier::notifyReceivedMessages (const list<shared_ptr<linphone::ChatMessage>> &messages) {
	QVariantMap map;
	QString txt;
	if( messages.size() > 0){
		shared_ptr<linphone::ChatMessage> message = messages.front();
		
		if( messages.size() == 1){
			auto fileContent = message->getFileTransferInformation();
			if(!fileContent  ){
				foreach(auto content, message->getContents()){
					if(content->isText())
						txt += content->getUtf8Text().c_str();
				}
			}else if( fileContent->isVoiceRecording())
			//: 'Voice message received!' : message to warn the user in a notofication for voice messages.
				txt = tr("newVoiceMessage");
			else
				txt = tr("newFileMessage");
			if(txt.isEmpty() && message->hasConferenceInvitationContent())
			//: 'Conference invitation received!' : Notification about receiving an invitation to a conference.
				txt = tr("newConferenceInvitation");
		}else
		//: 'New messages received!' Notification that warn the user of new messages.
			txt = tr("newChatRoomMessages");
		map["message"] = txt;
		shared_ptr<linphone::ChatRoom> chatRoom(message->getChatRoom());
		map["timelineModel"].setValue(CoreManager::getInstance()->getTimelineListModel()->getTimeline(chatRoom, true).get());
		if( messages.size() == 1) {// Display only sender on mono message.
			map["peerAddress"] = Utils::coreStringToAppString(message->getFromAddress()->asStringUriOnly());
			map["fullPeerAddress"] = Utils::coreStringToAppString(message->getFromAddress()->asString());
		}
		map["localAddress"] = Utils::coreStringToAppString(message->getToAddress()->asStringUriOnly());
		map["fullLocalAddress"] = Utils::coreStringToAppString(message->getToAddress()->asString());
		map["window"].setValue(App::getInstance()->getMainWindow());
		CREATE_NOTIFICATION(Notifier::ReceivedMessage, map)
	}
}

void Notifier::notifyReceivedReactions(const QList<QPair<std::shared_ptr<linphone::ChatMessage>, std::shared_ptr<const linphone::ChatMessageReaction>>> &reactions) {
	QVariantMap map;
	QString txt;
	
	if( reactions.size() > 0){
		ChatMessageModel *redirection = nullptr;
		QPair<shared_ptr<linphone::ChatMessage>,std::shared_ptr<const linphone::ChatMessageReaction>> reaction = reactions.front();
		shared_ptr<linphone::ChatMessage> message = reaction.first;
		shared_ptr<linphone::ChatRoom> chatRoom(message->getChatRoom());
		auto timelineModel = CoreManager::getInstance()->getTimelineListModel()->getTimeline(chatRoom, true);
		map["messageId"] = Utils::coreStringToAppString(message->getMessageId());
		if( reactions.size() == 1){
			QString messageTxt;
			auto fileContent = message->getFileTransferInformation();
			if(!fileContent  ){
				foreach(auto content, message->getContents()){
					if(content->isText())
						messageTxt += content->getUtf8Text().c_str();
				}
			}else if( fileContent->isVoiceRecording())
			//: 'Voice message' : Voice message type that has been reacted.
				messageTxt += tr("voiceMessageReact");
			else {
				QFileInfo file(Utils::coreStringToAppString(fileContent->getFilePath()));
				messageTxt += file.fileName();
			}
			if(messageTxt.isEmpty() && message->hasConferenceInvitationContent())
			//: 'Conference invitation' : Conference invitation message type that has been reacted.
				messageTxt += tr("conferenceInvitationReact");
			//: ''Has reacted by %1 to: %2' : Reaction message. %1=Reaction(emoji), %2=type of message(Voice Message/Conference invitation/ Message text)
			txt = tr("reactionMessage").arg(Utils::coreStringToAppString(reaction.second->getBody())).arg(messageTxt);
			
		}else
		//: 'New reactions received!' : Notification that warn the user of new reactions.
			txt = tr("newReactionsMessages");
		map["message"] = txt;
		
		map["timelineModel"].setValue(timelineModel.get());
		if( reactions.size() == 1) {// Display only sender on mono message.
			map["peerAddress"] = Utils::coreStringToAppString(reaction.second->getFromAddress()->asStringUriOnly());
			map["fullPeerAddress"] = Utils::coreStringToAppString(reaction.second->getFromAddress()->asString());
		}
		map["localAddress"] = Utils::coreStringToAppString(chatRoom->getLocalAddress()->asStringUriOnly());
		map["fullLocalAddress"] = Utils::coreStringToAppString(chatRoom->getLocalAddress()->asString());
		map["window"].setValue(App::getInstance()->getMainWindow());
		CREATE_NOTIFICATION(Notifier::ReceivedMessage, map)
	}
}

void Notifier::notifyReceivedFileMessage (const shared_ptr<linphone::ChatMessage> &message, const shared_ptr<linphone::Content> &content) {
	QVariantMap map;
	shared_ptr<linphone::ChatRoom> chatRoom(message->getChatRoom());
	map["timelineModel"].setValue(CoreManager::getInstance()->getTimelineListModel()->getTimeline(chatRoom, true).get());
	map["fileUri"] = Utils::coreStringToAppString(content->getFilePath());
	if( Utils::getImage(map["fileUri"].toString()).isNull())
		map["imageUri"] = "";
	else
		map["imageUri"] = map["fileUri"];
	map["fileSize"] = quint64(content->getSize() + content->getFileSize());
	CREATE_NOTIFICATION(Notifier::ReceivedFileMessage, map)
}

void Notifier::notifyReceivedCall (const shared_ptr<linphone::Call> &call) {
	if(call->dataExists("call-model")){
		CallModel *callModel = &call->getData<CallModel>("call-model");
		QVariantMap map;
		map["call"].setValue(callModel);
		CREATE_NOTIFICATION(Notifier::ReceivedCall, map)
				
		QObject::connect(callModel, &CallModel::statusChanged, notification, [this, notification](CallModel::CallStatus status) {
			if (status == CallModel::CallStatusEnded || status == CallModel::CallStatusConnected)
				deleteNotification(QVariant::fromValue(notification));
		});
		QObject::connect(callModel, &CallModel::destroyed, notification, [this, notification]() {
				deleteNotification(QVariant::fromValue(notification));
		});
	}
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
