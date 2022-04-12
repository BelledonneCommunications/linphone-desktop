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

#ifndef IMAGE_LIST_MODEL_H_
#define IMAGE_LIST_MODEL_H_

// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>
#include <QQmlPropertyMap>
#include <QSharedPointer>

#include "ImageModel.hpp"
#include "app/proxyModel/ProxyListModel.hpp"
	
class ImageModel;

class ImageListModel : public ProxyListModel {
	Q_OBJECT
public:
	
	ImageListModel (QObject *parent = nullptr);
		
	void useConfig (const std::shared_ptr<linphone::Config> &config);
	
	Q_INVOKABLE QString getIds();
	
	QQmlPropertyMap * getQmlData();
	const QQmlPropertyMap * getQmlData() const;
	
	ImageModel * getImageModel(const QString& id);
				
private:
	void add(QSharedPointer<ImageModel> imdn);
	
	void overrideImages (const std::shared_ptr<linphone::Config> &config);
	
	QStringList getImagesIds () const;
	
	QQmlPropertyMap mData;
	bool mAreReadOnlyImages = true;
	
};
Q_DECLARE_METATYPE(QSharedPointer<ImageListModel>)

#endif 
