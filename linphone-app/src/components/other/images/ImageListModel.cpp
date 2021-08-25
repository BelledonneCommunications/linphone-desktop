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
#include "ImageListModel.hpp"

#include <linphone++/linphone.hh>

#include <QQmlApplicationEngine>
#include <QJsonValue>
#include <QDir>
#if LINPHONE_FRIDAY
  #include <QDate>
#endif // if LINPHONE_FRIDAY


#include "app/App.hpp"


#include "utils/Utils.hpp"

#include "components/Components.hpp"
#include "ImageModel.hpp"

namespace {
  constexpr char ImagesSection[] = "ui_images";
}

// =============================================================================

ImageListModel::ImageListModel ( QObject *parent) : QAbstractListModel(parent), mData(this) {
// Get all internals
	QString path = ":/assets/images/";
	QStringList filters;
	filters << "*.svg";
	
	QFileInfoList  files = QDir(path).entryInfoList(filters, QDir::Files , QDir::Name);
	for(QFileInfo file : files){
		std::shared_ptr<ImageModel> model = std::make_shared<ImageModel>(file.completeBaseName(), path+file.fileName(), "");
		add(model);
	}
	mData.insert("areReadOnlyImages", QVariant::fromValue(true));
}

int ImageListModel::rowCount (const QModelIndex &index) const{
	return mList.count();
}

QHash<int, QByteArray> ImageListModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$image";
	return roles;
}

QVariant ImageListModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mList.count())
		return QVariant();
	return QVariant::fromValue(mList[row].get());
}

void ImageListModel::add(std::shared_ptr<ImageModel> image){
	int row = mList.count();
	beginInsertRows(QModelIndex(), row, row);
	setProperty(image->getId().toStdString().c_str(), QVariant::fromValue(image.get()));
	
	mData.insert(image->getId(), QVariant::fromValue(image.get()));
	mList << image;
	
	endInsertRows();
	emit layoutChanged();
}

bool ImageListModel::removeRow (int row, const QModelIndex &parent){
	return removeRows(row, 1, parent);
}

bool ImageListModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
	if (row < 0 || count < 0 || limit >= mList.count())
		return false;
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i)
		mList.takeAt(row);
	
	endRemoveRows();
	return true;
}

void ImageListModel::useConfig (const std::shared_ptr<linphone::Config> &config) {
  #if LINPHONE_FRIDAY
    if (!isLinphoneFriday())
      overrideImages(config);
  #else
    overrideImages(config);
  #endif // if LINPHONE_FRIDAY
}

QString ImageListModel::getIds(){
	QStringList ids;
	const QMetaObject *info = metaObject();

  for (int i = info->propertyOffset(); i < info->propertyCount(); ++i) {
		const QMetaProperty metaProperty = info->property(i);
		const std::string id = metaProperty.name();
		ids << QString::fromStdString(id);
    }
    return ids.join(", ");
}

QQmlPropertyMap * ImageListModel::getQmlData() {
	return &mData;
}

const QQmlPropertyMap * ImageListModel::getQmlData() const{
	return &mData;
}

ImageModel * ImageListModel::getImageModel(const QString& id){
	for(auto image : mList)
		if(image->getId() == id)
			return image.get();
	return nullptr;	
}


void ImageListModel::overrideImages (const std::shared_ptr<linphone::Config> &config) {
  if (!config)
    return;
	for(auto image : mList){
		QString id = image->getId();
		const std::string pathValue = config->getString(ImagesSection, id.toStdString(), "");
		if(!pathValue.empty()){
			image->setPath(QString::fromStdString(pathValue));
		}
	}
}
