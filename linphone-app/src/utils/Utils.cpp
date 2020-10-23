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

#include <QFileInfo>
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QImageReader>

#include "Utils.hpp"
#include "components/core/CoreManager.hpp"

// =============================================================================

namespace {
  constexpr int SafeFilePathLimit = 100;
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
QImage Utils::getImage(const QString &pUri) {
	QImage image(pUri);
	if(image.isNull()){// Try to determine format from headers instead of using suffix
		QImageReader reader(pUri);
		reader.setDecideFormatFromContent(true);
		QByteArray format = reader.format();
		if(!format.isEmpty())
			image = QImage(pUri, format);
	}
	return image;
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
  // Get default proxy
  addresses.push_back(CoreManager::getInstance()->getCore()->createPrimaryContactParsed());
  auto proxyList = CoreManager::getInstance()->getCore()->getProxyConfigList();
  foreach(auto proxy, proxyList)
    addresses.push_back(proxy->getIdentityAddress()->clone());
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
