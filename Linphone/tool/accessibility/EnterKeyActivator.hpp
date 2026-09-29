#pragma once

#include <QEvent>
#include <QObject>
#include <QPointer>
#include <QQuickItem>

class EnterKeyActivator : public QObject {
	Q_OBJECT

public:
	explicit EnterKeyActivator(QObject *parent = nullptr);

protected:
	bool eventFilter(QObject *watched, QEvent *event) override;

private:
	const QEvent *mDispatchedEvent = nullptr;
};
