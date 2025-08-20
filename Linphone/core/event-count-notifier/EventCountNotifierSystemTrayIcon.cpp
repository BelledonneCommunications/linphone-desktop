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

#include <QIcon>
#include <QPainter>
#include <QSvgRenderer>
#include <QSystemTrayIcon>
#include <QTimer>
#include <QWindow>

#include "core/App.hpp"
#include "model/core/CoreModel.hpp"
#include "model/setting/SettingsModel.hpp"
#include "tool/Constants.hpp"
#include "tool/Utils.hpp"

#include "EventCountNotifierSystemTrayIcon.hpp"

// =============================================================================

namespace {
constexpr int IconWidth = 256;
constexpr int IconHeight = 256;

constexpr int IconCounterBackgroundRadius = 100;
constexpr int IconCounterBlinkInterval = 1000;
constexpr int IconCounterTextPixelSize = 144;
} // namespace

DEFINE_ABSTRACT_OBJECT(EventCountNotifier)

QSharedPointer<EventCountNotifier> EventCountNotifier::create(QObject *parent) {
	auto sharedPointer = QSharedPointer<EventCountNotifier>(new EventCountNotifier(parent), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

EventCountNotifier::EventCountNotifier(QObject *parent) : AbstractEventCountNotifier(parent) {
	QSvgRenderer renderer((QString(Constants::WindowIconPath)));
	if (!renderer.isValid()) qFatal("Invalid SVG Image.");

	QPixmap buf(IconWidth, IconHeight);
	buf.fill(QColor(Qt::transparent));

	QPainter painter(&buf);
	renderer.render(&painter);

	mBuf = new QPixmap(buf);
	mBufWithCounter = new QPixmap();

	mBlinkTimer = new QTimer(this);
	mBlinkTimer->setInterval(IconCounterBlinkInterval);
	connect(mBlinkTimer, &QTimer::timeout, this, &EventCountNotifier::update);
}

void EventCountNotifier::setSelf(QSharedPointer<EventCountNotifier> me) {
}

EventCountNotifier::~EventCountNotifier() {
	delete mBuf;
	delete mBufWithCounter;
}

// -----------------------------------------------------------------------------

void EventCountNotifier::notifyEventCount(int n) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	n = n > 99 ? 99 : n;
	QSystemTrayIcon *sysTrayIcon = App::getInstance()->getSystemTrayIcon();
	if (!sysTrayIcon) return;

	if (!n) {
		mBlinkTimer->stop();
		sysTrayIcon->setIcon(QIcon(*mBuf));
		return;
	}

	*mBufWithCounter = *mBuf;
	QPainter p(mBufWithCounter);

	const int width = mBufWithCounter->width();
	const int height = mBufWithCounter->height();

	// Draw background.
	{
		p.setBrush(QColor(Utils::getDefaultStyleColor("main1_100")));
		p.drawEllipse(QPointF(width / 2, height / 2), IconCounterBackgroundRadius, IconCounterBackgroundRadius);
	}

	// Draw text.
	{
		QFont font = p.font();
		font.setPixelSize(IconCounterTextPixelSize);

		p.setFont(font);
		p.setPen(QPen(QColor(Utils::getDefaultStyleColor("main1_500_main"))));
		p.drawText(QRect(0, 0, width, height), Qt::AlignCenter, QString::number(n));
	}

	// Change counter.
	mBlinkTimer->stop();
	auto coreModel = CoreModel::getInstance();
	if (!coreModel->isInitialized() || SettingsModel::getInstance()->isSystrayNotificationBlinkEnabled())
		mBlinkTimer->start();
	mDisplayCounter = true;
	update();
}

void EventCountNotifier::update() {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	QSystemTrayIcon *sysTrayIcon = App::getInstance()->getSystemTrayIcon();
	if (sysTrayIcon) {
		sysTrayIcon->setIcon(QIcon(mDisplayCounter ? *mBufWithCounter : *mBuf));
	}
	mDisplayCounter = !mDisplayCounter;
}
