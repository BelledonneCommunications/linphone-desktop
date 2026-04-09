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
	int timeout = 2;
	// AbstractNotificationBackend::Notifications[(int)NotificationType::ReceivedCall].getTimeout();

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
	auto callId = call->mCore->getCallId();
	qDebug() << "put tag to toast" << callId;
	hr = toast2->put_Tag(HStringReference(reinterpret_cast<const wchar_t *>(callId.utf16())).Get());
	toast2->put_Group(HStringReference(L"linphone").Get());
	if (FAILED(hr)) lWarning() << "puting tag on toast failed";

	connect(call->mCore.get(), &CallCore::stateChanged, this, [this, call, notifier, toast] {
		if (call->mCore->getState() == LinphoneEnums::CallState::End ||
		    call->mCore->getState() == LinphoneEnums::CallState::Error) {
			qDebug() << "Call ended or error, remove toast";
			auto callId = call->mCore->getCallId();
			call->deleteLater();

			std::unique_ptr<DesktopNotificationHistoryCompat> history;
			DesktopNotificationManagerCompat::get_History(&history);

			auto hr = history->RemoveGroupedTag(reinterpret_cast<const wchar_t *>(callId.utf16()), L"linphone");
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
