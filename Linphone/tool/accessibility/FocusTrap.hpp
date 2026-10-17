#pragma once

#include <QEvent>
#include <QObject>
#include <QPointer>
#include <QQuickItem>

class FocusTrapAttached : public QObject {
	Q_OBJECT
	Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)

public:
	explicit FocusTrapAttached(QObject *parent = nullptr);

	bool isEnabled() const;
	void setEnabled(bool enabled);

signals:
	void enabledChanged();

protected:
	bool eventFilter(QObject *watched, QEvent *event) override;

private:
	QQuickItem *nextInside(QQuickItem *from, bool forward) const;

	QPointer<QQuickItem> mItem;
	bool mEnabled = false;
};

class FocusTrap : public QObject {
	Q_OBJECT

public:
	using QObject::QObject;

	static FocusTrapAttached *qmlAttachedProperties(QObject *object);
};

QML_DECLARE_TYPEINFO(FocusTrap, QML_HAS_ATTACHED_PROPERTIES)
