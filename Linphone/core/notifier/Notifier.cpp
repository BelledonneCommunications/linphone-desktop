/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#include <QFileInfo>
#include <QMutex>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQuickItem>
#include <QQuickView>
#include <QQuickWindow>
#include <QScreen>
#include <QTimer>

#include "Notifier.hpp"

#include "core/App.hpp"
#include "core/call/CallGui.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/LinphoneEnums.hpp"
#include "tool/providers/AvatarProvider.hpp"
#include "tool/providers/ImageProvider.hpp"

DEFINE_ABSTRACT_OBJECT(Notifier)

// =============================================================================

using namespace std;

namespace {
constexpr char NotificationsPath[] = "qrc:/Linphone/view/Control/Popup/Notification/";

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
} // namespace

// =============================================================================

template <class T>
void setProperty(QObject &object, const char *property, const T &value) {
	if (!object.setProperty(property, QVariant(value))) {
		qWarning() << QStringLiteral("Unable to set property: `%1`.").arg(property);
		abort();
	}
}

// =============================================================================
// Available notifications.
// =============================================================================

const QHash<int, Notifier::Notification> Notifier::Notifications = {
    //{Notifier::ReceivedMessage, {Notifier::ReceivedMessage, "NotificationReceivedMessage.qml", 10}},
    //{Notifier::ReceivedFileMessage, {Notifier::ReceivedFileMessage, "NotificationReceivedFileMessage.qml", 10}},
    {Notifier::ReceivedCall, {Notifier::ReceivedCall, "NotificationReceivedCall.qml", 30}},
    //{Notifier::NewVersionAvailable, {Notifier::NewVersionAvailable, "NotificationNewVersionAvailable.qml", 30}},
    //{Notifier::SnapshotWasTaken, {Notifier::SnapshotWasTaken, "NotificationSnapshotWasTaken.qml", 10}},
    //{Notifier::RecordingCompleted, {Notifier::RecordingCompleted, "NotificationRecordingCompleted.qml", 10}}
};

// -----------------------------------------------------------------------------

Notifier::Notifier(QObject *parent) : QObject(parent) {
	mustBeInMainThread(getClassName());
	const int nComponents = Notifications.size();
	mComponents.resize(nComponents);

	QQmlEngine *engine = App::getInstance()->mEngine;
	for (const auto &key : Notifications.keys()) {
		QQmlComponent *component =
		    new QQmlComponent(engine, QUrl(NotificationsPath + Notifier::Notifications[key].filename));
		if (Q_UNLIKELY(component->isError())) {
			qWarning() << QStringLiteral("Errors found in `Notification` component %1:").arg(key)
			           << component->errors();
			abort();
		}
		mComponents[key] = component;
	}

	mMutex = new QMutex();
}

Notifier::~Notifier() {
	mustBeInMainThread("~" + getClassName());
	delete mMutex;

	const int nComponents = Notifications.size();
	mComponents.clear();
}

// -----------------------------------------------------------------------------

