#include "WindowsNotificationBackend.hpp"
#include "core/App.hpp"
#include "core/call/CallGui.hpp"
#include "core/chat/ChatGui.hpp"
#include "core/event-filter/LockEventFilter.hpp"
#include "tool/Constants.hpp"
#include "tool/Utils.hpp"

#include "DesktopNotificationManagerCompat.hpp"
#include <windows.foundation.h>
#include <windows.ui.notifications.h>

#include <QDebug>
#include <iostream>
#include <random>
#include <string>

using namespace Microsoft::WRL;
using namespace ABI::Windows::UI::Notifications;
using namespace ABI::Windows::Foundation;
using namespace Microsoft::WRL::Wrappers;

NotificationBackend::NotificationBackend(QObject *parent) : AbstractNotificationBackend(parent) {
	connect(App::getInstance(), &App::sessionLockedChanged, this, [this] {
		if (!App::getInstance()->getSessionLocked()) {
			qDebug() << "Session unlocked, flush pending notifications";
			flushPendingNotifications();
		}
	});
}

void NotificationBackend::flushPendingNotifications() {
	for (const auto &notif : mPendingNotifications) {
		sendNotification(notif.type, notif.data);
	}
	mPendingNotifications.clear();
}

void NotificationBackend::sendMessageNotification(QVariantMap data) {

	IToastNotifier *notifier = nullptr;
	HRESULT hr = DesktopNotificationManagerCompat::CreateToastNotifier(&notifier);
	if (FAILED(hr) || !notifier) {
		lWarning() << "CreateToastNotifier failed:" << Qt::hex << hr;
		return;
	}

	auto msgTxt = data["message"].toString().toStdWString();
	auto remoteAddress = data["remoteAddress"].toString().toStdWString();
	auto chatRoomName = data["chatRoomName"].toString().toStdWString();
	auto chatRoomAddress = data["chatRoomAddress"].toString().toStdWString();
	auto appIcon = Utils::getIconAsPng(Utils::getAppIcon("logo").toString()).toStdWString();
	auto avatarUri = data["avatarUri"].toString().toStdWString();
	bool isGroup = data["isGroupChat"].toBool();
	ChatGui *chat = data["chat"].value<ChatGui *>();

	std::wstring xml = L"<toast>"
	                   L"    <visual>"
	                   L"        <binding template=\"ToastGeneric\">"
	                   L"            <image src=\"file:///" +
	                   appIcon +
	                   L"\" placement=\"appLogoOverride\"/>"
	                   L"            <text><![CDATA[" +
	                   chatRoomName +
	                   L"]]></text>"
	                   L"            <text><![CDATA[" +
	                   (isGroup ? remoteAddress : L"") +
	                   L"]]></text>"
	                   L"            <group>"
	                   L"                <subgroup>"
	                   L"                    <text hint-style=\"body\"><![CDATA[" +
	                   msgTxt +
	                   L"]]></text>"
	                   L"                </subgroup>"
	                   L"            </group>"
	                   L"        </binding>"
	                   L"    </visual>"
	                   L"    <audio silent=\"true\"/>"
	                   L"</toast>";

	ABI::Windows::Data::Xml::Dom::IXmlDocument *doc = nullptr;
	hr = DesktopNotificationManagerCompat::CreateXmlDocumentFromString(xml.c_str(), &doc);
	if (FAILED(hr) || !doc) {
		lWarning() << "CreateXmlDocumentFromString failed:" << Qt::hex << hr;
		notifier->Release();
		return;
	}

	IToastNotification *toast = nullptr;
	hr = DesktopNotificationManagerCompat::CreateToastNotification(doc, &toast);
	if (FAILED(hr) || !toast) {
		lWarning() << "CreateToastNotification failed:" << Qt::hex << hr;
		doc->Release();
		notifier->Release();
		Utils::showInformationPopup(tr("info_popup_error_title"), tr("info_popup_error_creating_notification"), false);
		return;
	}

	EventRegistrationToken token;
	toast->add_Activated(Microsoft::WRL::Callback<ITypedEventHandler<ToastNotification *, IInspectable *>>(
	                         [this, chat](IToastNotification *sender, IInspectable *args) -> HRESULT {
		                         qInfo() << "Message toast clicked!";

		                         Utils::openChat(chat);

		                         return S_OK;
	                         })
	                         .Get(),
	                     &token);

	hr = notifier->Show(toast);
	if (FAILED(hr)) {
		lWarning() << "Toast Show failed:" << Qt::hex << hr;
	}

	toast->Release();
	doc->Release();
	notifier->Release();
}

