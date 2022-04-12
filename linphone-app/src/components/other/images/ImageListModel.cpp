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

ImageListModel::ImageListModel ( QObject *parent) : ProxyListModel(parent), mData(this) {
// Get all internals
	QString path = ":/assets/images/";
	QStringList filters;
	filters << "*.svg";
	
	QFileInfoList  files = QDir(path).entryInfoList(filters, QDir::Files , QDir::Name);
	for(QFileInfo file : files){
		QSharedPointer<ImageModel> model = QSharedPointer<ImageModel>::create(file.completeBaseName(), path+file.fileName(), "");
		add(model);
	}
	mData.insert("areReadOnlyImages", QVariant::fromValue(true));
}

void ImageListModel::add(QSharedPointer<ImageModel> image){
	setProperty(image->getId().toStdString().c_str(), QVariant::fromValue(image.get()));
	mData.insert(image->getId(), QVariant::fromValue(image.get()));
	
	ProxyListModel::add(image);
	
	emit layoutChanged();
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
	for(auto item : mList) {
		auto image = item.objectCast<ImageModel>();
		if(image->getId() == id)
			return image.get();
	}
	return nullptr;	
}


void ImageListModel::overrideImages (const std::shared_ptr<linphone::Config> &config) {
  if (!config)
    return;
	for(auto item : mList){
		auto image = item.objectCast<ImageModel>();
		QString id = image->getId();
		const std::string pathValue = config->getString(ImagesSection, id.toStdString(), "");
		if(!pathValue.empty()){
			image->setPath(QString::fromStdString(pathValue));
		}
	}
}
