/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#ifndef TIMELINE_PROXY_MODEL_H_
#define TIMELINE_PROXY_MODEL_H_

#include <QSortFilterProxyModel>
// =============================================================================

#include "../chat-room/ChatRoomModel.hpp"

class TimelineModel;

class TimelineProxyModel : public QSortFilterProxyModel {
	Q_OBJECT
	
	
public:
	enum TimelineFilter {
		SecureChatRoom = 1,
		GroupChatRoom = 2,
		AllChatRooms = 0
	};
	Q_ENUM(TimelineFilter)
	
	enum TimelineMode {
		Chats,
		Calls
	};
	Q_ENUM(TimelineMode)
	
		enum TimelineListSource{
		Undefined, 
		Main,	// Timeline list comes from the singleton stored in CoreManager.
		Copy	// Timeline list is created from Main but have no attach to the main list (aside of root items).
	};
	Q_ENUM(TimelineListSource)
	
	TimelineProxyModel (QObject *parent = Q_NULLPTR);
	
	Q_PROPERTY(TimelineListSource listSource READ getListSource WRITE setListSource NOTIFY listSourceChanged)
	
	Q_PROPERTY(int filterFlags MEMBER mFilterFlags WRITE setFilterFlags NOTIFY filterFlagsChanged)
	Q_PROPERTY(QString filterText MEMBER mFilterText WRITE setFilterText NOTIFY filterTextChanged)
	Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
	Q_PROPERTY(TimelineMode mode MEMBER mMode WRITE setMode NOTIFY modeChanged)
		
	Q_INVOKABLE void unselectAll();
	Q_INVOKABLE void setFilterFlags(const int& filterFlags);
	Q_INVOKABLE void setFilterText(const QString& text);
	Q_INVOKABLE void setMode(const TimelineMode& mode);
	
	TimelineListSource getListSource() const;
	void setListSource(const TimelineListSource& source);
	
signals:
	void countChanged();
	void selectedCountChanged(int selectedCount);
	void selectedChanged(TimelineModel * timelineModel);
	void filterFlagsChanged();
	void filterTextChanged();
	void listSourceChanged();
	void modeChanged();
	
protected:
	
	bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
	bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;
	
	QString getLocalAddress () const;
	QString getCleanedLocalAddress () const;
	void handleLocalAddressChanged (const QString &localAddress);
	
private:
	int mFilterFlags = 0;
	QString mFilterText;
	TimelineMode mMode = Chats;
	TimelineListSource mListSource = Undefined;
};

#endif // TIMELINE_PROXY_MODEL_H_