bool Notifier::createNotification(Notifier::NotificationType type, QVariantMap data) {
	mMutex->lock();
	Q_ASSERT(mInstancesNumber <= MaxNotificationsNumber);
	if (mInstancesNumber == MaxNotificationsNumber) { // Check existing instances.
		qWarning() << QStringLiteral("Unable to create another notification.");
		mMutex->unlock();
		return false;
	}
	QList<QScreen *> allScreens = QGuiApplication::screens();
	if (allScreens.size() > 0) { // Ensure to have a screen to avoid errors
		QQuickItem *previousWrapper = nullptr;
		bool showAsTool = false;
#ifdef Q_OS_MACOS
		for (auto w : QGuiApplication::topLevelWindows()) {
			if ((w->windowState() & Qt::WindowFullScreen) == Qt::WindowFullScreen) {
				showAsTool = true;
				w->raise(); // Used to get focus on Mac (On Mac, A Tool is hidden if the app has not focus and the only
				            // way to rid it is to use Widget Attributes(Qt::WA_MacAlwaysShowToolWindow) that is not
				            // available)
			}
		}
#endif
		for (int i = 0; i < allScreens.size(); ++i) {

			++mInstancesNumber;
			// Use QQuickView to create a visual root object that is
			// independant from current application Window
			QScreen *screen = allScreens[i];
			// auto engine = App::getInstance()->mEngine;
			auto engine = new QQmlApplicationEngine();
			engine->addImageProvider(ImageProvider::ProviderId, new ImageProvider());
			engine->addImageProvider(AvatarProvider::ProviderId, new AvatarProvider());
			engine->addImportPath(":/");
			// if(showAsTool) window->setProperty("showAsTool",true);
			engine->setInitialProperties(data);
			//  engine->rootContext()->setContextProperty("applicationDirPath",QGuiApplication::applicationDirPath());
			//  engine->setInitialProperties({{"screenIndex", i}});
			//, {"x", screen->geometry().x()}, {"y", screen->geometry().y()}});
			const QUrl url(QString(NotificationsPath) + Notifier::Notifications[type].filename);
			QObject::connect(
			    engine, &QQmlApplicationEngine::objectCreated, this,
			    [this, url, screen, engine, type](QObject *obj, const QUrl &objUrl) {
				    if (!obj && url == objUrl) {
					    lCritical() << "[App] Notifier.qml couldn't be load.";
					    engine->deleteLater();
					    exit(-1);
				    } else {
					    lDebug() << engine->rootObjects()[0];
					    auto window = qobject_cast<QQuickWindow *>(obj);
					    if (window) {
						    int *screenHeightOffset = &mScreenHeightOffset[screen->name()]; // Access optimization
						    QRect availableGeometry = screen->availableGeometry();
						    int heightOffset =
						        availableGeometry.y() +
						        (availableGeometry.height() -
						         window->height()); //*screen->devicePixelRatio(); when using manual scaler

						    window->setX(availableGeometry.x() +
						                 (availableGeometry.width() -
						                  window->property("width")
						                      .toInt())); //*screen->devicePixelRatio()); when using manual scaler
						    window->setY(heightOffset - (*screenHeightOffset % heightOffset));
						    const int timeout = Notifications[type].getTimeout() * 1000;
						    QObject::connect(window, &QQuickWindow::closing, window,
						                     [this, window] { deleteNotification(QVariant::fromValue(window)); });
						    showNotification(window, timeout);
						    lInfo() << QStringLiteral("Create notification:") << QVariant::fromValue(window);
					    }
				    }
			    },
			    Qt::QueuedConnection);
			engine->load(url);
		}
	}

	mMutex->unlock();
	return true;
}

// -----------------------------------------------------------------------------

void Notifier::showNotification(QObject *notification, int timeout) {
	// Display notification.
	QMetaObject::invokeMethod(notification, NotificationShowMethodName, Qt::DirectConnection);

	QTimer *timer = new QTimer(notification);
	timer->setInterval(timeout);
	timer->setSingleShot(true);
	notification->setProperty(NotificationPropertyTimer, QVariant::fromValue(timer));

	// Destroy it after timeout.
	QObject::connect(timer, &QTimer::timeout, this,
	                 [this, notification]() { deleteNotificationOnTimeout(QVariant::fromValue(notification)); });

	// Called explicitly (by a click on notification for example)
	QObject::connect(notification, SIGNAL(deleteNotification(QVariant)), this, SLOT(deleteNotification(QVariant)));

	timer->start();
}

// -----------------------------------------------------------------------------
void Notifier::deleteNotificationOnTimeout(QVariant notification) {
#ifdef Q_OS_MACOS
	for (auto w : QGuiApplication::topLevelWindows()) {
		if ((w->windowState() & Qt::WindowFullScreen) == Qt::WindowFullScreen) {
			w->requestActivate(); // Used to get focus on fullscreens on Mac in order to avoid screen switching.
		}
	}
#endif
	deleteNotification(notification);
}

