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

#ifndef LOGGER_LISTENER_H_
#define LOGGER_LISTENER_H_

#include <QMutex>
#include <memory>

#include <linphone++/linphone.hh>

// =============================================================================
class LoggerListener : public linphone::LoggingServiceListener {
public:
	LoggerListener();

private:
	virtual void onLogMessageWritten(const std::shared_ptr<linphone::LoggingService> &logService,
	                                 const std::string &domain,
	                                 linphone::LogLevel level,
	                                 const std::string &message) override;

	bool mIsVerbose = true;
	bool mQtOnlyEnabled = false;
};

#endif