std::string generateRandomHexString(size_t length) {
	static const char hexChars[] = "0123456789abcdef";
	std::random_device rd;
	std::uniform_int_distribution<int> dist(0, 15);

	std::string result;
	result.reserve(length);
	for (size_t i = 0; i < length; ++i)
		result += hexChars[dist(rd)];
	return result;
}

void NotificationBackend::sendCallNotification(QVariantMap data) {

	IToastNotifier *notifier = nullptr;
	HRESULT hr = DesktopNotificationManagerCompat::CreateToastNotifier(&notifier);
	if (FAILED(hr) || !notifier) {
		lWarning() << "CreateToastNotifier failed:" << Qt::hex << hr;
		return;
	}

	auto displayName = data["displayName"].toString().toStdWString();
	auto remoteAddress = data["remoteAddress"].toString().toStdWString();
	CallGui *call = data["call"].value<CallGui *>();
	// int timeout = AbstractNotificationBackend::Notification[(int)NotificationType::ReceivedCall].getTimeout();

	// Incoming call
	auto callDescription = tr("incoming_call").toStdWString();

	QList<ToastButton> actions;
	QString declineIcon = Utils::getIconAsPng(Utils::getAppIcon("endCall").toString());
	QString acceptIcon = Utils::getIconAsPng(Utils::getAppIcon("phone").toString());
	auto appIcon = Utils::getIconAsPng(Utils::getAppIcon("logo").toString()).toStdWString();
	//: Accept
	actions.append(ToastButton(tr("accept_button"), "accept", acceptIcon));
	//: Decline
	actions.append(ToastButton(tr("decline_button"), "decline", declineIcon));
	std::wstring wActions;
	if (!actions.isEmpty()) {
		wActions += L"<actions>";
		for (const auto &action : actions) {
			std::wstring wLabel = action.label.toStdWString();
			std::wstring wArg = action.argument.toStdWString();
			std::wstring wIcon = action.icon.toStdWString();
			qDebug() << "toast icon action" << wIcon;
			wActions +=
			    L"<action content=\"" + wLabel + L"\" arguments=\"" + wArg + L"\" imageUri=\"" + wIcon + L"\"/>";
		}
		wActions += L"</actions>";
	}

	std::wstring xml = L"<toast scenario=\"reminder\">"
	                   L"    <visual>"
	                   L"        <binding template=\"ToastGeneric\">"
	                   L"            <image src=\"file:///" +
	                   appIcon +
	                   L"\" placement=\"appLogoOverride\"/>"
	                   L"            <text hint-style=\"header\">" +
	                   displayName +
	                   L"</text>"
	                   L"            <text hint-style=\"base\">" +
	                   remoteAddress +
	                   L"</text>"
	                   L"            <text hint-style=\"body\">" +
	                   callDescription +
	                   L"</text>"
	                   L"        </binding>"
	                   L"    </visual>" +
	                   wActions +
	                   L"    <audio silent=\"true\"/>"
	                   L"</toast>";

	ABI::Windows::Data::Xml::Dom::IXmlDocument *doc = nullptr;
	hr = DesktopNotificationManagerCompat::CreateXmlDocumentFromString(xml.c_str(), &doc);
	if (FAILED(hr) || !doc) {
		lWarning() << "CreateXmlDocumentFromString failed:" << Qt::hex << hr;
		notifier->Release();
		return;
	}

	IToastNotification *toast = nullptr;
	hr = DesktopNotificationManagerCompat::CreateToastNotification(doc, &toast);
	if (FAILED(hr) || !toast) {
		lWarning() << "CreateToastNotification failed:" << Qt::hex << hr;
		doc->Release();
		notifier->Release();
		Utils::showInformationPopup(tr("info_popup_error_title"), tr("info_popup_error_creating_notification"), false);
		return;
	}

	ComPtr<IToastNotification2> toast2;
	hr = toast->QueryInterface(IID_PPV_ARGS(&toast2));
	if (FAILED(hr)) lWarning() << "QueryInterface failed";
	auto callId = generateRandomHexString(64);
	qDebug() << "put tag to toast" << callId;
	hr = toast2->put_Tag(HStringReference(std::wstring(callId.begin(), callId.end()).c_str()).Get());
	toast2->put_Group(HStringReference(L"linphone").Get());
	if (FAILED(hr)) lWarning() << "puting tag on toast failed";

	connect(call->mCore.get(), &CallCore::stateChanged, this,
	        [this, wcall = QWeakPointer(call->mCore), callId, notifier, toast] {
		        auto call = wcall.lock();
		        if (!call || !call ||
		            (call->getState() == LinphoneEnums::CallState::End ||
		             call->getState() == LinphoneEnums::CallState::Error ||
		             call->getState() == LinphoneEnums::CallState::StreamsRunning)) {
			        qDebug() << "Call ended, answered or error, remove toast";
			        // auto callId = call->mCore->getCallId();

			        std::unique_ptr<DesktopNotificationHistoryCompat> history;
			        DesktopNotificationManagerCompat::get_History(&history);

			        auto hr =
			            history->RemoveGroupedTag(std::wstring(callId.begin(), callId.end()).c_str(), L"linphone");
			        if (FAILED(hr)) {
				        lWarning() << "removing toast failed";
			        }
		        }
	        });

	EventRegistrationToken token;
	toast->add_Activated(Microsoft::WRL::Callback<ITypedEventHandler<ToastNotification *, IInspectable *>>(
	                         [this, call](IToastNotification *sender, IInspectable *args) -> HRESULT {
		                         qInfo() << "Toast clicked!";
		                         // Cast args en IToastActivatedEventArgs
		                         Microsoft::WRL::ComPtr<IToastActivatedEventArgs> activatedArgs;
		                         HRESULT hr = args->QueryInterface(IID_PPV_ARGS(&activatedArgs));
		                         if (SUCCEEDED(hr)) {
			                         HSTRING argumentsHString;
			                         activatedArgs->get_Arguments(&argumentsHString);

			                         // Convertir HSTRING en wstring
			                         UINT32 length;
			                         const wchar_t *rawStr = WindowsGetStringRawBuffer(argumentsHString, &length);
			                         std::wstring arguments(rawStr, length);
			                         QString arg = QString::fromStdWString(arguments);
			                         qInfo() << "Toast activated with args:" << arg;

			                         if (arg.compare("accept") == 0) {
				                         if (call) {
					                         qDebug() << "Accept call";
					                         Utils::openCallsWindow(call);
					                         call->mCore->lAccept(false);
				                         }
			                         } else if (arg.compare("decline") == 0) {
				                         if (call) {
					                         qDebug() << "Decline call";
					                         call->mCore->lDecline();
				                         }
			                         } else if (arg.isEmpty()) {
				                         if (call) Utils::openCallsWindow(call);
			                         }

			                         WindowsDeleteString(argumentsHString);
		                         }
		                         return S_OK;
	                         })
	                         .Get(),
	                     &token);

	hr = notifier->Show(toast);
	if (FAILED(hr)) {
		lWarning() << "Toast Show failed:" << Qt::hex << hr;
	}

	toast->Release();
	doc->Release();
	notifier->Release();
}

void NotificationBackend::sendNotification(NotificationType type, QVariantMap data) {
	if (App::getInstance()->getSessionLocked()) {
		mPendingNotifications.append({type, data});
		return;
	}
	switch (type) {
		case NotificationType::ReceivedCall:
			sendCallNotification(data);
			break;
		case NotificationType::ReceivedMessage:
			sendMessageNotification(data);
			break;
	}
}
