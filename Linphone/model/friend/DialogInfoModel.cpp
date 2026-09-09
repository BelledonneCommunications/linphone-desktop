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

#include "DialogInfoModel.hpp"

#include <QXmlStreamReader>

DialogInfoModel::State DialogInfoModel::parse(const QString &xmlBody) {
	QXmlStreamReader reader(xmlBody);

	// A hint can aggregate several devices; report the busiest state found.
	State worst = State::Unknown;

	auto upgrade = [&worst](State candidate) {
		// Priority: InCall > Ringing > Idle > Unknown
		static auto rank = [](State s) {
			switch (s) {
				case State::InCall:
					return 3;
				case State::Ringing:
					return 2;
				case State::Idle:
					return 1;
				default:
					return 0;
			}
		};
		if (rank(candidate) > rank(worst)) worst = candidate;
	};

	bool sawDialogElement = false;

	while (!reader.atEnd() && !reader.hasError()) {
		auto token = reader.readNext();
		if (token != QXmlStreamReader::StartElement) continue;

		if (reader.name() == QLatin1String("dialog")) {
			sawDialogElement = true;
		} else if (reader.name() == QLatin1String("state") && sawDialogElement) {
			auto stateText = reader.readElementText().trimmed();
			if (stateText == QLatin1String("confirmed")) upgrade(State::InCall);
			else if (stateText == QLatin1String("early")) upgrade(State::Ringing);
			else if (stateText == QLatin1String("terminated")) upgrade(State::Idle);
		}
	}

	if (reader.hasError()) return State::Unknown;

	// No <dialog> element at all => extension has no active call => idle.
	if (!sawDialogElement) return State::Idle;

	return worst == State::Unknown ? State::Idle : worst;
}
