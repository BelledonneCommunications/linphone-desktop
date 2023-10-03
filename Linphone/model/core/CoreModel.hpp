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

#ifndef CORE_MODEL_H_
#define CORE_MODEL_H_

#include <QObject>
#include <QSharedPointer>
#include <QString>
#include <QThread>
#include <linphone++/linphone.hh>

// =============================================================================

class CoreModel : public QThread {
	Q_OBJECT
public:
	CoreModel(const QString &configPath, QObject *parent);
	~CoreModel();

	std::shared_ptr<linphone::Core> getCore();

	virtual void run();

	static CoreModel *getInstance();

	bool mEnd = false;
	QString mConfigPath;

	std::shared_ptr<linphone::Core> mCore;
};

#endif
