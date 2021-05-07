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

#ifndef TIMELINE_LIST_MODEL_H_
#define TIMELINE_LIST_MODEL_H_

#include <QSortFilterProxyModel>
#include "components/chat-room/ChatRoomModel.hpp"

class TimelineModel;
// =============================================================================

class TimelineListModel : public QAbstractListModel {
  Q_OBJECT
public:
	
	Q_PROPERTY(int selectedCount MEMBER mSelectedCount WRITE setSelectedCount NOTIFY selectedCountChanged)
    
    TimelineListModel (QObject *parent = Q_NULLPTR);
    
    void reset();
	void update();
	void selectAll(const bool& selected);
	TimelineModel * getAt(const int& index);
	std::shared_ptr<TimelineModel> getTimeline(std::shared_ptr<linphone::ChatRoom> chatRoom, const bool &create);
  
	int rowCount (const QModelIndex &index = QModelIndex()) const override;
  
	QHash<int, QByteArray> roleNames () const override;
	QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;
  
// Remove a chatroom
	Q_INVOKABLE void remove (TimelineModel *importer);
	int mSelectedCount;
	
	void setSelectedCount(int selectedCount);
public slots:
	void selectedHasChanged(bool selected);
	
signals:
	void selectedCountChanged(int selectedCount);

private:
	bool removeRow (int row, const QModelIndex &parent = QModelIndex());
	bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;
	
	
	
	void initTimeline ();
	void updateTimelines();

	QList<std::shared_ptr<TimelineModel>> mTimelines;
};

#endif // TIMELINE_LIST_MODEL_H_
