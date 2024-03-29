/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#include <QAction>
#include <QBitmap>
#include <QFileInfo>
#include <QCryptographicHash>
#include <QCursor>
#include <QDir>
#include <QFile>
#include <QImageReader>
#include <QDebug>
#include <QMimeDatabase>
#include <QTimeZone>
#include <QUrl>

#include "config.h"

#ifdef PDF_ENABLED
#include <QtPdf/QPdfDocument>
#include <QtPdfWidgets/QPdfView>
#include "components/pdf/PdfWidget.hpp"
#endif


#include "Utils.hpp"
#include "UriTools.hpp"
#include "app/App.hpp"
#include "app/paths/Paths.hpp"
#include "app/providers/ImageProvider.hpp"
#include "components/core/CoreManager.hpp"
#include "components/other/colors/ColorListModel.hpp"
#include "components/other/colors/ColorModel.hpp"
#include "components/other/date/DateModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/contact/ContactModel.hpp"
#include "components/contact/VcardModel.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"


#ifdef _WIN32
#include <time.h>
#endif

// =============================================================================

namespace {
constexpr int SafeFilePathLimit = 100;

}

std::shared_ptr<linphone::Address> Utils::interpretUrl(const QString& address){
	bool usePrefix = CoreManager::getInstance()->getAccountSettingsModel()->getUseInternationalPrefixForCallsAndChats();
	auto interpretedAddress = CoreManager::getInstance()->getCore()->interpretUrl(Utils::appStringToCoreString(address), usePrefix);
	if(!interpretedAddress){// Try by removing scheme.
		QStringList splitted = address.split(":");
		if(splitted.size() > 0 && splitted[0] == "sip"){
			splitted.removeFirst();
			interpretedAddress = CoreManager::getInstance()->getCore()->interpretUrl(Utils::appStringToCoreString(splitted.join(":")), usePrefix);
		}
	}
	return interpretedAddress;
}
char *Utils::rstrstr (const char *a, const char *b) {
	size_t a_len = strlen(a);
	size_t b_len = strlen(b);
	
	if (b_len > a_len)
		return nullptr;
	
	for (const char *s = a + a_len - b_len; s >= a; --s) {
		if (!strncmp(s, b, b_len))
			return const_cast<char *>(s);
	}
	
	return nullptr;
}

// -----------------------------------------------------------------------------

bool Utils::hasCapability(const QString& address, const LinphoneEnums::FriendCapability& capability, bool defaultCapability){
	auto addressCleaned = cleanSipAddress(address);
	auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(addressCleaned);
	if(contact)
		return contact->hasCapability(capability);
	else
		return defaultCapability;
}

//--------------------------------------------------------------------------------------

QDateTime Utils::addMinutes(QDateTime date, const int& min){
	return date.addSecs(min*60);
}

QDateTime Utils::getOffsettedUTC(const QDateTime& date){
	QDateTime utc = date.toUTC();// Get a date free of any offsets.
	auto timezone = date.timeZone();
	utc = utc.addSecs(timezone.offsetFromUtc(date));// add offset from date timezone
	utc.setTimeSpec(Qt::OffsetFromUTC);// ensure to have an UTC date
	return utc;
}

QString Utils::toDateTimeString(QDateTime date, const QString& format){
	if(date.date() == QDate::currentDate())
		return toTimeString(date);
	else{
		return getOffsettedUTC(date).toString(format);
	}
}

QString Utils::toTimeString(QDateTime date, const QString& format){
// Issue : date.toString() will not print the good time in timezones. Get it from date and add ourself the offset.
	return getOffsettedUTC(date).toString(format);
}

QString Utils::toDateString(QDateTime date, const QString& format){
	return QLocale().toString(getOffsettedUTC(date), (!format.isEmpty() ? format : QLocale().dateFormat()) );
}

QString Utils::toDateString(QDate date, const QString& format){
	return QLocale().toString(date, (!format.isEmpty() ? format : QLocale().dateFormat()) );
}

// Return custom address to be displayed on UI.
// In order to return only the username and to remove all domains from the GUI, you may just change the default mode.
QString Utils::toDisplayString(const QString& str, SipDisplayMode displayMode){
	if(displayMode == SIP_DISPLAY_ALL) return str;
	std::shared_ptr<linphone::Address> addr = linphone::Factory::get()->createAddress(str.toStdString());
	QString displayString;
	if( addr && ( (displayMode & SIP_DISPLAY_USERNAME) == SIP_DISPLAY_USERNAME))
		displayString = Utils::coreStringToAppString(addr->getUsername());
	if(displayString.isEmpty())
		return str;
	else
		return displayString;
}

QDate Utils::getCurrentDate() {
	return QDate::currentDate();
}

DateModel* Utils::getCurrentDateModel() {
	return new DateModel(QDate::currentDate());
}

QDate Utils::getMinDate() {
	return QDate(1,1,1);
}
DateModel* Utils::getMinDateModel() {
	return new DateModel(QDate(1,1,1));
}
QDate Utils::toDate(const QString& str, const QString& format) {
	return QDate::fromString(str, format);
}
DateModel* Utils::toDateModel(const QString& str, const QString& format) {
	return new DateModel(toDate(str, format));
}
QDate Utils::getDate(int year, int month, int day) {
	auto d = QDate(year, month, day);
	if(!d.isValid() ){
		auto first = QDate(year, month, 1);
		if(first.isValid()) {
			d = first.addDays(day-1);
		}
	}
	return d;
}

DateModel* Utils::getDateModel(int year, int month, int day) {
	auto d = QDate(year, month, day);
	if(!d.isValid() ){
		auto first = QDate(year, month, 1);
		if(first.isValid()) {
			d = first.addDays(day-1);
		}
	}
	return new DateModel(d);
}

int Utils::getFullYear(const QDate& date) {
	return date.year();
}

int Utils::getMonth(const QDate& date) {
	return date.month();
}

int Utils::getDay(const QDate& date) {
	return date.day();
}

int Utils::getDayOfWeek(const QDate& date) {
	return date.dayOfWeek();
}

bool Utils::equals(const QDate& d1, const QDate& d2){
	return d1 == d2;
}

bool Utils::isGreatherThan(const QDate& d1, const QDate& d2) {
	return d1 >= d2;
}

//--------------------------------------------------------------------------------------

QString Utils::getDisplayName(const QString& address){
	QString displayName = getDisplayName(interpretUrl(address));
	return displayName.isEmpty() ? address : displayName;
}

QString Utils::getInitials(const QString& username){
	if(username.isEmpty()) return "";
	
	QRegularExpression regex("[\\s\\.]+");
	QStringList words = username.split(regex);// Qt 5.14: Qt::SkipEmptyParts
	QStringList initials;
	auto str32 = words[0].toStdU32String();
	std::u32string char32;
	char32 += str32[0];
	initials << QString::fromStdU32String(char32);
	for(int i = 1; i < words.size() && initials.size() <= 1 ; ++i) {
		if( words[i].size() > 0){
			str32 = words[i].toStdU32String();
			char32[0] = str32[0];
			initials << QString::fromStdU32String(char32);
		}
	}
	return  App::getInstance()->getLocale().toUpper(initials.join(""));
}

