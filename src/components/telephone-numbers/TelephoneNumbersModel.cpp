/*
 * TelephoneNumbersModel.cpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: May 31, 2017
 *      Author: Ronan Abhamon
 */

#include "TelephoneNumbersModel.hpp"

using namespace std;

// =============================================================================

const QList<QPair<QLocale::Country, QString> > TelephoneNumbersModel::mCountryCodes = {
  { QLocale::Afghanistan, "93" },
  { QLocale::Albania, "355" },
  { QLocale::Algeria, "213" },
  { QLocale::AmericanSamoa, "1" },
  { QLocale::Andorra, "376" },
  { QLocale::Angola, "244" },
  { QLocale::Anguilla, "1" },
  { QLocale::AntiguaAndBarbuda, "1" },
  { QLocale::Argentina, "54" },
  { QLocale::Armenia, "374" },
  { QLocale::Aruba, "297" },
  { QLocale::Australia, "61" },
  { QLocale::Austria, "43" },
  { QLocale::Azerbaijan, "994" },
  { QLocale::Bahamas, "1" },
  { QLocale::Bahrain, "973" },
  { QLocale::Bangladesh, "880" },
  { QLocale::Barbados, "1" },
  { QLocale::Belarus, "375" },
  { QLocale::Belgium, "32" },
  { QLocale::Belize, "501" },
  { QLocale::Benin, "229" },
  { QLocale::Bermuda, "1" },
  { QLocale::Bhutan, "975" },
  { QLocale::Bolivia, "591" },
  { QLocale::BosniaAndHerzegowina, "387" },
  { QLocale::Botswana, "267" },
  { QLocale::Brazil, "55" },
  { QLocale::Brunei, "673" },
  { QLocale::Bulgaria, "359" },
  { QLocale::BurkinaFaso, "226" },
  { QLocale::Burundi, "257" },
  { QLocale::Cambodia, "855" },
  { QLocale::Cameroon, "237" },
  { QLocale::Canada, "1" },
  { QLocale::CapeVerde, "238" },
  { QLocale::CaymanIslands, "1" },
  { QLocale::CentralAfricanRepublic, "236" },
  { QLocale::Chad, "235" },
  { QLocale::Chile, "56" },
  { QLocale::China, "86" },
  { QLocale::Colombia, "57" },
  { QLocale::Comoros, "269" },
  { QLocale::PeoplesRepublicOfCongo, "242" },
  { QLocale::DemocraticRepublicOfCongo, "243" },
  { QLocale::CookIslands, "682" },
  { QLocale::CostaRica, "506" },
  { QLocale::IvoryCoast, "225" },
  { QLocale::Croatia, "385" },
  { QLocale::Cuba, "53" },
  { QLocale::Cyprus, "357" },
  { QLocale::CzechRepublic, "420" },
  { QLocale::Denmark, "45" },
  { QLocale::Djibouti, "253" },
  { QLocale::Dominica, "1" },
  { QLocale::DominicanRepublic, "1" },
  { QLocale::Ecuador, "593" },
  { QLocale::Egypt, "20" },
  { QLocale::ElSalvador, "503" },
  { QLocale::EquatorialGuinea, "240" },
  { QLocale::Eritrea, "291" },
  { QLocale::Estonia, "372" },
  { QLocale::Ethiopia, "251" },
  { QLocale::FalklandIslands, "500" },
  { QLocale::FaroeIslands, "298" },
  { QLocale::Fiji, "679" },
  { QLocale::Finland, "358" },
  { QLocale::France, "33" },
  { QLocale::FrenchGuiana, "594" },
  { QLocale::FrenchPolynesia, "689" },
  { QLocale::Gabon, "241" },
  { QLocale::Gambia, "220" },
  { QLocale::Georgia, "995" },
  { QLocale::Germany, "49" },
  { QLocale::Ghana, "233" },
  { QLocale::Gibraltar, "350" },
  { QLocale::Greece, "30" },
  { QLocale::Greenland, "299" },
  { QLocale::Grenada, "1" },
  { QLocale::Guadeloupe, "590" },
  { QLocale::Guam, "1" },
  { QLocale::Guatemala, "502" },
  { QLocale::Guinea, "224" },
  { QLocale::GuineaBissau, "245" },
  { QLocale::Guyana, "592" },
  { QLocale::Haiti, "509" },
  { QLocale::Honduras, "504" },
  { QLocale::HongKong, "852" },
  { QLocale::Hungary, "36" },
  { QLocale::Iceland, "354" },
  { QLocale::India, "91" },
  { QLocale::Indonesia, "62" },
  { QLocale::Iran, "98" },
  { QLocale::Iraq, "964" },
  { QLocale::Ireland, "353" },
  { QLocale::Israel, "972" },
  { QLocale::Italy, "39" },
  { QLocale::Jamaica, "1" },
  { QLocale::Japan, "81" },
  { QLocale::Jordan, "962" },
  { QLocale::Kazakhstan, "7" },
  { QLocale::Kenya, "254" },
  { QLocale::Kiribati, "686" },
  { QLocale::DemocraticRepublicOfKorea, "850" },
  { QLocale::RepublicOfKorea, "82" },
  { QLocale::Kuwait, "965" },
  { QLocale::Kyrgyzstan, "996" },
  { QLocale::Laos, "856" },
  { QLocale::Latvia, "371" },
  { QLocale::Lebanon, "961" },
  { QLocale::Lesotho, "266" },
  { QLocale::Liberia, "231" },
  { QLocale::Libya, "218" },
  { QLocale::Liechtenstein, "423" },
  { QLocale::Lithuania, "370" },
  { QLocale::Luxembourg, "352" },
  { QLocale::Macau, "853" },
  { QLocale::Macedonia, "389" },
  { QLocale::Madagascar, "261" },
  { QLocale::Malawi, "265" },
  { QLocale::Malaysia, "60" },
  { QLocale::Maldives, "960" },
  { QLocale::Mali, "223" },
  { QLocale::Malta, "356" },
  { QLocale::MarshallIslands, "692" },
  { QLocale::Martinique, "596" },
  { QLocale::Mauritania, "222" },
  { QLocale::Mauritius, "230" },
  { QLocale::Mayotte, "262" },
  { QLocale::Mexico, "52" },
  { QLocale::Micronesia, "691" },
  { QLocale::Moldova, "373" },
  { QLocale::Monaco, "377" },
  { QLocale::Mongolia, "976" },
  { QLocale::Montenegro, "382" },
  { QLocale::Montserrat, "664" },
  { QLocale::Morocco, "212" },
  { QLocale::Mozambique, "258" },
  { QLocale::Myanmar, "95" },
  { QLocale::Namibia, "264" },
  { QLocale::NauruCountry, "674" },
  { QLocale::Nepal, "43" },
  { QLocale::Netherlands, "31" },
  { QLocale::NewCaledonia, "687" },
  { QLocale::NewZealand, "64" },
  { QLocale::Nicaragua, "505" },
  { QLocale::Niger, "227" },
  { QLocale::Nigeria, "234" },
  { QLocale::Niue, "683" },
  { QLocale::NorfolkIsland, "672" },
  { QLocale::NorthernMarianaIslands, "1" },
  { QLocale::Norway, "47" },
  { QLocale::Oman, "968" },
  { QLocale::Pakistan, "92" },
  { QLocale::Palau, "680" },
  { QLocale::PalestinianTerritories, "970" },
  { QLocale::Panama, "507" },
  { QLocale::PapuaNewGuinea, "675" },
  { QLocale::Paraguay, "595" },
  { QLocale::Peru, "51" },
  { QLocale::Philippines, "63" },
  { QLocale::Poland, "48" },
  { QLocale::Portugal, "351" },
  { QLocale::PuertoRico, "1" },
  { QLocale::Qatar, "974" },
  { QLocale::Reunion, "262" },
  { QLocale::Romania, "40" },
  { QLocale::RussianFederation, "7" },
  { QLocale::Rwanda, "250" },
  { QLocale::SaintHelena, "290" },
  { QLocale::SaintKittsAndNevis, "1" },
  { QLocale::SaintLucia, "1" },
  { QLocale::SaintPierreAndMiquelon, "508" },
  { QLocale::SaintVincentAndTheGrenadines, "1" },
  { QLocale::Samoa, "685" },
  { QLocale::SanMarino, "378" },
  { QLocale::SaoTomeAndPrincipe, "239" },
  { QLocale::SaudiArabia, "966" },
  { QLocale::Senegal, "221" },
  { QLocale::Serbia, "381" },
  { QLocale::Seychelles, "248" },
  { QLocale::SierraLeone, "232" },
  { QLocale::Singapore, "65" },
  { QLocale::Slovakia, "421" },
  { QLocale::Slovenia, "386" },
  { QLocale::SolomonIslands, "677" },
  { QLocale::Somalia, "252" },
  { QLocale::SouthAfrica, "27" },
  { QLocale::Spain, "34" },
  { QLocale::SriLanka, "94" },
  { QLocale::Sudan, "249" },
  { QLocale::Suriname, "597" },
  { QLocale::Swaziland, "268" },
  { QLocale::Sweden, "46" },
  { QLocale::Switzerland, "41" },
  { QLocale::Syria, "963" },
  { QLocale::Taiwan, "886" },
  { QLocale::Tajikistan, "992" },
  { QLocale::Tanzania, "255" },
  { QLocale::Thailand, "66" },
  { QLocale::Togo, "228" },
  { QLocale::Tokelau, "690" },
  { QLocale::Tonga, "676" },
  { QLocale::TrinidadAndTobago, "1" },
  { QLocale::Tunisia, "216" },
  { QLocale::Turkey, "90" },
  { QLocale::Turkmenistan, "993" },
  { QLocale::TurksAndCaicosIslands, "1" },
  { QLocale::Tuvalu, "688" },
  { QLocale::Uganda, "256" },
  { QLocale::Ukraine, "380" },
  { QLocale::UnitedArabEmirates, "971" },
  { QLocale::UnitedKingdom, "44" },
  { QLocale::UnitedStates, "1" },
  { QLocale::Uruguay, "598" },
  { QLocale::Uzbekistan, "998" },
  { QLocale::Vanuatu, "678" },
  { QLocale::Venezuela, "58" },
  { QLocale::Vietnam, "84" },
  { QLocale::WallisAndFutunaIslands, "681" },
  { QLocale::Yemen, "967" },
  { QLocale::Zambia, "260" },
  { QLocale::Zimbabwe, "263" }
};

