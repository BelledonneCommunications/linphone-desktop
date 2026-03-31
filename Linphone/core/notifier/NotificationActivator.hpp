#ifndef NOTIFICATIONACTIVATOR_HPP
#define NOTIFICATIONACTIVATOR_HPP

#pragma once
#include <NotificationActivationCallback.h>
#include <QApplication>
#include <QDebug>
#include <QTimer>
#include <windows.h>
#include <wrl/implements.h>
#include <wrl/module.h>
// #include <wil/com.h>
#include <windows.data.xml.dom.h>
#include <windows.ui.notifications.h>
// #include <winrt/base.h>

// using namespace winrt;
// using namespace Windows::UI::Notifications;
// using namespace Windows::Data::Xml::Dom;
using namespace ABI::Windows::Data::Xml::Dom;
using namespace Microsoft::WRL;

using Microsoft::WRL::ClassicCom;
using Microsoft::WRL::RuntimeClass;
using Microsoft::WRL::RuntimeClassFlags;

class DECLSPEC_UUID("FC946101-E4AB-4EA4-BC2E-C7F4D72B89AC") NotificationActivator
    : public Microsoft::WRL::RuntimeClass<Microsoft::WRL::RuntimeClassFlags<Microsoft::WRL::ClassicCom>,
                                          INotificationActivationCallback> {

public:
	NotificationActivator();
	~NotificationActivator();

	static void onActivated(LPCWSTR invokedArgs); // appelé depuis le .cpp
	HRESULT STDMETHODCALLTYPE Activate(LPCWSTR appUserModelId,
	                                   LPCWSTR invokedArgs,
	                                   const NOTIFICATION_USER_INPUT_DATA *data,
	                                   ULONG dataCount) override;
};

#endif // NOTIFICATIONACTIVATOR_HPP
