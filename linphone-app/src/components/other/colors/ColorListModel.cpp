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
	initKeywords();
	init();	
}

void ColorListModel::initKeywords(){
	mKeywordsMap["s"] = "standard";
	mKeywordsMap["ma"] = "main";
	mKeywordsMap["l"] = "list";
	mKeywordsMap["sc"] = "screen";
	mKeywordsMap["me"] = "menu";
	
	mKeywordsMap["n"] = "normal";
	mKeywordsMap["d"] = "disabled";
	mKeywordsMap["h"] = "hovered";
	mKeywordsMap["p"] = "pressed";
	mKeywordsMap["u"] = "updating";
	mKeywordsMap["c"] = "checked";
	
	mKeywordsMap["b"] = "button";
	
	mKeywordsMap["inv"] = "inverse";
	
	mKeywordsMap["bg"] = "background";
	mKeywordsMap["fg"] = "foreground";
}

int ColorListModel::rowCount (const QModelIndex &index) const{
	return mList.count();
}

QHash<int, QByteArray> ColorListModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$color";
	roles[Qt::UserRole] = "id";
	roles[Qt::UserRole+1] = "modelData";
	return roles;
}

QVariant ColorListModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mList.count())
		return QVariant();
	
	if (role >= Qt::UserRole)
		return mList[row]->getName();
	return QVariant::fromValue(mList[row].get());
	
	//return QVariant();
}

ColorModel *ColorListModel::getAt(const int& index){
	return mList[index].get();
}

void ColorListModel::add(std::shared_ptr<ColorModel> color){
	int row = mList.count();
	
	connect(color.get(), &ColorModel::uiColorChanged, this, &ColorListModel::handleUiColorChanged);
	
	beginInsertRows(QModelIndex(), row, row);
	setProperty(color->getName().toStdString().c_str(), QVariant::fromValue(color.get()));
	
	
	
	mData.insert(color->getName(), QVariant::fromValue(color.get()));
	mList << color;
	
	endInsertRows();
	emit layoutChanged();
}

ColorModel * ColorListModel::add(const QString& id, const QString& idLink, QString description, QString colorValue){
	ColorModel * color = getColor(id);
	if(!color){
		if(idLink != ""){
			if( colorValue == ""){
				auto linkColor = getColor(idLink);
				if(linkColor){
					colorValue = linkColor->getColor().name(QColor::HexArgb);
				}
			}
			addLink(id, idLink);
		}
		if( description == ""){
			description = id;
			QStringList tokens = description.split('_');
			for(int index = 0 ; index < tokens.size() ; ++index)
				if(mKeywordsMap.contains(tokens[index]))
					tokens[index] = mKeywordsMap[tokens[index]];
			description = tokens.join(' ');
			description[0] = description[0].toUpper();
		}
		auto colorShared = std::make_shared<ColorModel>(id, colorValue, description);
		add(colorShared);
		color = colorShared.get();
		emit colorChanged();
	}
	return color;
}

ColorModel * ColorListModel::addImageColor(const QString& id, const QString& imageId, const QString& idLink, QString description, QString color){
	ColorModel * model = add(id, idLink, description, color);
	model->setLinkedToImage(imageId);
	imageLinks[imageId].push_back(model);
	return model;
}

void ColorListModel::addLink(const QString& a, const QString& b){
	int index = 0;
	if( mColorLinkIndexes.contains(b)){
		index = mColorLinkIndexes[b];
	}else {
		index = mColorLinks.size();
		mColorLinks.push_back(QStringList(b));
		mColorLinkIndexes[b] = index;
	}
	mColorLinks[index].push_back(a);
	mColorLinkIndexes[a] = index;
}

void ColorListModel::removeLink(const QString& a){
	mColorLinks[mColorLinkIndexes[a]].removeOne(a);
	mColorLinkIndexes.remove(a);
}

void ColorListModel::updateLink(const QString& id, const QString& newLink){
	removeLink(id);
	if( newLink != "" ){
		addLink(id, newLink);
		ColorModel * linkModel = getColor(newLink);
		ColorModel * idModel = getColor(id);
		idModel->setColor(linkModel->getColor());
	}
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

ColorModel * ColorListModel::getColor(const QString& id){
	if(mData.contains(id)){
		return mData[id].value<ColorModel*>();
	}else
		return nullptr;
}

QVector<QStringList> ColorListModel::getColorIdLinks(){
	return mColorLinks;
}

QQmlPropertyMap * ColorListModel::getQmlData() {
	return &mData;
}

const QQmlPropertyMap * ColorListModel::getQmlData() const{
	return &mData;
}

int ColorListModel::getLinkIndex(const QString& id){
	if( mColorLinkIndexes.contains(id))
		return  mColorLinkIndexes[id];
	else
		return -1;
}

void ColorListModel::overrideColors (const std::shared_ptr<linphone::Config> &colorsConfig) {
	if (!colorsConfig)
		return;
	std::list<std::string> colorsIds = colorsConfig->getKeysNamesList(ColorsSection);
	for(auto configId : colorsIds){
		if(configId == "ColorLinks"){
			std::list<std::string> colorString = colorsConfig->getStringList(ColorsSection, configId, std::list<std::string>());
			QVector<QStringList> colorLinks;
			QMap<QString, int> colorLinksIndexes;
			for(auto color : colorString){
				QStringList pair = QString::fromStdString(color).split(";");
				if(pair.size()  == 2){
					QString id = pair.front();
					int index = pair.back().toInt();
					colorLinksIndexes[id] = index;					
					colorLinks.resize(index+1);
					colorLinks[index].append(id);
				}
			}
			mColorLinks = colorLinks;
			mColorLinkIndexes = colorLinksIndexes;
		}else{
			bool haveColor = false;
			QString qtConfigId = QString::fromStdString(configId);
			QString colorName = QString::fromStdString(colorsConfig->getString(ColorsSection, configId, ""));
			for(auto color : mList){
				QString name = color->getName();
				if( name == qtConfigId) {
					color->setColor(QColor(colorName));
					haveColor = true;
				}
			}
			if(!haveColor){
				add(qtConfigId, "", "Added from Configuration", colorName);
			}
		}
	}  
	
	/*
	for(auto color : mList){
		QString name = color->getName();
		const std::string colorValue = config->getString(ColorsSection, name.toStdString(), "");
		if(!colorValue.empty()){
			color->setColor(QColor(QString::fromStdString(colorValue)));
		}
	}*/
}

std::shared_ptr<linphone::Config> ColorListModel::getConfigColors(const QString filename){
	std::shared_ptr<linphone::Config> config = linphone::Factory::get()->createConfig(filename.toStdString());
// Colors links
	std::list<std::string> links;
	for(auto link = mColorLinkIndexes.begin() ; link != mColorLinkIndexes.end() ; ++link) {
		links.push_back((link.key()+";"+QString::number(link.value())).toStdString());
	}
	config->setStringList(ColorsSection, "ColorLinks", links);
	for(auto color : mList){
		config->setString(ColorsSection, color->getName().toStdString(), color->getColor().name(QColor::HexArgb).toStdString());
	}
	return config;
}

void ColorListModel::handleUiColorChanged(const QString& id, const QColor& color){
	if( mColorLinkIndexes.contains(id)){
		int index = mColorLinkIndexes[id];
		for(int i = 0 ; i < mColorLinks[index].size() ; ++i){
			auto colorToUpdate = getColor(mColorLinks[index][i]);
			if(colorToUpdate)
				colorToUpdate->setInternalColor(color);
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