// -----------------------------------------------------------------------------

TelephoneNumbersModel::TelephoneNumbersModel (QObject *parent) : QAbstractListModel(parent) {}

int TelephoneNumbersModel::rowCount (const QModelIndex &) const {
  return mCountryCodes.count();
}

QHash<int, QByteArray> TelephoneNumbersModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$phoneNumber";
  return roles;
}

QVariant TelephoneNumbersModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (!index.isValid() || row < 0 || row >= mCountryCodes.count())
    return QVariant();

  if (role == Qt::DisplayRole) {
    const QPair<QLocale::Country, QString> &countryCode = mCountryCodes[row];

    QVariantMap map;
    map["countryCode"] = countryCode.second;
    map["countryName"] = QStringLiteral("%1 (+%2)")
      .arg(QLocale::countryToString(countryCode.first))
      .arg(countryCode.second);
    return map;
  }

  return QVariant();
}

int TelephoneNumbersModel::getDefaultIndex () const {
  QLocale::Country country = QLocale().country();
  const auto it = find_if(
      mCountryCodes.cbegin(), mCountryCodes.cend(), [&country](const QPair<QLocale::Country, QString> &pair) {
        return country == pair.first;
      }
    );
  return it != mCountryCodes.cend() ? static_cast<int>(distance(mCountryCodes.cbegin(), it)) : 0;
}
