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
//	URI : https://tools.ietf.org/html/rfc3986
// =============================================================================

#include "UriTools.hpp"

static UriTools gUriTools;

UriTools::UriTools(){
	initRegularExpressions();
}

QVector<QPair<bool, QString> > UriTools::parseIri(const QString& text){
	return parse(text, gUriTools.mIriRegularExpression);
}

QVector<QPair<bool, QString> > UriTools::parseUri(const QString& text){
	return parse(text, gUriTools.mUriRegularExpression);
}

// Parse a text and return all lines where regex is matched or not
QVector<QPair<bool, QString> > UriTools::parse(const QString& text, const QRegularExpression regex){
	QVector<QPair<bool, QString> > results;
	int currentIndex = 0;
	auto match = regex.match(text);
	
	for (int i = 0; i <= match.lastCapturedIndex(); ++i) {
		int startIndex = match.capturedStart(i);
		if(currentIndex != startIndex){
			results.push_back({false, text.mid(currentIndex, startIndex - currentIndex)});
		}
		results.push_back({true, match.captured(i)});
		currentIndex = startIndex;
	}
	
	if(results.size() == 0)
		results.push_back({false, text});
	else{
		currentIndex += results.back().second.length();
		if( currentIndex < text.size())
			results.push_back({false, text.mid(currentIndex)});
	}
	return results;
}

