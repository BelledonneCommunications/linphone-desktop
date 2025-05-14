/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
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
// =============================================================================
// Library to deal with IRI and URI.
// See:
//	IRI : https://tools.ietf.org/html/rfc3987
// NOTE : Unicodes after \uFFFF are not supported by the QML RegExp (or the right syntax has not been found) : "Invalid
// regular expression" (even with surrogate pairs). Parts have been commented out for latter use.
//  URI : https://tools.ietf.org/html/rfc3986
// =============================================================================

#ifndef URI_TOOLS_H
#define URI_TOOLS_H

#include <QPair>
#include <QRegularExpression>
#include <QString>
#include <QVector>

class UriTools {
public:
	UriTools();
	bool mSupportUrl = true;

	static QVector<QPair<bool, QString>> parseIri(const QString &text);
	static QVector<QPair<bool, QString>> parseUri(const QString &text);
	static QRegularExpression getRegularExpression();

private:
	void initRegularExpressions();
	static QVector<QPair<bool, QString>> parse(const QString &text, const QRegularExpression regex);

	QRegularExpression mIriRegularExpression; // https://tools.ietf.org/html/rfc3987
	QRegularExpression mUriRegularExpression; // https://tools.ietf.org/html/rfc3986
};

#endif