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

#include "model/logger/LoggerModel.hpp"

// =============================================================================

class CoreModel : public QObject {
	Q_OBJECT
public:
	CoreModel(const QString &configPath, QObject *parent);
	~CoreModel();

	std::shared_ptr<linphone::Core> getCore();

	void start();

	static CoreModel *getInstance();
	
	void setConfigPath(QString path);
	

	bool mEnd = false;

	std::shared_ptr<linphone::Core> mCore;
	std::shared_ptr<LoggerModel> mLogger;

signals:
	void loggerInitialized();
private:
	QString mConfigPath;
	
	void setPathBeforeCreation();
	void setPathsAfterCreation();
	void setPathAfterStart();
	
};

#endif
