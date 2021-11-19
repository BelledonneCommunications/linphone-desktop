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

#ifndef CONTENT_PROXY_MODEL_H_
#define CONTENT_PROXY_MODEL_H_


#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>
#include <QSortFilterProxyModel>

class ContentListModel;
class ContentModel;
class ChatMessageModel;

class ContentProxyModel : public QSortFilterProxyModel {
	Q_OBJECT
	
public:
	ContentProxyModel (QObject *parent = nullptr);	
	Q_PROPERTY(ChatMessageModel * chatMessageModel WRITE setChatMessageModel NOTIFY chatMessageModelChanged)
	
	void setChatMessageModel(ChatMessageModel * message);
	
signals:
	void chatMessageModelChanged();
	
protected:
	virtual bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
	virtual bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;
	
	std::shared_ptr<ContentListModel> mContens;
	
};

#endif
