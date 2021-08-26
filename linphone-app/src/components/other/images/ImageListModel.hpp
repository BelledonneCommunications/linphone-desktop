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
#include <QAbstractListModel>
#include <memory> 
#include <QQmlPropertyMap>

#include "ImageModel.hpp"
	
class ImageModel;

class ImageListModel : public QAbstractListModel {
	Q_OBJECT
public:
	
	ImageListModel (QObject *parent = nullptr);
	
	int rowCount (const QModelIndex &index = QModelIndex()) const override;
	
	virtual QHash<int, QByteArray> roleNames () const override;
	virtual QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;
	
	void useConfig (const std::shared_ptr<linphone::Config> &config);
	
	Q_INVOKABLE QString getIds();
	
	QQmlPropertyMap * getQmlData();
	const QQmlPropertyMap * getQmlData() const;
	
	ImageModel * getImageModel(const QString& id);
				
private:
	void add(std::shared_ptr<ImageModel> imdn);
	bool removeRow (int row, const QModelIndex &parent = QModelIndex());
	virtual bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;
	
	QList<std::shared_ptr<ImageModel>> mList;
	
	void overrideImages (const std::shared_ptr<linphone::Config> &config);
	
	QStringList getImagesIds () const;
	
	QQmlPropertyMap mData;
	bool mAreReadOnlyImages = true;
	
};
Q_DECLARE_METATYPE(std::shared_ptr<ImageListModel>)

#endif 