QString Utils::toString(const LinphoneEnums::TunnelMode& mode){
	switch(mode){
	case LinphoneEnums::TunnelMode::TunnelModeEnable :
		//: 'Enable' : One word for button action to enable tunnel mode.
		return QObject::tr("LinphoneEnums_TunnelModeEnable");
	case LinphoneEnums::TunnelMode::TunnelModeDisable :
		//: 'Disable' : One word for button action to disable tunnel mode.
		return QObject::tr("LinphoneEnums_TunnelModeDisable");
	case LinphoneEnums::TunnelMode::TunnelModeAuto :
		//: 'Auto' : One word for button action to set the auto tunnel mode.
		return QObject::tr("LinphoneEnums_TunnelModeAuto");
	default:
		return "";
	}
}

QImage Utils::getImage(const QString &pUri) {
	QImage image(pUri);
	QImageReader reader(pUri);
	reader.setAutoTransform(true);
	if(image.isNull()){// Try to determine format from headers instead of using suffix
		reader.setDecideFormatFromContent(true);
	}
	return reader.read();
}
QString Utils::getSafeFilePath (const QString &filePath, bool *soFarSoGood) {
	if (soFarSoGood)
		*soFarSoGood = true;
	
	QFileInfo info(filePath);
	if (!info.exists())
		return filePath;
	
	const QString prefix = QStringLiteral("%1/%2").arg(info.absolutePath()).arg(info.baseName());
	const QString ext = info.completeSuffix();
	
	for (int i = 1; i < SafeFilePathLimit; ++i) {
		QString safePath = QStringLiteral("%1 (%3).%4").arg(prefix).arg(i).arg(ext);
		if (!QFileInfo::exists(safePath))
			return safePath;
	}
	
	if (soFarSoGood)
		*soFarSoGood = false;
	
	return QString("");
}
std::shared_ptr<linphone::Address> Utils::getMatchingLocalAddress(std::shared_ptr<linphone::Address> p_localAddress){
	QVector<std::shared_ptr<linphone::Address> > addresses;
	// Get default account
	addresses.push_back(CoreManager::getInstance()->getCore()->createPrimaryContactParsed());
	auto accounts = CoreManager::getInstance()->getAccountList();
	foreach(auto account, accounts)
		addresses.push_back(account->getParams()->getIdentityAddress()->clone());
	foreach(auto address, addresses){
		if( address->getUsername() == p_localAddress->getUsername() && address->getDomain() == p_localAddress->getDomain())
			return address;
	}
	return p_localAddress;
}
// Return at most : sip:username@domain
QString Utils::cleanSipAddress (const QString &sipAddress) {
	std::shared_ptr<linphone::Address> addr = linphone::Factory::get()->createAddress(sipAddress.toStdString());
	if( addr) {
		addr->clean();
		QStringList fields = Utils::coreStringToAppString(addr->asStringUriOnly()).split('@');
		if(fields.size() > 0){// maybe useless but it's just to be sure to have a domain
			fields.removeLast();
			QString domain = Utils::coreStringToAppString(addr->getDomain());
			if( domain.count(':')>1)
				fields.append('['+domain+']');
			else
				fields.append(domain);
			return fields.join('@');
		}
	}
	return sipAddress;
}
// Data to retrieve WIN32 process
#ifdef _WIN32
#include <windows.h>
struct EnumData {
	DWORD dwProcessId;
	HWND hWnd;
};
// Application-defined callback for EnumWindows
BOOL CALLBACK EnumProc(HWND hWnd, LPARAM lParam) {
	// Retrieve storage location for communication data
	EnumData& ed = *(EnumData*)lParam;
	DWORD dwProcessId = 0x0;
	// Query process ID for hWnd
	GetWindowThreadProcessId(hWnd, &dwProcessId);
	// Apply filter - if you want to implement additional restrictions,
	// this is the place to do so.
	if (ed.dwProcessId == dwProcessId) {
		// Found a window matching the process ID
		ed.hWnd = hWnd;
		// Report success
		SetLastError(ERROR_SUCCESS);
		// Stop enumeration
		return FALSE;
	}
	// Continue enumeration
	return TRUE;
}
// Main entry
HWND FindWindowFromProcessId(DWORD dwProcessId) {
	EnumData ed = { dwProcessId };
	if (!EnumWindows(EnumProc, (LPARAM)&ed) &&
			(GetLastError() == ERROR_SUCCESS)) {
		return ed.hWnd;
	}
	return NULL;
}

// Helper method for convenience
HWND FindWindowFromProcess(HANDLE hProcess) {
	return FindWindowFromProcessId(GetProcessId(hProcess));
}
#endif

