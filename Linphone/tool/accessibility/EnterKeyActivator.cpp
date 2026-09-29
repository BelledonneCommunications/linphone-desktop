#include "EnterKeyActivator.hpp"

#include <QGuiApplication>
#include <QKeyEvent>
#include <QQuickWindow>

EnterKeyActivator::EnterKeyActivator(QObject *parent) : QObject(parent) {
	qApp->installEventFilter(this);
}

bool EnterKeyActivator::eventFilter(QObject *watched, QEvent *event) {
	if (event->type() != QEvent::KeyPress || event == mDispatchedEvent) return false;
	auto keyEvent = static_cast<QKeyEvent *>(event);
	if (keyEvent->key() != Qt::Key_Return && keyEvent->key() != Qt::Key_Enter) return false;
	if ((keyEvent->modifiers() & ~Qt::KeypadModifier) != Qt::NoModifier) return false;
	auto item = qobject_cast<QQuickItem *>(watched);
	if (!item || !item->window() || item->window()->activeFocusItem() != item) return false;
	if (!item->inherits("QQuickAbstractButton")) return false;

	QPointer<QQuickItem> button = item;
	const QEvent *previousDispatchedEvent = mDispatchedEvent;
	mDispatchedEvent = event;
	QCoreApplication::sendEvent(item, event);
	mDispatchedEvent = previousDispatchedEvent;
	if (event->isAccepted()) return true;

	event->accept();
	if (button && !keyEvent->isAutoRepeat() && button->isEnabled() && button->isVisible())
		QMetaObject::invokeMethod(button, "click");
	return true;
}
