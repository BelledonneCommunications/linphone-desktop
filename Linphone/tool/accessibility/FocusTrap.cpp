#include "FocusTrap.hpp"

#include <QGuiApplication>
#include <QKeyEvent>
#include <QQuickWindow>

FocusTrapAttached::FocusTrapAttached(QObject *parent) : QObject(parent), mItem(qobject_cast<QQuickItem *>(parent)) {
}

bool FocusTrapAttached::isEnabled() const {
	return mEnabled;
}

void FocusTrapAttached::setEnabled(bool enabled) {
	if (mEnabled == enabled) return;
	mEnabled = enabled;
	if (mEnabled) qApp->installEventFilter(this);
	else qApp->removeEventFilter(this);
	emit enabledChanged();
}

bool FocusTrapAttached::eventFilter(QObject *watched, QEvent *event) {
	if (event->type() != QEvent::KeyPress || !mItem || !mItem->isVisible()) return false;
	auto window = mItem->window();
	if (!window || watched != window) return false;
	auto keyEvent = static_cast<QKeyEvent *>(event);
	if (keyEvent->modifiers() & (Qt::ControlModifier | Qt::AltModifier | Qt::MetaModifier)) return false;
	bool forward;
	if (keyEvent->key() == Qt::Key_Backtab) forward = false;
	else if (keyEvent->key() == Qt::Key_Tab) forward = !(keyEvent->modifiers() & Qt::ShiftModifier);
	else return false;
	auto focus = window->activeFocusItem();
	if (!focus || !mItem->isAncestorOf(focus)) return false;
	auto next = nextInside(focus, forward);
	if (next) next->forceActiveFocus(forward ? Qt::TabFocusReason : Qt::BacktabFocusReason);
	return true;
}

QQuickItem *FocusTrapAttached::nextInside(QQuickItem *from, bool forward) const {
	QQuickItem *candidate = from;
	for (int i = 0; i < 1000; ++i) {
		candidate = candidate->nextItemInFocusChain(forward);
		if (!candidate || candidate == from) return nullptr;
		if (candidate->isVisible() && candidate->isEnabled() && mItem->isAncestorOf(candidate)) return candidate;
	}
	return nullptr;
}

FocusTrapAttached *FocusTrap::qmlAttachedProperties(QObject *object) {
	return new FocusTrapAttached(object);
}
