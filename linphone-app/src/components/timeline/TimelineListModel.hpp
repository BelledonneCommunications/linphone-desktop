/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
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
#include <QSharedPointer>

#include "app/proxyModel/ProxyListModel.hpp"
#include "components/chat-room/ChatRoomModel.hpp"


class TimelineModel;
// =============================================================================

class TimelineListModel : public ProxyListModel {
  Q_OBJECT
public:
	
	Q_PROPERTY(int selectedCount MEMBER mSelectedCount WRITE setSelectedCount NOTIFY selectedCountChanged)
	Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    
    TimelineListModel (QObject *parent = Q_NULLPTR);
    TimelineListModel(const TimelineListModel* model);
    virtual ~TimelineListModel();
    TimelineListModel * clone() const;
    void reset();
	void selectAll(const bool& selected);
	TimelineModel * getAt(const int& index);
	QSharedPointer<TimelineModel> getTimeline(std::shared_ptr<linphone::ChatRoom> chatRoom, const bool &create);
	Q_INVOKABLE QVariantList getLastChatRooms(const int& maxCount) const;
	QSharedPointer<ChatRoomModel> getChatRoomModel(std::shared_ptr<linphone::ChatRoom> chatRoom, const bool &create);
	QSharedPointer<ChatRoomModel> getChatRoomModel(ChatRoomModel * chatRoom);
  
	void add (QSharedPointer<TimelineModel> timeline);	// Use to add a timeline that is not in Linphone list (like empty chat rooms that were hide by configuration)
	void add (QList<QSharedPointer<TimelineModel>> timelines);

	Q_INVOKABLE void select(ChatRoomModel * chatRoomModel);
	void setSelectedCount(int selectedCount);
	
	int mSelectedCount;
	bool mAutoSelectAfterCreation = false;// Request to select the next chat room after creation
	
public slots:
	void update();
	void removeChatRoomModel(QSharedPointer<ChatRoomModel> model);
	void onSelectedHasChanged(bool selected);
	void onChatRoomRead(const std::shared_ptr<linphone::ChatRoom> &chatRoom);
	void onChatRoomStateChanged(const std::shared_ptr<linphone::ChatRoom> &chatRoom,linphone::ChatRoom::State state);
	void onCallStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::Call::State state) ;
	void onCallCreated(const std::shared_ptr<linphone::Call> &call);
	void onTimelineDeleted();
	void onTimelineDataChanged();
	
signals:
	void countChanged();
	void selectedCountChanged(int selectedCount);
	void selectedChanged(TimelineModel * timelineModel);

private:
	virtual bool removeRows (int row, int count, const QModelIndex &parent) override;
	
	void updateTimelines();
};

#endif // TIMELINE_LIST_MODEL_H_