void UriTools::initRegularExpressions() {
	// Level 0. --------------------------------------------------------------------
	QString URI_DEC_OCTET = QString("(?:") +
			"25[0-5]" +
			"|" + "2[0-4]\\d" +
			"|" + "1\\d{2}" +
			"|" + "[1-9]\\d" +
			"|" + "\\d" +
			")";
	
	QString URI_H16 = "[0-9A-Fa-f]{1,4}";
	QString URI_PCT_ENCODED = "%[A-Fa-f\\d]{2}";
	QString URI_PORT =  "\\d*";
	QString URI_SCHEME = "[a-zA-Z][\\w+\\.\\-]*";
	QString URI_SUB_DELIMS = "[!$&\"()*+,;=]";
	QString URI_UNRESERVED = "[\\w\\._~\\-]";
	QString IRI_UCS_CHAR = QString("(?:") +
			"[\\x{00A0}-\\x{D7FF}]" + "|" + "[\\x{F900}-\\x{FDCF}]" + "|" + "[\\x{FDF0}-\\x{FFEF}]" +
			"|" + "[\\x{10000}-\\x{1FFFD}]"             + "|" + "[\\x{20000}-\\x{2FFFD}]"             + "|" + "[\\x{30000}-\\x{3FFFD}]" +
			//"|" + "[\\x{D800\\x{DC00}-\\x{D83F\\x{DFFD}]" + "|" + "[\\x{D840\\x{DC00}-\\x{D87F\\x{DFFD}]" + "|" + "[\\x{D880\\x{DC00}-\\x{D8BF\\x{DFFD}]" +
			
			"|" + "[\\x{40000}-\\x{4FFFD}]"             + "|" + "[\\x{50000}-\\x{5FFFD}]"             + "|" + "[\\x{60000}-\\x{6FFFD}]" +
			//"|" + "[\\x{D8C0\\x{DC00}-\\x{D8FF\\x{DFFD}]" + "|" + "[\\x{D900\\x{DC00}-\\x{D93F\\x{DFFD}]" + "|" + "[\\x{D940\\x{DC00}-\\x{D97F\\x{DFFD}]" +
			
			"|" + "[\\x{70000}-\\x{7FFFD}]"             + "|" + "[\\x{80000}-\\x{8FFFD}]"             + "|" + "[\\x{90000}-\\x{9FFFD}]" +
			//"|" + "[\\x{D980\\x{DC00}-\\x{D9BF\\x{DFFD}]" + "|" + "[\\x{D9C0\\x{DC00}-\\x{D9FF\\x{DFFD}]" + "|" + "[\\x{DA00\\x{DC00}-\\x{DA3F\\x{DFFD}]" +
			
			"|" + "[\\x{A0000}-\\x{AFFFD}]"             + "|" + "[\\x{B0000}-\\x{BFFFD}]"             + "|" + "[\\x{C0000}-\\x{CFFFD}]" +
			//"|" + "[\\x{DA40\\x{DC00}-\\x{DA7F\\x{DFFD}]" + "|" + "[\\x{DA80\\x{DC00}-\\x{DABF\\x{DFFD}]" + "|" + "[\\x{DAC0\\x{DC00}-\\x{DAFF\\x{DFFD}]" +
			
			"|" + "[\\x{D0000}-\\x{DFFFD}]"             + "|" + "[\\x{E1000}-\\x{EFFFD}]" +
			//"|" + "[\\x{DB00\\x{DC00}-\\x{DB3F\\x{DFFD}]" + "|" + "[\\x{DB44\\x{DC00}-\\x{DB7F\\x{DFFD}]" +
			")";
	
	QString IRI_PRIVATE = QString("(?:") +
			"[\\x{E000}-\\x{F8FF}]" +
			"|" + "[\\x{F0000}-\\x{FFFFD}]"             + "|" + "[\\x{100000}-\\x{10FFFD}]" +
			//"|" + "[\\x{DBC0\\x{DC00}-\\x{DBFF\\x{DFFD}]" + "|" + "[\\x{DBC0\\x{DC00}-\\x{DBFF\\x{DFFD}]" +
			")";
	
	
	// Level 1. --------------------------------------------------------------------
	QString URI_IPV_FUTURE = QString("v[0-9A-Fa-f]+\\.") + "(?:" +
			URI_UNRESERVED +
			URI_SUB_DELIMS +
			":" +
			")";
	
	QString IRI_UNRESERVED = QString("(?:") +
			"[\\w\\._~\\-]" +
			"|" + IRI_UCS_CHAR +
			")";
	
	QString URI_IPV4_ADDRESS = URI_DEC_OCTET + "\\." + URI_DEC_OCTET + "\\." +
			URI_DEC_OCTET + "\\." + URI_DEC_OCTET;
	
	QString URI_PCHAR = "(?:" +
			URI_UNRESERVED +
			"|" + URI_PCT_ENCODED +
			"|" + URI_SUB_DELIMS +
			"|" + "[:@]" +
			")";
	
	QString URI_REG_NAME = "(?:" +
			URI_UNRESERVED +
			"|" + URI_PCT_ENCODED +
			"|" + URI_SUB_DELIMS +
			")*";
	
	QString URI_USERINFO = "(?:" +
			URI_UNRESERVED +
			"|" + URI_PCT_ENCODED +
			"|" + URI_SUB_DELIMS +
			"|" + ":" +
			")*";
	
	// Level 2. --------------------------------------------------------------------
	
	QString URI_FRAGMENT = "(?:" +
			URI_PCHAR +
			"|" + "[/?]" +
			")*";
	
	QString URI_LS32 = "(?:" +
			URI_H16 + ":" + URI_H16 +
			"|" + URI_IPV4_ADDRESS +
			")";
	
	QString URI_QUERY = "(?:" +
			URI_PCHAR +
			"|" + "[/?]" +
			")*";
	
	QString URI_SEGMENT = URI_PCHAR + "*";
	
	QString URI_SEGMENT_NZ = URI_PCHAR + "+";
	
	QString IRI_PCHAR = "(?:" +
			IRI_UNRESERVED +
			"|" + URI_PCT_ENCODED +
			"|" + URI_SUB_DELIMS +
			"|" + "[:@]" +
			")";
	
	QString IRI_REG_NAME = "(?:" +
			IRI_UNRESERVED +
			"|" + URI_PCT_ENCODED +
			"|" + URI_SUB_DELIMS +
			")*";
	
	QString IRI_USERINFO = "(?:" +
			IRI_UNRESERVED +
			"|" + URI_PCT_ENCODED +
			"|" + URI_SUB_DELIMS +
			"|" + ":" +
			")*";
	
	// Level 3. --------------------------------------------------------------------
	
	QString URI_IPV6_ADDRESS = QString("(?:") +
			"(?:" + URI_H16 + ":){6}" + URI_LS32 +
			"|" +  "::(?:" + URI_H16 + ":){5}" + URI_LS32 +
			"|" +  "\\[" + URI_H16 + "\\]::(?:" + URI_H16 + ":){4}" + URI_LS32 +
			"|" +  "\\[" + "(?:" + URI_H16 + ":)?" + URI_H16 + "\\]::(?:" + URI_H16 + ":){3}" + URI_LS32 +
			"|" +  "\\[" + "(?:" + URI_H16 + ":){0,2}" + URI_H16 + "\\]::(?:" + URI_H16 + ":){2}" + URI_LS32 +
			"|" +  "\\[" + "(?:" + URI_H16 + ":){0,3}" + URI_H16 + "\\]::" + URI_H16 + ":" + URI_LS32 +
			"|" +  "\\[" + "(?:" + URI_H16 + ":){0,4}" + URI_H16 + "\\]::" + URI_LS32 +
			"|" +  "\\[" + "(?:" + URI_H16 + ":){0,5}" + URI_H16 + "\\]::" + URI_H16 +
			"|" +  "\\[" + "(?:" + URI_H16 + ":){0,6}" + URI_H16 + "\\]::" +
			")";
	
	QString URI_PATH_ABEMPTY = QString("(?:") + "/" + URI_SEGMENT + ")*";
	
	QString URI_PATH_ABSOLUTE = QString("/") +
			"(?:" + URI_SEGMENT_NZ + "(?:" + "/" + URI_SEGMENT + ")*" + ")?";
	
	QString URI_PATH_ROOTLESS =
			URI_SEGMENT_NZ + "(?:" + "/" + URI_SEGMENT + ")*";
	
	QString IRI_FRAGMENT = "(?:" +
			IRI_PCHAR +
			"|" + "[/?]" +
			")*";
	
	QString IRI_QUERY = "(?:" +
			IRI_PCHAR +
			"|" + IRI_PRIVATE +
			"|" + "[/?]" +
			")*";
	
	QString IRI_SEGMENT = IRI_PCHAR + "*";
	QString IRI_SEGMENT_NZ = IRI_PCHAR + "+";
	
	
	// Level 4. --------------------------------------------------------------------
	
	QString URI_IP_LITERAL = QString("\\[" )+
			"(?:" +
			URI_IPV6_ADDRESS +
			"|" + URI_IPV_FUTURE +
			")" +
			"\\]";
	
	QString IRI_PATH_ABEMPTY = QString("(?:") + "/" + IRI_SEGMENT + ")*";
	
	QString IRI_PATH_ABSOLUTE = QString("/") +
			"(?:" + IRI_SEGMENT_NZ + "(?:" + "/" + IRI_SEGMENT + ")*" + ")?";
	
	QString IRI_PATH_ROOTLESS =
			IRI_SEGMENT_NZ + "(?:" + "/" + IRI_SEGMENT + ")*";
	
	
	// Level 5. --------------------------------------------------------------------
	
	QString URI_HOST = "(?:" +
			URI_REG_NAME +
			"|" + URI_IPV4_ADDRESS +
			"|" + URI_IP_LITERAL +
			")";
	
	QString IRI_HOST = "(?:" +
			IRI_REG_NAME +
			"|" + URI_IPV4_ADDRESS +
			"|" + URI_IP_LITERAL +
			")";
	
	// Level 6. --------------------------------------------------------------------
	
	QString URI_AUTHORITY = "(?:" + URI_USERINFO + "@" + ")?" +
			URI_HOST +
			"(?:" + ":" + URI_PORT + ")?";
	
	QString IRI_AUTHORITY = "(?:" + IRI_USERINFO + "@" + ")?" +
			IRI_HOST +
			"(?:" + ":" + URI_PORT + ")?";
	
	// Level 7. --------------------------------------------------------------------
	
	// `path-empty` not used.
	QString URI_HIER_PART = QString("(?:") +
			"//" + URI_AUTHORITY + URI_PATH_ABEMPTY +
			"|" + URI_PATH_ABSOLUTE +
			"|" + URI_PATH_ROOTLESS +
			")";
	QString IRI_HIER_PART = QString("(?:") +
			"//" + IRI_AUTHORITY + IRI_PATH_ABEMPTY +
			"|" + IRI_PATH_ABSOLUTE +
			"|" + IRI_PATH_ROOTLESS +
			")";
	
	// Level 8. --------------------------------------------------------------------
	
	// Regex to match URI. It respects the RFC 3986.
	QString URI = "(?:"
			+ URI_SCHEME + ":" + "|" + "www\\." + ")"
			+ URI_HIER_PART + "(?:" + "\\?" + URI_QUERY + ")?" +
			"(?:" + "#" + URI_FRAGMENT + ")?";
	
	// Regex to match URI. It respects the RFC 3987.
	QString IRI = "(?:" + URI_SCHEME + ":" + "|" + "www\\." + ")"
			+ IRI_HIER_PART + "(?:" + "\\?" + IRI_QUERY + ")?" +
			"(?:" + "#" + IRI_FRAGMENT + ")?";
	
	mIriRegularExpression = QRegularExpression(IRI,QRegularExpression::CaseInsensitiveOption | QRegularExpression::UseUnicodePropertiesOption);
	mUriRegularExpression = QRegularExpression(URI,QRegularExpression::CaseInsensitiveOption | QRegularExpression::UseUnicodePropertiesOption);
}
