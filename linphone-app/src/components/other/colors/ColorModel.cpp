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
#include "ColorModel.hpp"

#include <QQmlApplicationEngine>
#include "app/App.hpp"

#include "utils/Utils.hpp"

#include "components/Components.hpp"
#include "components/core/CoreManager.hpp"

// =============================================================================

ColorModel::ColorModel (const QString& name, const QColor& color, const QColor& originColor, const QString& description, const ContextMode& context, QObject * parent) : QObject(parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mName = name;
	mContextMode = context;
	if( color.isValid() && originColor.isValid()){
		mColor = color;
		mOriginColor = originColor;
		if(mColor.alpha() != mOriginColor.alpha() && mOriginColor.alpha() > 0)
			mAlphaFactor = mColor.alpha() / (double)mOriginColor.alpha();
	}else if( color.isValid())
		setColor(color);
	else
		setOriginColor(originColor);
	setDescription(description);
}

// -----------------------------------------------------------------------------

QString ColorModel::getName() const{
	return mName;
}

QColor ColorModel::getColor() const{
	return mColor;
}

QColor ColorModel::getColor(const ContextMode& context) const{
	QColor color = mOriginColor;
	if(mAlphaFactor>0)
		color.setAlpha(std::min(255.0, mOriginColor.alpha() * mAlphaFactor));
	switch(context){
	case CONTEXT_FROMLINK : case CONTEXT_NORMAL : break;
	case CONTEXT_PRESSED: color = color.lighter(140); break;
	case CONTEXT_HOVERED: color = color.darker(140); break;
	case CONTEXT_DEACTIVATED: color.setAlpha(60);break;
	}
	return color;
}

QColor ColorModel::getOriginColor() const{
	return mOriginColor;
}
QString ColorModel::getDescription() const{
	return mDescription;
}
QString ColorModel::getLinkedToImage() const{
	return mLinkedToImage;
}
int ColorModel::getLinkIndex() const{
	return mLinkIndex;
}

ColorModel::ContextMode ColorModel::getContext() const{
	return mContextMode;
}

void ColorModel::setColor(const QColor& color){
	if(color != mColor){
		if(mAlphaFactor>=0 && mColor.isValid() && mOriginColor.isValid() && color.alpha() != mColor.alpha() && mOriginColor.alpha() != 0)
			mAlphaFactor = color.alpha() / (double)mOriginColor.alpha();
		mColor = color;
		updateContextFromColor();
		emit colorChanged();
		emit uiColorChanged(mName, mOriginColor);
	}
}


void ColorModel::setOriginColor(const QColor& color, const bool& emitEvents){
	if(color != mOriginColor){
		mOriginColor = color;
		updateContext();
		if(emitEvents)
			emit uiColorChanged(mName, mOriginColor);
	}
}

void ColorModel::setAlpha(const int& alpha){
	if(mOriginColor.alpha()>0)
		mAlphaFactor = alpha / (double)mOriginColor.alpha();
	mColor.setAlpha(alpha);
	emit colorChanged();
}

void ColorModel::setDescription(const QString& description){
	if(description != mDescription){
		mDescription = description;
		emit descriptionChanged();
	}
}

void ColorModel::setLinkedToImage(const QString& id){
	mLinkedToImage = id;
}
void ColorModel::setLinkIndex(const int& index){
	if(index != mLinkIndex){
		mLinkIndex = index;
		emit linkIndexChanged();
	}
}

void ColorModel::setContext(const ContextMode& context){
	mContextMode = context;
	updateContext();
}

void ColorModel::updateContext(){
	//auto backup = mColor.alpha();
	mColor = getColor(mContextMode);
	emit colorChanged();
}

void ColorModel::updateContextFromColor(){
	auto backup = mOriginColor.alpha();
	mOriginColor = mColor;
	if(mAlphaFactor>0)
		mOriginColor.setAlpha(std::min(255.0, mColor.alpha() / mAlphaFactor));
	switch(mContextMode){
	case CONTEXT_FROMLINK : case CONTEXT_NORMAL : break;
	case CONTEXT_PRESSED: mOriginColor = mOriginColor.darker(140); break;
	case CONTEXT_HOVERED: mOriginColor = mOriginColor.lighter(140); break;
	case CONTEXT_DEACTIVATED: mOriginColor.setAlpha(backup);break;
	}
}