void Notifier::deleteNotification(QVariant notification) {
	mMutex->lock();

	QObject *instance = notification.value<QObject *>();

	// Notification marked destroyed.
	if (instance->property("__valid").isValid()) {
		mMutex->unlock();
		return;
	}

	lInfo() << QStringLiteral("Delete notification:") << instance << --mInstancesNumber;

	instance->setProperty("__valid", true);
	auto timerProperty = instance->property(NotificationPropertyTimer).value<QTimer *>();
	if (timerProperty) timerProperty->stop();

	Q_ASSERT(mInstancesNumber >= 0);

	if (mInstancesNumber == 0) mScreenHeightOffset.clear();

	mMutex->unlock();

	instance->deleteLater();
}

// =============================================================================

#define CREATE_NOTIFICATION(TYPE, DATA)                                                                                \
	auto settings = App::getInstance()->getSettings();                                                                 \
	if (settings && settings->dndEnabled()) return;                                                                    \
	createNotification(TYPE, DATA);

// -----------------------------------------------------------------------------
// Notification functions.
// -----------------------------------------------------------------------------

void Notifier::notifyReceivedCall(const shared_ptr<linphone::Call> &call) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto remoteAddress = call->getRemoteAddress();
	auto accountSender = ToolModel::findAccount(remoteAddress);
	auto account = ToolModel::findAccount(call->getToAddress());
	if (account) {
		auto accountModel = Utils::makeQObject_ptr<AccountModel>(account);
		accountModel->setSelf(accountModel);
		if (!accountModel->getNotificationsAllowed()) {
			qInfo()
			    << "Notifications have been disabled for this account - not creating a notification for incoming call";
			return;
		}
	}

	auto model = CallCore::create(call);
	auto gui = new CallGui(model);
	gui->moveToThread(App::getInstance()->thread());
	App::postCoreAsync([this, gui]() {
		mustBeInMainThread(getClassName());
		QVariantMap map;

		map["call"].setValue(gui);
		CREATE_NOTIFICATION(Notifier::ReceivedCall, map)
	});
}