bool Utils::processExists(const quint64& p_processId)
{
#ifdef _WIN32
	return FindWindowFromProcessId(p_processId) != NULL;
#else
	return true;
#endif
}
QString Utils::getCountryName(const QLocale::Country& p_country)
{
	QString countryName;
	switch(p_country)
	{
		case QLocale::Afghanistan: if((countryName = QCoreApplication::translate("country", "Afghanistan"))== "Afghanistan") countryName = "";break;
		case QLocale::Albania: if((countryName = QCoreApplication::translate("country", "Albania"))== "Albania") countryName = "";break;
		case QLocale::Algeria: if((countryName = QCoreApplication::translate("country", "Algeria"))== "Algeria") countryName = "";break;
		case QLocale::AmericanSamoa: if((countryName = QCoreApplication::translate("country", "AmericanSamoa"))== "AmericanSamoa") countryName = "";break;
		case QLocale::Andorra: if((countryName = QCoreApplication::translate("country", "Andorra"))== "Andorra") countryName = "";break;
		case QLocale::Angola: if((countryName = QCoreApplication::translate("country", "Angola"))== "Angola") countryName = "";break;
		case QLocale::Anguilla: if((countryName = QCoreApplication::translate("country", "Anguilla"))== "Anguilla") countryName = "";break;
		case QLocale::AntiguaAndBarbuda: if((countryName = QCoreApplication::translate("country", "AntiguaAndBarbuda"))== "AntiguaAndBarbuda") countryName = "";break;
		case QLocale::Argentina: if((countryName = QCoreApplication::translate("country", "Argentina"))== "Argentina") countryName = "";break;
		case QLocale::Armenia: if((countryName = QCoreApplication::translate("country", "Armenia"))== "Armenia") countryName = "";break;
		case QLocale::Aruba: if((countryName = QCoreApplication::translate("country", "Aruba"))== "Aruba") countryName = "";break;
		case QLocale::Australia: if((countryName = QCoreApplication::translate("country", "Australia"))== "Australia") countryName = "";break;
		case QLocale::Austria: if((countryName = QCoreApplication::translate("country", "Austria"))== "Austria") countryName = "";break;
		case QLocale::Azerbaijan: if((countryName = QCoreApplication::translate("country", "Azerbaijan"))== "Azerbaijan") countryName = "";break;
		case QLocale::Bahamas: if((countryName = QCoreApplication::translate("country", "Bahamas"))== "Bahamas") countryName = "";break;
		case QLocale::Bahrain: if((countryName = QCoreApplication::translate("country", "Bahrain"))== "Bahrain") countryName = "";break;
		case QLocale::Bangladesh: if((countryName = QCoreApplication::translate("country", "Bangladesh"))== "Bangladesh") countryName = "";break;
		case QLocale::Barbados: if((countryName = QCoreApplication::translate("country", "Barbados"))== "Barbados") countryName = "";break;
		case QLocale::Belarus: if((countryName = QCoreApplication::translate("country", "Belarus"))== "Belarus") countryName = "";break;
		case QLocale::Belgium: if((countryName = QCoreApplication::translate("country", "Belgium"))== "Belgium") countryName = "";break;
		case QLocale::Belize: if((countryName = QCoreApplication::translate("country", "Belize"))== "Belize") countryName = "";break;
		case QLocale::Benin: if((countryName = QCoreApplication::translate("country", "Benin"))== "Benin") countryName = "";break;
		case QLocale::Bermuda: if((countryName = QCoreApplication::translate("country", "Bermuda"))== "Bermuda") countryName = "";break;
		case QLocale::Bhutan: if((countryName = QCoreApplication::translate("country", "Bhutan"))== "Bhutan") countryName = "";break;
		case QLocale::Bolivia: if((countryName = QCoreApplication::translate("country", "Bolivia"))== "Bolivia") countryName = "";break;
		case QLocale::BosniaAndHerzegowina: if((countryName = QCoreApplication::translate("country", "BosniaAndHerzegowina"))== "BosniaAndHerzegowina") countryName = "";break;
		case QLocale::Botswana: if((countryName = QCoreApplication::translate("country", "Botswana"))== "Botswana") countryName = "";break;
		case QLocale::Brazil: if((countryName = QCoreApplication::translate("country", "Brazil"))== "Brazil") countryName = "";break;
		case QLocale::Brunei: if((countryName = QCoreApplication::translate("country", "Brunei"))== "Brunei") countryName = "";break;
		case QLocale::Bulgaria: if((countryName = QCoreApplication::translate("country", "Bulgaria"))== "Bulgaria") countryName = "";break;
		case QLocale::BurkinaFaso: if((countryName = QCoreApplication::translate("country", "BurkinaFaso"))== "BurkinaFaso") countryName = "";break;
		case QLocale::Burundi: if((countryName = QCoreApplication::translate("country", "Burundi"))== "Burundi") countryName = "";break;
		case QLocale::Cambodia: if((countryName = QCoreApplication::translate("country", "Cambodia"))== "Cambodia") countryName = "";break;
		case QLocale::Cameroon: if((countryName = QCoreApplication::translate("country", "Cameroon"))== "Cameroon") countryName = "";break;
		case QLocale::Canada: if((countryName = QCoreApplication::translate("country", "Canada"))== "Canada") countryName = "";break;
		case QLocale::CapeVerde: if((countryName = QCoreApplication::translate("country", "CapeVerde"))== "CapeVerde") countryName = "";break;
		case QLocale::CaymanIslands: if((countryName = QCoreApplication::translate("country", "CaymanIslands"))== "CaymanIslands") countryName = "";break;
		case QLocale::CentralAfricanRepublic: if((countryName = QCoreApplication::translate("country", "CentralAfricanRepublic"))== "CentralAfricanRepublic") countryName = "";break;
		case QLocale::Chad: if((countryName = QCoreApplication::translate("country", "Chad"))== "Chad") countryName = "";break;
		case QLocale::Chile: if((countryName = QCoreApplication::translate("country", "Chile"))== "Chile") countryName = "";break;
		case QLocale::China: if((countryName = QCoreApplication::translate("country", "China"))== "China") countryName = "";break;
		case QLocale::Colombia: if((countryName = QCoreApplication::translate("country", "Colombia"))== "Colombia") countryName = "";break;
		case QLocale::Comoros: if((countryName = QCoreApplication::translate("country", "Comoros"))== "Comoros") countryName = "";break;
		case QLocale::PeoplesRepublicOfCongo: if((countryName = QCoreApplication::translate("country", "PeoplesRepublicOfCongo"))== "PeoplesRepublicOfCongo") countryName = "";break;
		case QLocale::DemocraticRepublicOfCongo: if((countryName = QCoreApplication::translate("country", "DemocraticRepublicOfCongo"))== "DemocraticRepublicOfCongo") countryName = "";break;
		case QLocale::CookIslands: if((countryName = QCoreApplication::translate("country", "CookIslands"))== "CookIslands") countryName = "";break;
		case QLocale::CostaRica: if((countryName = QCoreApplication::translate("country", "CostaRica"))== "CostaRica") countryName = "";break;
		case QLocale::IvoryCoast: if((countryName = QCoreApplication::translate("country", "IvoryCoast"))== "IvoryCoast") countryName = "";break;
		case QLocale::Croatia: if((countryName = QCoreApplication::translate("country", "Croatia"))== "Croatia") countryName = "";break;
		case QLocale::Cuba: if((countryName = QCoreApplication::translate("country", "Cuba"))== "Cuba") countryName = "";break;
		case QLocale::Cyprus: if((countryName = QCoreApplication::translate("country", "Cyprus"))== "Cyprus") countryName = "";break;
		case QLocale::CzechRepublic: if((countryName = QCoreApplication::translate("country", "CzechRepublic"))== "CzechRepublic") countryName = "";break;
		case QLocale::Denmark: if((countryName = QCoreApplication::translate("country", "Denmark"))== "Denmark") countryName = "";break;
		case QLocale::Djibouti: if((countryName = QCoreApplication::translate("country", "Djibouti"))== "Djibouti") countryName = "";break;
		case QLocale::Dominica: if((countryName = QCoreApplication::translate("country", "Dominica"))== "Dominica") countryName = "";break;
		case QLocale::DominicanRepublic: if((countryName = QCoreApplication::translate("country", "DominicanRepublic"))== "DominicanRepublic") countryName = "";break;
		case QLocale::Ecuador: if((countryName = QCoreApplication::translate("country", "Ecuador"))== "Ecuador") countryName = "";break;
		case QLocale::Egypt: if((countryName = QCoreApplication::translate("country", "Egypt"))== "Egypt") countryName = "";break;
		case QLocale::ElSalvador: if((countryName = QCoreApplication::translate("country", "ElSalvador"))== "ElSalvador") countryName = "";break;
		case QLocale::EquatorialGuinea: if((countryName = QCoreApplication::translate("country", "EquatorialGuinea"))== "EquatorialGuinea") countryName = "";break;
		case QLocale::Eritrea: if((countryName = QCoreApplication::translate("country", "Eritrea"))== "Eritrea") countryName = "";break;
		case QLocale::Estonia: if((countryName = QCoreApplication::translate("country", "Estonia"))== "Estonia") countryName = "";break;
		case QLocale::Ethiopia: if((countryName = QCoreApplication::translate("country", "Ethiopia"))== "Ethiopia") countryName = "";break;
		case QLocale::FalklandIslands: if((countryName = QCoreApplication::translate("country", "FalklandIslands"))== "FalklandIslands") countryName = "";break;
		case QLocale::FaroeIslands: if((countryName = QCoreApplication::translate("country", "FaroeIslands"))== "FaroeIslands") countryName = "";break;
		case QLocale::Fiji: if((countryName = QCoreApplication::translate("country", "Fiji"))== "Fiji") countryName = "";break;
		case QLocale::Finland: if((countryName = QCoreApplication::translate("country", "Finland"))== "Finland") countryName = "";break;
		case QLocale::France: if((countryName = QCoreApplication::translate("country", "France"))== "France") countryName = "";break;
		case QLocale::FrenchGuiana: if((countryName = QCoreApplication::translate("country", "FrenchGuiana"))== "FrenchGuiana") countryName = "";break;
		case QLocale::FrenchPolynesia: if((countryName = QCoreApplication::translate("country", "FrenchPolynesia"))== "FrenchPolynesia") countryName = "";break;
		case QLocale::Gabon: if((countryName = QCoreApplication::translate("country", "Gabon"))== "Gabon") countryName = "";break;
		case QLocale::Gambia: if((countryName = QCoreApplication::translate("country", "Gambia"))== "Gambia") countryName = "";break;
		case QLocale::Georgia: if((countryName = QCoreApplication::translate("country", "Georgia"))== "Georgia") countryName = "";break;
		case QLocale::Germany: if((countryName = QCoreApplication::translate("country", "Germany"))== "Germany") countryName = "";break;
		case QLocale::Ghana: if((countryName = QCoreApplication::translate("country", "Ghana"))== "Ghana") countryName = "";break;
		case QLocale::Gibraltar: if((countryName = QCoreApplication::translate("country", "Gibraltar"))== "Gibraltar") countryName = "";break;
		case QLocale::Greece: if((countryName = QCoreApplication::translate("country", "Greece"))== "Greece") countryName = "";break;
		case QLocale::Greenland: if((countryName = QCoreApplication::translate("country", "Greenland"))== "Greenland") countryName = "";break;
		case QLocale::Grenada: if((countryName = QCoreApplication::translate("country", "Grenada"))== "Grenada") countryName = "";break;
		case QLocale::Guadeloupe: if((countryName = QCoreApplication::translate("country", "Guadeloupe"))== "Guadeloupe") countryName = "";break;
		case QLocale::Guam: if((countryName = QCoreApplication::translate("country", "Guam"))== "Guam") countryName = "";break;
		case QLocale::Guatemala: if((countryName = QCoreApplication::translate("country", "Guatemala"))== "Guatemala") countryName = "";break;
		case QLocale::Guinea: if((countryName = QCoreApplication::translate("country", "Guinea"))== "Guinea") countryName = "";break;
		case QLocale::GuineaBissau: if((countryName = QCoreApplication::translate("country", "GuineaBissau"))== "GuineaBissau") countryName = "";break;
		case QLocale::Guyana: if((countryName = QCoreApplication::translate("country", "Guyana"))== "Guyana") countryName = "";break;
		case QLocale::Haiti: if((countryName = QCoreApplication::translate("country", "Haiti"))== "Haiti") countryName = "";break;
		case QLocale::Honduras: if((countryName = QCoreApplication::translate("country", "Honduras"))== "Honduras") countryName = "";break;
		case QLocale::HongKong: if((countryName = QCoreApplication::translate("country", "HongKong"))== "HongKong") countryName = "";break;
		case QLocale::Hungary: if((countryName = QCoreApplication::translate("country", "Hungary"))== "Hungary") countryName = "";break;
		case QLocale::Iceland: if((countryName = QCoreApplication::translate("country", "Iceland"))== "Iceland") countryName = "";break;
		case QLocale::India: if((countryName = QCoreApplication::translate("country", "India"))== "India") countryName = "";break;
		case QLocale::Indonesia: if((countryName = QCoreApplication::translate("country", "Indonesia"))== "Indonesia") countryName = "";break;
		case QLocale::Iran: if((countryName = QCoreApplication::translate("country", "Iran"))== "Iran") countryName = "";break;
		case QLocale::Iraq: if((countryName = QCoreApplication::translate("country", "Iraq"))== "Iraq") countryName = "";break;
		case QLocale::Ireland: if((countryName = QCoreApplication::translate("country", "Ireland"))== "Ireland") countryName = "";break;
		case QLocale::Israel: if((countryName = QCoreApplication::translate("country", "Israel"))== "Israel") countryName = "";break;
		case QLocale::Italy: if((countryName = QCoreApplication::translate("country", "Italy"))== "Italy") countryName = "";break;
		case QLocale::Jamaica: if((countryName = QCoreApplication::translate("country", "Jamaica"))== "Jamaica") countryName = "";break;
		case QLocale::Japan: if((countryName = QCoreApplication::translate("country", "Japan"))== "Japan") countryName = "";break;
		case QLocale::Jordan: if((countryName = QCoreApplication::translate("country", "Jordan"))== "Jordan") countryName = "";break;
		case QLocale::Kazakhstan: if((countryName = QCoreApplication::translate("country", "Kazakhstan"))== "Kazakhstan") countryName = "";break;
		case QLocale::Kenya: if((countryName = QCoreApplication::translate("country", "Kenya"))== "Kenya") countryName = "";break;
		case QLocale::Kiribati: if((countryName = QCoreApplication::translate("country", "Kiribati"))== "Kiribati") countryName = "";break;
		case QLocale::DemocraticRepublicOfKorea: if((countryName = QCoreApplication::translate("country", "DemocraticRepublicOfKorea"))== "DemocraticRepublicOfKorea") countryName = "";break;
		case QLocale::RepublicOfKorea: if((countryName = QCoreApplication::translate("country", "RepublicOfKorea"))== "RepublicOfKorea") countryName = "";break;
		case QLocale::Kuwait: if((countryName = QCoreApplication::translate("country", "Kuwait"))== "Kuwait") countryName = "";break;
		case QLocale::Kyrgyzstan: if((countryName = QCoreApplication::translate("country", "Kyrgyzstan"))== "Kyrgyzstan") countryName = "";break;
		case QLocale::Laos: if((countryName = QCoreApplication::translate("country", "Laos"))== "Laos") countryName = "";break;
		case QLocale::Latvia: if((countryName = QCoreApplication::translate("country", "Latvia"))== "Latvia") countryName = "";break;
		case QLocale::Lebanon: if((countryName = QCoreApplication::translate("country", "Lebanon"))== "Lebanon") countryName = "";break;
		case QLocale::Lesotho: if((countryName = QCoreApplication::translate("country", "Lesotho"))== "Lesotho") countryName = "";break;
		case QLocale::Liberia: if((countryName = QCoreApplication::translate("country", "Liberia"))== "Liberia") countryName = "";break;
		case QLocale::Libya: if((countryName = QCoreApplication::translate("country", "Libya"))== "Libya") countryName = "";break;
		case QLocale::Liechtenstein: if((countryName = QCoreApplication::translate("country", "Liechtenstein"))== "Liechtenstein") countryName = "";break;
		case QLocale::Lithuania: if((countryName = QCoreApplication::translate("country", "Lithuania"))== "Lithuania") countryName = "";break;
		case QLocale::Luxembourg: if((countryName = QCoreApplication::translate("country", "Luxembourg"))== "Luxembourg") countryName = "";break;
		case QLocale::Macau: if((countryName = QCoreApplication::translate("country", "Macau"))== "Macau") countryName = "";break;
		case QLocale::Macedonia: if((countryName = QCoreApplication::translate("country", "Macedonia"))== "Macedonia") countryName = "";break;
		case QLocale::Madagascar: if((countryName = QCoreApplication::translate("country", "Madagascar"))== "Madagascar") countryName = "";break;
		case QLocale::Malawi: if((countryName = QCoreApplication::translate("country", "Malawi"))== "Malawi") countryName = "";break;
		case QLocale::Malaysia: if((countryName = QCoreApplication::translate("country", "Malaysia"))== "Malaysia") countryName = "";break;
		case QLocale::Maldives: if((countryName = QCoreApplication::translate("country", "Maldives"))== "Maldives") countryName = "";break;
		case QLocale::Mali: if((countryName = QCoreApplication::translate("country", "Mali"))== "Mali") countryName = "";break;
		case QLocale::Malta: if((countryName = QCoreApplication::translate("country", "Malta"))== "Malta") countryName = "";break;
		case QLocale::MarshallIslands: if((countryName = QCoreApplication::translate("country", "MarshallIslands"))== "MarshallIslands") countryName = "";break;
		case QLocale::Martinique: if((countryName = QCoreApplication::translate("country", "Martinique"))== "Martinique") countryName = "";break;
		case QLocale::Mauritania: if((countryName = QCoreApplication::translate("country", "Mauritania"))== "Mauritania") countryName = "";break;
		case QLocale::Mauritius: if((countryName = QCoreApplication::translate("country", "Mauritius"))== "Mauritius") countryName = "";break;
		case QLocale::Mayotte: if((countryName = QCoreApplication::translate("country", "Mayotte"))== "Mayotte") countryName = "";break;
		case QLocale::Mexico: if((countryName = QCoreApplication::translate("country", "Mexico"))== "Mexico") countryName = "";break;
		case QLocale::Micronesia: if((countryName = QCoreApplication::translate("country", "Micronesia"))== "Micronesia") countryName = "";break;
		case QLocale::Moldova: if((countryName = QCoreApplication::translate("country", "Moldova"))== "Moldova") countryName = "";break;
		case QLocale::Monaco: if((countryName = QCoreApplication::translate("country", "Monaco"))== "Monaco") countryName = "";break;
		case QLocale::Mongolia: if((countryName = QCoreApplication::translate("country", "Mongolia"))== "Mongolia") countryName = "";break;
		case QLocale::Montenegro: if((countryName = QCoreApplication::translate("country", "Montenegro"))== "Montenegro") countryName = "";break;
		case QLocale::Montserrat: if((countryName = QCoreApplication::translate("country", "Montserrat"))== "Montserrat") countryName = "";break;
		case QLocale::Morocco: if((countryName = QCoreApplication::translate("country", "Morocco"))== "Morocco") countryName = "";break;
		case QLocale::Mozambique: if((countryName = QCoreApplication::translate("country", "Mozambique"))== "Mozambique") countryName = "";break;
		case QLocale::Myanmar: if((countryName = QCoreApplication::translate("country", "Myanmar"))== "Myanmar") countryName = "";break;
		case QLocale::Namibia: if((countryName = QCoreApplication::translate("country", "Namibia"))== "Namibia") countryName = "";break;
		case QLocale::NauruCountry: if((countryName = QCoreApplication::translate("country", "NauruCountry"))== "NauruCountry") countryName = "";break;
		case QLocale::Nepal: if((countryName = QCoreApplication::translate("country", "Nepal"))== "Nepal") countryName = "";break;
		case QLocale::Netherlands: if((countryName = QCoreApplication::translate("country", "Netherlands"))== "Netherlands") countryName = "";break;
		case QLocale::NewCaledonia: if((countryName = QCoreApplication::translate("country", "NewCaledonia"))== "NewCaledonia") countryName = "";break;
		case QLocale::NewZealand: if((countryName = QCoreApplication::translate("country", "NewZealand"))== "NewZealand") countryName = "";break;
		case QLocale::Nicaragua: if((countryName = QCoreApplication::translate("country", "Nicaragua"))== "Nicaragua") countryName = "";break;
		case QLocale::Niger: if((countryName = QCoreApplication::translate("country", "Niger"))== "Niger") countryName = "";break;
		case QLocale::Nigeria: if((countryName = QCoreApplication::translate("country", "Nigeria"))== "Nigeria") countryName = "";break;
		case QLocale::Niue: if((countryName = QCoreApplication::translate("country", "Niue"))== "Niue") countryName = "";break;
		case QLocale::NorfolkIsland: if((countryName = QCoreApplication::translate("country", "NorfolkIsland"))== "NorfolkIsland") countryName = "";break;
		case QLocale::NorthernMarianaIslands: if((countryName = QCoreApplication::translate("country", "NorthernMarianaIslands"))== "NorthernMarianaIslands") countryName = "";break;
		case QLocale::Norway: if((countryName = QCoreApplication::translate("country", "Norway"))== "Norway") countryName = "";break;
		case QLocale::Oman: if((countryName = QCoreApplication::translate("country", "Oman"))== "Oman") countryName = "";break;
		case QLocale::Pakistan: if((countryName = QCoreApplication::translate("country", "Pakistan"))== "Pakistan") countryName = "";break;
		case QLocale::Palau: if((countryName = QCoreApplication::translate("country", "Palau"))== "Palau") countryName = "";break;
		case QLocale::PalestinianTerritories: if((countryName = QCoreApplication::translate("country", "PalestinianTerritories"))== "PalestinianTerritories") countryName = "";break;
		case QLocale::Panama: if((countryName = QCoreApplication::translate("country", "Panama"))== "Panama") countryName = "";break;
		case QLocale::PapuaNewGuinea: if((countryName = QCoreApplication::translate("country", "PapuaNewGuinea"))== "PapuaNewGuinea") countryName = "";break;
		case QLocale::Paraguay: if((countryName = QCoreApplication::translate("country", "Paraguay"))== "Paraguay") countryName = "";break;
		case QLocale::Peru: if((countryName = QCoreApplication::translate("country", "Peru"))== "Peru") countryName = "";break;
		case QLocale::Philippines: if((countryName = QCoreApplication::translate("country", "Philippines"))== "Philippines") countryName = "";break;
		case QLocale::Poland: if((countryName = QCoreApplication::translate("country", "Poland"))== "Poland") countryName = "";break;
		case QLocale::Portugal: if((countryName = QCoreApplication::translate("country", "Portugal"))== "Portugal") countryName = "";break;
		case QLocale::PuertoRico: if((countryName = QCoreApplication::translate("country", "PuertoRico"))== "PuertoRico") countryName = "";break;
		case QLocale::Qatar: if((countryName = QCoreApplication::translate("country", "Qatar"))== "Qatar") countryName = "";break;
		case QLocale::Reunion: if((countryName = QCoreApplication::translate("country", "Reunion"))== "Reunion") countryName = "";break;
		case QLocale::Romania: if((countryName = QCoreApplication::translate("country", "Romania"))== "Romania") countryName = "";break;
		case QLocale::RussianFederation: if((countryName = QCoreApplication::translate("country", "RussianFederation"))== "RussianFederation") countryName = "";break;
		case QLocale::Rwanda: if((countryName = QCoreApplication::translate("country", "Rwanda"))== "Rwanda") countryName = "";break;
		case QLocale::SaintHelena: if((countryName = QCoreApplication::translate("country", "SaintHelena"))== "SaintHelena") countryName = "";break;
		case QLocale::SaintKittsAndNevis: if((countryName = QCoreApplication::translate("country", "SaintKittsAndNevis"))== "SaintKittsAndNevis") countryName = "";break;
		case QLocale::SaintLucia: if((countryName = QCoreApplication::translate("country", "SaintLucia"))== "SaintLucia") countryName = "";break;
		case QLocale::SaintPierreAndMiquelon: if((countryName = QCoreApplication::translate("country", "SaintPierreAndMiquelon"))== "SaintPierreAndMiquelon") countryName = "";break;
		case QLocale::SaintVincentAndTheGrenadines: if((countryName = QCoreApplication::translate("country", "SaintVincentAndTheGrenadines"))== "SaintVincentAndTheGrenadines") countryName = "";break;
		case QLocale::Samoa: if((countryName = QCoreApplication::translate("country", "Samoa"))== "Samoa") countryName = "";break;
		case QLocale::SanMarino: if((countryName = QCoreApplication::translate("country", "SanMarino"))== "SanMarino") countryName = "";break;
		case QLocale::SaoTomeAndPrincipe: if((countryName = QCoreApplication::translate("country", "SaoTomeAndPrincipe"))== "SaoTomeAndPrincipe") countryName = "";break;
		case QLocale::SaudiArabia: if((countryName = QCoreApplication::translate("country", "SaudiArabia"))== "SaudiArabia") countryName = "";break;
		case QLocale::Senegal: if((countryName = QCoreApplication::translate("country", "Senegal"))== "Senegal") countryName = "";break;
		case QLocale::Serbia: if((countryName = QCoreApplication::translate("country", "Serbia"))== "Serbia") countryName = "";break;
		case QLocale::Seychelles: if((countryName = QCoreApplication::translate("country", "Seychelles"))== "Seychelles") countryName = "";break;
		case QLocale::SierraLeone: if((countryName = QCoreApplication::translate("country", "SierraLeone"))== "SierraLeone") countryName = "";break;
		case QLocale::Singapore: if((countryName = QCoreApplication::translate("country", "Singapore"))== "Singapore") countryName = "";break;
		case QLocale::Slovakia: if((countryName = QCoreApplication::translate("country", "Slovakia"))== "Slovakia") countryName = "";break;
		case QLocale::Slovenia: if((countryName = QCoreApplication::translate("country", "Slovenia"))== "Slovenia") countryName = "";break;
		case QLocale::SolomonIslands: if((countryName = QCoreApplication::translate("country", "SolomonIslands"))== "SolomonIslands") countryName = "";break;
		case QLocale::Somalia: if((countryName = QCoreApplication::translate("country", "Somalia"))== "Somalia") countryName = "";break;
		case QLocale::SouthAfrica: if((countryName = QCoreApplication::translate("country", "SouthAfrica"))== "SouthAfrica") countryName = "";break;
		case QLocale::Spain: if((countryName = QCoreApplication::translate("country", "Spain"))== "Spain") countryName = "";break;
		case QLocale::SriLanka: if((countryName = QCoreApplication::translate("country", "SriLanka"))== "SriLanka") countryName = "";break;
		case QLocale::Sudan: if((countryName = QCoreApplication::translate("country", "Sudan"))== "Sudan") countryName = "";break;
		case QLocale::Suriname: if((countryName = QCoreApplication::translate("country", "Suriname"))== "Suriname") countryName = "";break;
		case QLocale::Swaziland: if((countryName = QCoreApplication::translate("country", "Swaziland"))== "Swaziland") countryName = "";break;
		case QLocale::Sweden: if((countryName = QCoreApplication::translate("country", "Sweden"))== "Sweden") countryName = "";break;
		case QLocale::Switzerland: if((countryName = QCoreApplication::translate("country", "Switzerland"))== "Switzerland") countryName = "";break;
		case QLocale::Syria: if((countryName = QCoreApplication::translate("country", "Syria"))== "Syria") countryName = "";break;
		case QLocale::Taiwan: if((countryName = QCoreApplication::translate("country", "Taiwan"))== "Taiwan") countryName = "";break;
		case QLocale::Tajikistan: if((countryName = QCoreApplication::translate("country", "Tajikistan"))== "Tajikistan") countryName = "";break;
		case QLocale::Tanzania: if((countryName = QCoreApplication::translate("country", "Tanzania"))== "Tanzania") countryName = "";break;
		case QLocale::Thailand: if((countryName = QCoreApplication::translate("country", "Thailand"))== "Thailand") countryName = "";break;
		case QLocale::Togo: if((countryName = QCoreApplication::translate("country", "Togo"))== "Togo") countryName = "";break;
		case QLocale::Tokelau: if((countryName = QCoreApplication::translate("country", "Tokelau"))== "Tokelau") countryName = "";break;
		case QLocale::Tonga: if((countryName = QCoreApplication::translate("country", "Tonga"))== "Tonga") countryName = "";break;
		case QLocale::TrinidadAndTobago: if((countryName = QCoreApplication::translate("country", "TrinidadAndTobago"))== "TrinidadAndTobago") countryName = "";break;
		case QLocale::Tunisia: if((countryName = QCoreApplication::translate("country", "Tunisia"))== "Tunisia") countryName = "";break;
		case QLocale::Turkey: if((countryName = QCoreApplication::translate("country", "Turkey"))== "Turkey") countryName = "";break;
		case QLocale::Turkmenistan: if((countryName = QCoreApplication::translate("country", "Turkmenistan"))== "Turkmenistan") countryName = "";break;
		case QLocale::TurksAndCaicosIslands: if((countryName = QCoreApplication::translate("country", "TurksAndCaicosIslands"))== "TurksAndCaicosIslands") countryName = "";break;
		case QLocale::Tuvalu: if((countryName = QCoreApplication::translate("country", "Tuvalu"))== "Tuvalu") countryName = "";break;
		case QLocale::Uganda: if((countryName = QCoreApplication::translate("country", "Uganda"))== "Uganda") countryName = "";break;
		case QLocale::Ukraine: if((countryName = QCoreApplication::translate("country", "Ukraine"))== "Ukraine") countryName = "";break;
		case QLocale::UnitedArabEmirates: if((countryName = QCoreApplication::translate("country", "UnitedArabEmirates"))== "UnitedArabEmirates") countryName = "";break;
		case QLocale::UnitedKingdom: if((countryName = QCoreApplication::translate("country", "UnitedKingdom"))== "UnitedKingdom") countryName = "";break;
		case QLocale::UnitedStates: if((countryName = QCoreApplication::translate("country", "UnitedStates"))== "UnitedStates") countryName = "";break;
		case QLocale::Uruguay: if((countryName = QCoreApplication::translate("country", "Uruguay"))== "Uruguay") countryName = "";break;
		case QLocale::Uzbekistan: if((countryName = QCoreApplication::translate("country", "Uzbekistan"))== "Uzbekistan") countryName = "";break;
		case QLocale::Vanuatu: if((countryName = QCoreApplication::translate("country", "Vanuatu"))== "Vanuatu") countryName = "";break;
		case QLocale::Venezuela: if((countryName = QCoreApplication::translate("country", "Venezuela"))== "Venezuela") countryName = "";break;
		case QLocale::Vietnam: if((countryName = QCoreApplication::translate("country", "Vietnam"))== "Vietnam") countryName = "";break;
		case QLocale::WallisAndFutunaIslands: if((countryName = QCoreApplication::translate("country", "WallisAndFutunaIslands"))== "WallisAndFutunaIslands") countryName = "";break;
		case QLocale::Yemen: if((countryName = QCoreApplication::translate("country", "Yemen"))== "Yemen") countryName = "";break;
		case QLocale::Zambia: if((countryName = QCoreApplication::translate("country", "Zambia"))== "Zambia") countryName = "";break;
		case QLocale::Zimbabwe: if((countryName = QCoreApplication::translate("country", "Zimbabwe"))== "Zimbabwe") countryName = "";break;
		default: {
			countryName = QLocale::countryToString(p_country);
		}
	}
	if( countryName == "")
		countryName = QLocale::countryToString(p_country);
	return countryName;
}
// Copy a folder recursively without erasing old file
void Utils::copyDir(QString from, QString to) {
	QDir dir;
	dir.setPath(from);
	from += QDir::separator();
	to += QDir::separator();
	foreach (QString copyFile, dir.entryList(QDir::Files)) {// Copy each files
		QString toFile = to + copyFile;
		if (!QFile::exists(toFile))
			QFile::copy(from+copyFile, toFile);
	}
	foreach (QString nextDir, dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {// Copy folder
		QString toDir = to + nextDir;
		QDir().mkpath(toDir);// no need to check if dir exists
		copyDir(from + nextDir, toDir);//Go up
	}
}

QString Utils::getDisplayName(const std::shared_ptr<const linphone::Address>& address){
	QString displayName;
	if(address){
		displayName = CoreManager::getInstance()->getSipAddressesModel()->getDisplayName(address);
	}
	return displayName;
}

std::shared_ptr<linphone::Config> Utils::getConfigIfExists (const QString &configPath) {
	std::string factoryPath(Paths::getFactoryConfigFilePath());
	if (!Paths::filePathExists(factoryPath))
		factoryPath.clear();
	
	return linphone::Config::newWithFactory(configPath.toStdString(), factoryPath);
}

QString Utils::getApplicationProduct(){
// Note: Keep '-' as a separator between application name and application type
	return QString(APPLICATION_NAME"-Desktop").remove(' ')+"/"+QCoreApplication::applicationVersion();
}

QString Utils::getOsProduct(){
	QString version = QSysInfo::productVersion().remove(' ');// A version can be "Server 2016" (for Windows Server 2016)
	QString product = QSysInfo::productType().replace(' ', '-');	// Just in case
	return product+"/"+version;
}

QString Utils::computeUserAgent(const std::shared_ptr<linphone::Config>& config){
	return QStringLiteral("%1 (%2) %3 Qt/%4 LinphoneSDK")
					.arg(Utils::getApplicationProduct())
					.arg(SettingsModel::getDeviceName(config)
							.replace('\\', "\\\\")
							.replace('(', "\\(")
							.replace(')', "\\)")
					)
					.arg(Utils::getOsProduct())
					.arg(qVersion());
}

bool Utils::isMe(const QString& address){
	return !address.isEmpty() ? isMe(Utils::interpretUrl(address)) : false;
}

bool Utils::isMe(const std::shared_ptr<const linphone::Address>& address){
    if( !CoreManager::getInstance()->getCore()->getDefaultAccount()){// Default account is selected : Me is all local accounts.
        return CoreManager::getInstance()->getAccountSettingsModel()->findAccount(address) != nullptr;
    }else
        return address ? CoreManager::getInstance()->getAccountSettingsModel()->getUsedSipAddress()->weakEqual(address) : false;
}
bool Utils::isLocal(const std::shared_ptr<linphone::Conference>& conference, const std::shared_ptr<const linphone::ParticipantDevice>& device) {
	auto deviceAddress = device->getAddress();
	auto callAddress = conference->getMe()->getAddress();
	auto gruuAddress = CoreManager::getInstance()->getAccountSettingsModel()->findAccount(callAddress)->getContactAddress();
	return deviceAddress->equal(gruuAddress);
}

bool Utils::isAnimatedImage(const QString& path){
	if(path.isEmpty()) return false;
	QFileInfo info(path);
	if( !info.exists() || !QMimeDatabase().mimeTypeForFile(info).name().contains("image/"))
		return false;
	QImageReader reader(path);
	return reader.canRead() && reader.supportsAnimation() && reader.imageCount() > 1;
}

bool Utils::isImage(const QString& path){
	if(path.isEmpty()) return false;
	QFileInfo info(path);
	if( !info.exists() || CoreManager::getInstance()->getSettingsModel()->getVfsEncrypted()){
		return QMimeDatabase().mimeTypeForFile(info, QMimeDatabase::MatchExtension).name().contains("image/");
	}else if(!QMimeDatabase().mimeTypeForFile(info).name().contains("image/"))
		return false;
	QImageReader reader(path);
	return reader.canRead() && reader.imageCount() == 1;
}

bool Utils::isVideo(const QString& path){
	if(path.isEmpty()) return false;
	return QMimeDatabase().mimeTypeForFile(path).name().contains("video/");
}

bool Utils::isPdf(const QString& path){
	if(path.isEmpty()) return false;
	return QMimeDatabase().mimeTypeForFile(path).name().contains("application/pdf");
}

bool Utils::isSupportedForDisplay(const QString& path){
	if(path.isEmpty()) return false;
	return !QMimeDatabase().mimeTypeForFile(path).name().contains("application");// "for pdf : "application/pdf". Note : Make an exception when supported.
}

bool Utils::canHaveThumbnail(const QString& path){
	if(path.isEmpty()) return false;
	return isImage(path) || isAnimatedImage(path) || isPdf(path) || isVideo(path);
}

bool Utils::isPhoneNumber(const QString& txt){
	auto core = CoreManager::getInstance()->getCore();
	if(!core)
		return false;
	auto account = core->getDefaultAccount();
	return account && account->isPhoneNumber(Utils::appStringToCoreString(txt));
}

bool Utils::isUsername(const QString& txt){
	QRegularExpression regex("^(<?sips?:)?[a-zA-Z0-9+_.\\-]+>?$");
	QRegularExpressionMatch match = regex.match(txt);
	return match.hasMatch(); // true
}

bool Utils::isValidUrl(const QString& url){
	return QUrl(url).isValid();
}

QSize Utils::getImageSize(const QString& url){
	QString path;
	QUrl urlDecode(url);
	if(urlDecode.isLocalFile())
		path = QDir::toNativeSeparators(urlDecode.toLocalFile());
	else
		path = url;
	QFileInfo info(path);
	if( !info.exists())
		return QSize(0,0);
	QImageReader reader(path);
	QSize s = reader.size();
	if( s.isValid())
		return s;
	else
		return QSize(0,0);
}

QPoint Utils::getCursorPosition(){
	return QCursor::pos();
}

QString Utils::getFileChecksum(const QString& filePath){
    QFile file(filePath);
    if (file.open(QFile::ReadOnly)) {
        QCryptographicHash hash(QCryptographicHash::Sha256);
        if (hash.addData(&file)) {
            return hash.result().toHex();
        }
    }
    return QString();
}
bool Utils::codepointIsEmoji(uint code){
        return (code >= 0x2600 && code <= 0x27bf) || (code >= 0x2b00 && code <= 0x2bff) ||
               (code >= 0x1f000 && code <= 0x1faff) || code == 0x200d || code == 0xfe0f;
}

bool Utils::codepointIsVisible(uint code) {
	return code > 0x00020;
}

QString Utils::encodeEmojiToQmlRichFormat(const QString &body){
	QString fmtBody = "";
	QVector<uint> utf32_string = body.toUcs4();
	
	bool insideFontBlock = false;
	for (auto &code : utf32_string) {
		if (Utils::codepointIsEmoji(code)) {
			if (!insideFontBlock) {
				fmtBody += QString("<font face=\"" +
								   CoreManager::getInstance()->getSettingsModel()->getEmojiFont().family() + "\">");
				insideFontBlock = true;
			}
		} else {
			if (insideFontBlock) {
				fmtBody += "</font>";
				insideFontBlock = false;
			}
		}
		fmtBody += QString::fromUcs4(&code, 1);
	}
	if (insideFontBlock) {
		fmtBody += "</font>";
	}
	return fmtBody;
}

bool Utils::isOnlyEmojis(const QString& text){
	if(text.isEmpty()) return false;
	QVector<uint> utf32_string = text.toUcs4();
	for (auto &code : utf32_string)
		if(codepointIsVisible(code) && !Utils::codepointIsEmoji(code))
			return false;
	return true;
}


QString Utils::encodeTextToQmlRichFormat(const QString& text, const QVariantMap& options){
	/*QString images;
	QStringList imageFormat;
	for(auto format : QImageReader::supportedImageFormats())
		imageFormat.append(QString::fromLatin1(format).toUpper());
	*/
	QStringList formattedText;
	bool lastWasUrl = false;
	
	if(options.contains("noLink") && options["noLink"].toBool()){
		formattedText.append(encodeEmojiToQmlRichFormat(text));
	}else{
		auto primaryColor = App::getInstance()->getColorListModel()->getColor("i")->getColor();
		auto iriParsed = UriTools::parseIri(text);
		
		for(int i = 0 ; i < iriParsed.size() ; ++i){
			QString iri = iriParsed[i].second.replace('&', "&amp;")
						.replace('<', "\u2063&lt;")
						.replace('>', "\u2063&gt;")
						.replace('"', "&quot;")
						.replace('\'', "&#039;");
			if(!iriParsed[i].first){
				if(lastWasUrl){
					lastWasUrl = false;
					if(iri.front() != ' ')
						iri.push_front(' ');
				}
				formattedText.append(encodeEmojiToQmlRichFormat(iri));
			}else{
				QString uri = iriParsed[i].second.left(3) == "www" ? "http://"+iriParsed[i].second : iriParsed[i].second ;
				/* TODO : preview from link
				int extIndex = iriParsed[i].second.lastIndexOf('.');
				QString ext;
				if( extIndex >= 0)
					ext = iriParsed[i].second.mid(extIndex+1).toUpper();
				if(imageFormat.contains(ext.toLatin1())){// imagesHeight is not used because of bugs on display (blank image if set without width)
					images += "<a href=\"" + uri + "\"><img" + (
							options.contains("imagesWidth")
								? QString(" width='") + options["imagesWidth"].toString() + "'"
								: ""
						) + (
							options.contains("imagesWidth")
							? QString(" height='auto'")
							: ""
						) + " src=\"" + iriParsed[i].second + "\" />"+uri+"</a>";
				}else{
				*/
					formattedText.append( "<a style=\"color:"+ primaryColor.name() +";\" href=\"" + uri + "\">" + iri + "</a>");
					lastWasUrl = true;
				/*}*/
			}
		}
	}
	if(lastWasUrl && formattedText.last().back() != ' '){
		formattedText.push_back(" ");
	}
	return "<p style=\"white-space:pre-wrap;\">" + formattedText.join("") + "</p>";
}

QString Utils::getFileContent(const QString& filePath){
	QString contents;
	QFile file(filePath);
	if (!file.open(QFile::ReadOnly | QFile::Text))
		return "";
	return file.readAll();
}
static QStringList gDbPaths;

void Utils::deleteAllUserData(){
// Store usable data like custom folders
	gDbPaths.clear();
	gDbPaths.append(Utils::coreStringToAppString(linphone::Factory::get()->getDataDir(nullptr)));
	gDbPaths.append(Utils::coreStringToAppString(linphone::Factory::get()->getConfigDir(nullptr)));
// Exit with a delete code
	App::getInstance()->exit(App::DeleteDataCode);
}

void Utils::deleteAllUserDataOffline(){
	qWarning() << "Deleting all data! ";
	for(int i = 0 ; i < gDbPaths.size() ; ++i){
		QDir dir(gDbPaths[i]);
		qWarning() << "Deleting " << gDbPaths[i] << " : " << (dir.removeRecursively() ? "Successfully" : "Failed");
	}
}

//-------------------------------------------------------------------------------------------------------
//					WIDGETS
//-------------------------------------------------------------------------------------------------------

bool Utils::openWithPdfViewer(ContentModel * contentModel, const QString& filePath, const int& width, const int& height) {
#ifdef PDF_ENABLED
	PdfWidget *view = new PdfWidget(contentModel);
	view->setMinimumSize(QSize(width, height));
	view->show();
	view->open(filePath);
	return true;
#else
	return false;
#endif
}

void Utils::setFamilyFont(QAction * dest, const QString& family){
	QFont font(dest->font());
	font.setFamily(family);
	dest->setFont(font);
}
void Utils::setFamilyFont(QWidget * dest, const QString& family){
	QFont font(dest->font());
	font.setFamily(family);
	dest->setFont(font);
}
QPixmap Utils::getMaskedPixmap(const QString& name, const QColor& color){
	QSize size;
	QPixmap img = ImageProvider::computePixmap(name, &size);
	QPixmap pxr( img.size() );
	pxr.fill( color );
	pxr.setMask( img.createMaskFromColor( Qt::transparent ) );
	return pxr;
}
