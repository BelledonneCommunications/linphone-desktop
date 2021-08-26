/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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
#include "ColorListModel.hpp"

#include <linphone++/linphone.hh>

#include <QQmlApplicationEngine>
#include <QJsonValue>
#if LINPHONE_FRIDAY
  #include <QDate>
#endif // if LINPHONE_FRIDAY


#include "app/App.hpp"


#include "utils/Utils.hpp"

#include "components/Components.hpp"

namespace {
  constexpr char ColorsSection[] = "ui_colors";
}

// =============================================================================

ColorListModel::ColorListModel ( QObject *parent) : QAbstractListModel(parent) {
	init();	
}

int ColorListModel::rowCount (const QModelIndex &index) const{
	return mList.count();
}

QHash<int, QByteArray> ColorListModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$color";
	return roles;
}

QVariant ColorListModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mList.count())
		return QVariant();
	
	//if (role == Qt::DisplayRole)
		return QVariant::fromValue(mList[row].get());
	
	//return QVariant();
}

void ColorListModel::add(std::shared_ptr<ColorModel> color){
	int row = mList.count();
	beginInsertRows(QModelIndex(), row, row);
	setProperty(color->getName().toStdString().c_str(), QVariant::fromValue(color.get()));
	
	mData.insert(color->getName(), QVariant::fromValue(color.get()));
	mList << color;
	
	endInsertRows();
	emit layoutChanged();
}

bool ColorListModel::removeRow (int row, const QModelIndex &parent){
	return removeRows(row, 1, parent);
}

bool ColorListModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
	if (row < 0 || count < 0 || limit >= mList.count())
		return false;
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i)
		mList.takeAt(row);
	
	endRemoveRows();
	return true;
}

void ColorListModel::useConfig (const std::shared_ptr<linphone::Config> &config) {
  #if LINPHONE_FRIDAY
    if (!isLinphoneFriday())
      overrideColors(config);
  #else
    overrideColors(config);
  #endif // if LINPHONE_FRIDAY
}

QString ColorListModel::getNames(){
	QStringList names;
	const QMetaObject *info = metaObject();

  for (int i = info->propertyOffset(); i < info->propertyCount(); ++i) {
		const QMetaProperty metaProperty = info->property(i);
		const std::string colorName = metaProperty.name();
		names << QString::fromStdString(colorName);
    }
    return names.join(", ");
}

QQmlPropertyMap * ColorListModel::getQmlData() {
	return &mData;
}

const QQmlPropertyMap * ColorListModel::getQmlData() const{
	return &mData;
}

void ColorListModel::overrideColors (const std::shared_ptr<linphone::Config> &config) {
  if (!config)
    return;
	for(auto color : mList){
		QString name = color->getName();
		const std::string colorValue = config->getString(ColorsSection, name.toStdString(), "");
		if(!colorValue.empty()){
			color->setColor(QColor(QString::fromStdString(colorValue)));
		}
	}
}

//--------------------------------------------------------------------------------
/*
std::shared_ptr<ColorModel> ColorListModel::getImdnState(const std::shared_ptr<const linphone::Color> & state){
	std::shared_ptr<ColorModel> imdn;
	auto imdnAddress = state->getParticipant()->getAddress();
	auto it = mList.begin();
	while(it != mList.end() && !(*it)->getAddress()->equal(imdnAddress))
		++it;
	if(it != mList.end())
		imdn = *it;
	else{// Create the new one
		imdn = std::make_shared<ColorModel>(state);
		add(imdn);
	}
	return imdn;
}
*/
//--------------------------------------------------------------------------------