/*
void Notifier::notifyReceivedMessages(const list<shared_ptr<linphone::ChatMessage>> &messages) {
    QVariantMap map;
    QString txt;
    if (messages.size() > 0) {
        shared_ptr<linphone::ChatMessage> message = messages.front();

        if (messages.size() == 1) {
            auto fileContent = message->getFileTransferInformation();
            if (!fileContent) {
                foreach (auto content, message->getContents()) {
                    if (content->isText()) txt += content->getUtf8Text().c_str();
                }
            } else if (fileContent->isVoiceRecording())
                //: 'Voice message received!' : message to warn the user in a notofication for voice messages.
                txt = tr("newVoiceMessage");
            else txt = tr("newFileMessage");
            if (txt.isEmpty() && message->hasConferenceInvitationContent())
                //: 'Conference invitation received!' : Notification about receiving an invitation to a conference.
                txt = tr("newConferenceInvitation");
        } else
            //: 'New messages received!' Notification that warn the user of new messages.
            txt = tr("newChatRoomMessages");
        map["message"] = txt;
        shared_ptr<linphone::ChatRoom> chatRoom(message->getChatRoom());
        map["timelineModel"].setValue(
            CoreManager::getInstance()->getTimelineListModel()->getTimeline(chatRoom, true).get());
        if (messages.size() == 1) { // Display only sender on mono message.
            map["peerAddress"] = Utils::coreStringToAppString(message->getFromAddress()->asStringUriOnly());
            map["fullPeerAddress"] = Utils::coreStringToAppString(message->getFromAddress()->asString());
        }
        map["localAddress"] = Utils::coreStringToAppString(message->getToAddress()->asStringUriOnly());
        map["fullLocalAddress"] = Utils::coreStringToAppString(message->getToAddress()->asString());
        map["window"].setValue(App::getInstance()->getMainWindow());
        CREATE_NOTIFICATION(Notifier::ReceivedMessage, map)
    }
}

void Notifier::notifyReceivedReactions(
    const QList<QPair<std::shared_ptr<linphone::ChatMessage>, std::shared_ptr<const linphone::ChatMessageReaction>>>
        &reactions) {
    QVariantMap map;
    QString txt;

    if (reactions.size() > 0) {
        ChatMessageModel *redirection = nullptr;
        QPair<shared_ptr<linphone::ChatMessage>, std::shared_ptr<const linphone::ChatMessageReaction>> reaction =
            reactions.front();
        shared_ptr<linphone::ChatMessage> message = reaction.first;
        shared_ptr<linphone::ChatRoom> chatRoom(message->getChatRoom());
        auto timelineModel = CoreManager::getInstance()->getTimelineListModel()->getTimeline(chatRoom, true);
        map["messageId"] = Utils::coreStringToAppString(message->getMessageId());
        if (reactions.size() == 1) {
            QString messageTxt;
            auto fileContent = message->getFileTransferInformation();
            if (!fileContent) {
                foreach (auto content, message->getContents()) {
                    if (content->isText()) messageTxt += content->getUtf8Text().c_str();
                }
            } else if (fileContent->isVoiceRecording())
                //: 'Voice message' : Voice message type that has been reacted.
                messageTxt += tr("voiceMessageReact");
            else {
                QFileInfo file(Utils::coreStringToAppString(fileContent->getFilePath()));
                messageTxt += file.fileName();
            }
            if (messageTxt.isEmpty() && message->hasConferenceInvitationContent())
                //: 'Conference invitation' : Conference invitation message type that has been reacted.
                messageTxt += tr("conferenceInvitationReact");
            //: ''Has reacted by %1 to: %2' : Reaction message. %1=Reaction(emoji), %2=type of message(Voice
            //: Message/Conference invitation/ Message text)
            txt = tr("reactionMessage").arg(Utils::coreStringToAppString(reaction.second->getBody())).arg(messageTxt);

        } else
            //: 'New reactions received!' : Notification that warn the user of new reactions.
            txt = tr("newReactionsMessages");
        map["message"] = txt;

        map["timelineModel"].setValue(timelineModel.get());
        if (reactions.size() == 1) { // Display only sender on mono message.
            map["peerAddress"] = Utils::coreStringToAppString(reaction.second->getFromAddress()->asStringUriOnly());
            map["fullPeerAddress"] = Utils::coreStringToAppString(reaction.second->getFromAddress()->asString());
        }
        map["localAddress"] = Utils::coreStringToAppString(chatRoom->getLocalAddress()->asStringUriOnly());
        map["fullLocalAddress"] = Utils::coreStringToAppString(chatRoom->getLocalAddress()->asString());
        map["window"].setValue(App::getInstance()->getMainWindow());
        CREATE_NOTIFICATION(Notifier::ReceivedMessage, map)
    }
}

void Notifier::notifyReceivedFileMessage(const shared_ptr<linphone::ChatMessage> &message,
                                         const shared_ptr<linphone::Content> &content) {
    QVariantMap map;
    shared_ptr<linphone::ChatRoom> chatRoom(message->getChatRoom());
    map["timelineModel"].setValue(
        CoreManager::getInstance()->getTimelineListModel()->getTimeline(chatRoom, true).get());
    map["fileUri"] = Utils::coreStringToAppString(content->getFilePath());
    if (Utils::getImage(map["fileUri"].toString()).isNull()) map["imageUri"] = "";
    else map["imageUri"] = map["fileUri"];
    map["fileSize"] = quint64(content->getSize() + content->getFileSize());
    CREATE_NOTIFICATION(Notifier::ReceivedFileMessage, map)
}



void Notifier::notifyNewVersionAvailable(const QString &version, const QString &url) {
    QVariantMap map;
    map["message"] = tr("newVersionAvailable").arg(version);
    map["url"] = url;
    CREATE_NOTIFICATION(Notifier::NewVersionAvailable, map)
}

void Notifier::notifySnapshotWasTaken(const QString &filePath) {
    QVariantMap map;
    map["filePath"] = filePath;
    CREATE_NOTIFICATION(Notifier::SnapshotWasTaken, map)
}

void Notifier::notifyRecordingCompleted(const QString &filePath) {
    QVariantMap map;
    map["filePath"] = filePath;
    CREATE_NOTIFICATION(Notifier::RecordingCompleted, map)
}
*/
#undef SHOW_NOTIFICATION
#undef CREATE_NOTIFICATION
