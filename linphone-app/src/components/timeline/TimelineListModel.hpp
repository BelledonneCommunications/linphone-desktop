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
	Q_PROPERTY(int count READ getCount NOTIFY countChanged)
    
    TimelineListModel (QObject *parent = Q_NULLPTR);
    
    void reset();
	void selectAll(const bool& selected);
	TimelineModel * getAt(const int& index);
	std::shared_ptr<TimelineModel> getTimeline(std::shared_ptr<linphone::ChatRoom> chatRoom, const bool &create);
	Q_INVOKABLE QVariantList getLastChatRooms(const int& maxCount) const;
	std::shared_ptr<ChatRoomModel> getChatRoomModel(std::shared_ptr<linphone::ChatRoom> chatRoom, const bool &create);
	std::shared_ptr<ChatRoomModel> getChatRoomModel(ChatRoomModel * chatRoom);
	int getCount() const;
  
	int rowCount (const QModelIndex &index = QModelIndex()) const override;
  
	QHash<int, QByteArray> roleNames () const override;
	QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;
  
	void add (std::shared_ptr<TimelineModel> timeline);	// Use to add a timeline that is not in Linphone list (like empty chat rooms that were hide by configuration)
// Remove a chatroom
	Q_INVOKABLE void remove (TimelineModel *importer);
	void remove(std::shared_ptr<TimelineModel> model);
	int mSelectedCount;
	
	bool mAutoSelectAfterCreation = false;// Request to select the next chat room after creation
	
	void setSelectedCount(int selectedCount);
public slots:
	void update();
	void removeChatRoomModel(std::shared_ptr<ChatRoomModel> model);
	void onSelectedHasChanged(bool selected);
	void onChatRoomStateChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,linphone::ChatRoom::State state);
	void onCallStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::Call::State state) ;
	void onCallCreated(const std::shared_ptr<linphone::Call> &call);
	//void onConferenceLeft();
	
	
	
signals:
	void countChanged();
	void selectedCountChanged(int selectedCount);
	void selectedChanged(TimelineModel * timelineModel);
	void updated();

private:
	bool removeRow (int row, const QModelIndex &parent = QModelIndex());
	bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;
	
	void updateTimelines();

	QList<std::shared_ptr<TimelineModel>> mTimelines;
};

#endif // TIMELINE_LIST_MODEL_H_
