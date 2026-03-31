#include "AbstractNotificationBackend.hpp"

DEFINE_ABSTRACT_OBJECT(AbstractNotificationBackend)

const QHash<int, AbstractNotificationBackend::Notification> AbstractNotificationBackend::Notifications = {
    {AbstractNotificationBackend::ReceivedMessage, Notification(AbstractNotificationBackend::ReceivedMessage, 10)},
    {AbstractNotificationBackend::ReceivedCall, Notification(AbstractNotificationBackend::ReceivedCall, 30)}};

AbstractNotificationBackend::AbstractNotificationBackend(QObject *parent) : QObject(parent) {
}
