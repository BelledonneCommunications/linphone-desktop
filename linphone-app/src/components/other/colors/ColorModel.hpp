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

#ifndef COLOR_MODEL_H
#define COLOR_MODEL_H

// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>
#include <QColor>

#include "utils/LinphoneEnums.hpp"

class ColorModel : public QObject {
    Q_OBJECT

public:
typedef enum{
		CONTEXT_FROMLINK = -1,
		CONTEXT_NORMAL = 0,
		CONTEXT_HOVERED,// More darker
		CONTEXT_PRESSED,// More lighter
		CONTEXT_DEACTIVATED// Alpha
	}ContextMode;
    ColorModel (const QString& name, const QColor& color, const QColor& originColor, const QString& description, const ContextMode& context, QObject * parent = nullptr);
	
	Q_PROPERTY(QColor color READ getColor WRITE setColor NOTIFY colorChanged)
	Q_PROPERTY(QString description MEMBER mDescription WRITE setDescription NOTIFY descriptionChanged)
	Q_PROPERTY(QString name MEMBER mName CONSTANT)
	Q_PROPERTY(int linkIndex MEMBER mLinkIndex WRITE setLinkIndex NOTIFY linkIndexChanged)
  
	QColor getColor() const;
	QColor getColor(const ContextMode& context) const;
	QColor getOriginColor() const;
	QString getDescription() const;
	QString getName() const;
	int getLinkIndex() const;
	ContextMode getContext() const;
	Q_INVOKABLE QString toString(){return getName();}
	QString getLinkedToImage() const;
	
	void setColor(const QColor& color);
	void setOriginColor(const QColor& color, const bool& emitEvents = true);
	void setAlpha(const int& alpha);
	void setDescription(const QString& description);
	void setLinkIndex(const int& index);
	void setLinkedToImage(const QString& id);
	void setContext(const ContextMode& context);
	void updateContext();
	void updateContextFromColor();
	
signals:
	void colorChanged();
	void uiColorChanged(const QString& id, const QColor& color);	// UI request a change
	void descriptionChanged();
	void linkIndexChanged();

private:
	QString mName;
	QColor mColor;
	QColor mOriginColor;
	double mAlphaFactor = -1.0;
	QString mDescription;
	QString mLinkedToImage;
	int mLinkIndex = -1;
	ContextMode mContextMode = CONTEXT_NORMAL;
};

Q_DECLARE_METATYPE(QSharedPointer<ColorModel>);

#endif
