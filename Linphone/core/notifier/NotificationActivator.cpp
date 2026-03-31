#include "NotificationActivator.hpp"

NotificationActivator::NotificationActivator() {
}

NotificationActivator::~NotificationActivator() {
}

HRESULT STDMETHODCALLTYPE NotificationActivator::Activate(LPCWSTR appUserModelId,
                                                          LPCWSTR invokedArgs,
                                                          const NOTIFICATION_USER_INPUT_DATA *data,
                                                          ULONG dataCount) {
	Q_UNUSED(appUserModelId);
	Q_UNUSED(invokedArgs);
	Q_UNUSED(data);
	Q_UNUSED(dataCount);
	return S_OK;
}

CoCreatableClass(NotificationActivator);
