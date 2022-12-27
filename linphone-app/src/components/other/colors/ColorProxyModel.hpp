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

#ifndef COLOR_PROXY_MODEL_H_
#define COLOR_PROXY_MODEL_H_


#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>
#include <QSortFilterProxyModel>

class ColorModel;
class ColorListModel;
class ChatMessageModel;

class ColorProxyModel : public QSortFilterProxyModel {
	Q_OBJECT
	
public:
	ColorProxyModel (QObject *parent = nullptr);
	
	Q_PROPERTY(QString sortDescription READ getSortDescription NOTIFY sortChanged)
	Q_PROPERTY(int showPageIndex READ getShowPageIndex WRITE setShowPageIndex NOTIFY showPageIndexChanged)
	Q_PROPERTY(bool showAll READ getShowAll WRITE setShowAll NOTIFY showAllChanged)
	
	Q_INVOKABLE void updateLink(const QString& id, const QString& newLink);
	Q_INVOKABLE void viewLinks(const QString& id);
	Q_INVOKABLE void changeSort();
	Q_INVOKABLE void filterText(const QString& text);
	
	void resetColors();
	void addColor(ColorModel * colorModel);
	
	QString getSortDescription() const;
	
	int getShowPageIndex()const;
	void setShowPageIndex(const int& index);
	
	bool getShowAll()const;
	void setShowAll(const bool& showAll);
	
signals:
	void sortChanged();
	void showPageIndexChanged();
	void showAllChanged();
	
protected:
	virtual bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
	virtual bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;
	
private:
	int mSortMode;
	int mShowPageIndex = 0;
	bool mShowAll = true;
	int mLinksIndex = -1;
	QString mFilterText;
	QList<QSharedPointer<QObject>> mColors;
};

#endif
