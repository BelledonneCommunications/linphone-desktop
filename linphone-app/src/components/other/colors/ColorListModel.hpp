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

#ifndef COLOR_LIST_MODEL_H_
#define COLOR_LIST_MODEL_H_

// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>
#include <QAbstractListModel>
#include <memory> 
#include <QQmlPropertyMap>

#include "ColorModel.hpp"

#define ADD_COLOR(COLOR, VALUE, DESCRIPTION) \
	color = std::make_shared<ColorModel>(COLOR, VALUE, DESCRIPTION); \
	add(color);
	
// Alpha is in percent.
#define ADD_COLOR_WITH_ALPHA(COLOR, ALPHA, DESCRIPTION) \
	color = std::make_shared<ColorModel>(COLOR + QString::number(ALPHA), mData[COLOR].value<ColorModel*>()->getColor().name(), DESCRIPTION); \
	color->setAlpha(ALPHA * 255 / 100); \
	add(color);
	
	
class ColorModel;

class ColorListModel : public QAbstractListModel {
	Q_OBJECT
	void init() {
		std::shared_ptr<ColorModel> color;
		ADD_COLOR("a", "transparent", "Generic transparent color.")
		// Primary color for hovered items.
		ADD_COLOR("b", "#D64D00", "Primary color for hovered items.")
		
		ADD_COLOR("c", "#CBCBCB", "Button pressed, separatos, fields.")
		ADD_COLOR("d", "#5A585B", "")
		ADD_COLOR("e", "#F3F3F3", "")
		ADD_COLOR("f", "#E8E8E8", "")
		ADD_COLOR("g", "#6B7A86", "SIP Address, Contact Text.")
		ADD_COLOR("h", "#687680", "")
		
		// Primary color.
		ADD_COLOR("i", "#FE5E00", "Primary color.")
		
		ADD_COLOR("j", "#4B5964", "Username, Background cancel button hovered.")
		
		// Popups, home, call, assistant and settings background.
		ADD_COLOR("k", "#FFFFFF", "Popups, home, call, assistant and settings background.")
		
		ADD_COLOR("l", "#000000", "Generic Black color")
		
		// Primary color for clicked items.
		ADD_COLOR("m", "#FF8600", "Primary color for clicked items.")
		
		ADD_COLOR("n", "#A1A1A1", "")
		ADD_COLOR("o", "#D0D8DE", "Disabled button")
		
		ADD_COLOR("p", "#17A81A", "Progress bar.")
		
		ADD_COLOR("q", "#FFFFFF", "Fields, backgrounds and text color on some items")
		
		ADD_COLOR("r", "#909fab", "Background button normal.")
		
		ADD_COLOR("s", "#96be64", "Security")
		
		ADD_COLOR("t", "#C2C2C2", "Title Header")
		ADD_COLOR("u", "#D2D2D2", "Menu border (message)")
		ADD_COLOR("v", "#E7E7E7", "Menu pressed (message)")
		ADD_COLOR("w", "#EDEDED", "Menu background (conversation)")
		
		// Field error.
		ADD_COLOR("error", "#FF0000", "Error Generic button.")
		
		ADD_COLOR_WITH_ALPHA("g", 10, "")
		ADD_COLOR_WITH_ALPHA("g", 20, "")
		ADD_COLOR_WITH_ALPHA("g", 90, "")
		ADD_COLOR_WITH_ALPHA("i", 30, "")
		ADD_COLOR_WITH_ALPHA("l", 50, "")
		ADD_COLOR_WITH_ALPHA("l", 80, "")
		ADD_COLOR_WITH_ALPHA("q", 50, "")
	}
public:
	
	ColorListModel (QObject *parent = nullptr);
	
	int rowCount (const QModelIndex &index = QModelIndex()) const override;
	
	virtual QHash<int, QByteArray> roleNames () const override;
	virtual QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;
	
	void useConfig (const std::shared_ptr<linphone::Config> &config);
	
	Q_INVOKABLE QString getNames();
	
	QQmlPropertyMap * getQmlData();
	const QQmlPropertyMap * getQmlData() const;
	

signals:
	void colorChanged();
	
private:
	void add(std::shared_ptr<ColorModel> imdn);
	bool removeRow (int row, const QModelIndex &parent = QModelIndex());
	virtual bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;
	
	QList<std::shared_ptr<ColorModel>> mList;
	
	void overrideColors (const std::shared_ptr<linphone::Config> &config);
	
	QStringList getColorNames () const;
	
	QQmlPropertyMap mData;
	
};
#undef ADD_COLOR
Q_DECLARE_METATYPE(std::shared_ptr<ColorListModel>)

#endif 
