/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#include "EventLogList.hpp"
#include "ChatMessageCore.hpp"
#include "ChatMessageGui.hpp"
#include "EventLogGui.hpp"
#include "core/App.hpp"
#include "core/call-history/CallHistoryGui.hpp"
#include "core/chat/ChatCore.hpp"
#include "core/chat/ChatGui.hpp"
#include "model/chat/message/EventLogModel.hpp"
#include <QSharedPointer>
#include <linphone++/linphone.hh>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(EventLogList)

QSharedPointer<EventLogList> EventLogList::create() {
	auto model = QSharedPointer<EventLogList>(new EventLogList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

EventLogList::EventLogList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

EventLogList::~EventLogList() {
	mustBeInMainThread("~" + getClassName());
}

ChatGui *EventLogList::getChat() const {
	if (mChatCore) return new ChatGui(mChatCore);
	else return nullptr;
}

QSharedPointer<ChatCore> EventLogList::getChatCore() const {
	return mChatCore;
}

void EventLogList::disconnectItem(const QSharedPointer<EventLogCore> &item) {
	auto message = item->getChatMessageCore();
	if (message) {
		disconnect(message.get(), &ChatMessageCore::isReadChanged, this, nullptr);
		disconnect(message.get(), &ChatMessageCore::deleted, this, nullptr);
		disconnect(message.get(), &ChatMessageCore::ephemeralDurationChanged, this, nullptr);
	}
}

void EventLogList::connectItem(const QSharedPointer<EventLogCore> &item) {
	auto message = item->getChatMessageCore();
	if (message) {
		connect(message.get(), &ChatMessageCore::isReadChanged, this, [this] {
			if (mChatCore) emit mChatCore->lUpdateUnreadCount();
		});
		connect(message.get(), &ChatMessageCore::deleted, this, [this, item] {
			if (mChatCore) emit mChatCore->lUpdateLastMessage();
			remove(item);
		});
	}
}

void EventLogList::setChatCore(QSharedPointer<ChatCore> core) {
	auto updateChatCore = [this](QSharedPointer<ChatCore> core) {
		if (mChatCore != core) {
			if (mChatCore) {
				disconnect(mChatCore.get(), &ChatCore::eventsInserted, this, nullptr);
				disconnect(mChatCore.get(), &ChatCore::eventListCleared, this, nullptr);
			}
			mChatCore = core;
			if (mChatCore) {
				connect(mChatCore.get(), &ChatCore::eventListCleared, this, [this] { resetData(); });
				connect(mChatCore.get(), &ChatCore::eventsInserted, this,
				        [this](QList<QSharedPointer<EventLogCore>> list) {
					        auto eventsList = getSharedList<EventLogCore>();
					        for (auto &event : list) {
						        auto it = std::find_if(
						            eventsList.begin(), eventsList.end(),
						            [event](const QSharedPointer<EventLogCore> item) { return item == event; });
						        if (it == eventsList.end()) {
							        connectItem(event);
							        add(event);
							        int index;
							        get(event.get(), &index);
							        emit eventInserted(index, new EventLogGui(event));
						        }
					        }
				        });
			}
			lUpdate();
			emit chatGuiChanged();
		}
	};
	if (mIsUpdating) {
		connect(this, &EventLogList::isUpdatingChanged, this, [this, core, updateChatCore] {
			if (!mIsUpdating) {
				updateChatCore(core);
				disconnect(this, &EventLogList::isUpdatingChanged, this, nullptr);
			}
		});
	} else {
		updateChatCore(core);
	}
}

void EventLogList::setChatGui(ChatGui *chat) {
	auto chatCore = chat ? chat->mCore : nullptr;
	setChatCore(chatCore);
}

void EventLogList::setDisplayItemsStep(int displayItemsStep) {
	if (mDisplayItemsStep != displayItemsStep) {
		mDisplayItemsStep = displayItemsStep;
		emit displayItemsStepChanged();
	}
}

void EventLogList::displayMore() {
	auto loadMoreItems = [this] {
		if (!mChatCore) return;
		auto chatModel = mChatCore->getModel();
		if (!chatModel) return;
		mCoreModelConnection->invokeToModel([this, chatModel]() {
			mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
			int maxSize = chatModel->getHistorySizeEvents();
			int totalItemsCount = mList.count();
			auto newCount = std::min(totalItemsCount + mDisplayItemsStep, maxSize);
			if (newCount <= totalItemsCount) {
				return;
			}
			auto linphoneLogs = chatModel->getHistoryRange(totalItemsCount, newCount);
			QList<QSharedPointer<EventLogCore>> *events = new QList<QSharedPointer<EventLogCore>>();
			for (auto it : linphoneLogs) {
				auto model = EventLogCore::create(it);
				events->push_back(model);
			}
			mCoreModelConnection->invokeToCore([this, events] {
				int currentCount = mList.count();
				for (auto it = events->end() - 1; it >= events->begin(); --it) {
					connectItem(*it);
					prepend(*it);
				}
			});
		});
	};
	if (mIsUpdating) {
		connect(this, &EventLogList::isUpdatingChanged, this, [this, loadMoreItems] {
			if (!mIsUpdating) {
				disconnect(this, &EventLogList::isUpdatingChanged, this, nullptr);
				loadMoreItems();
			}
		});
		return;
	} else loadMoreItems();
}

void EventLogList::loadMessagesUpTo(std::shared_ptr<linphone::EventLog> event) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto oldestEventLoaded = getAt<EventLogCore>(0);
	auto linOldest = std::const_pointer_cast<linphone::EventLog>(oldestEventLoaded->getModel()->getEventLog());
	auto chatModel = mChatCore->getModel();
	assert(chatModel);
	if (!chatModel) return;
	int filters = static_cast<int>(linphone::ChatRoom::HistoryFilter::ChatMessage) |
	              static_cast<int>(linphone::ChatRoom::HistoryFilter::InfoNoDevice);
	auto beforeEvents = chatModel->getHistoryRangeNear(mItemsToLoadBeforeSearchResult, 0, event, filters);
	auto linphoneLogs = chatModel->getHistoryRangeBetween(event, linOldest, filters);
	QList<QSharedPointer<EventLogCore>> *events = new QList<QSharedPointer<EventLogCore>>();
	for (auto it : beforeEvents) {
		auto model = EventLogCore::create(it);
		events->push_back(model);
	}
	for (auto it : linphoneLogs) {
		auto model = EventLogCore::create(it);
		events->push_back(model);
	}
	mCoreModelConnection->invokeToCore([this, events, event] {
		for (auto &e : *events) {
			connectItem(e);
			add(e);
		}
		emit messagesLoadedUpTo(event);
	});
}

int EventLogList::findFirstUnreadIndex() {
	auto eventList = getSharedList<EventLogCore>();
	auto it = std::find_if(eventList.begin(), eventList.end(), [](const QSharedPointer<EventLogCore> item) {
		return item->getChatMessageCore() && !item->getChatMessageCore()->isRead();
	});
	return it == eventList.end() ? -1 : std::distance(eventList.begin(), it);
}

void EventLogList::findChatMessageWithFilter(QString filter,
                                             QSharedPointer<EventLogCore> startEvent,
                                             bool forward,
                                             bool isFirstResearch) {
	if (mChatCore) {
		if (isFirstResearch) mLastFoundResult.reset();
		auto chatModel = mChatCore->getModel();
		auto startEventModel = startEvent ? startEvent->getModel() : nullptr;
		mCoreModelConnection->invokeToModel([this, chatModel, startEventModel, filter, forward, isFirstResearch] {
			auto linStartEvent = startEventModel ? startEventModel->getEventLog() : nullptr;
			auto eventLog = chatModel->searchMessageByText(filter, linStartEvent, forward);
			if (!eventLog)
				// event not found, search in the entire history
				auto eventLog = chatModel->searchMessageByText(filter, nullptr, forward);
			int index = -1;
			if (eventLog) {
				auto eventList = getSharedList<EventLogCore>();
				auto it = std::find_if(eventList.begin(), eventList.end(),
				                       [eventLog](const QSharedPointer<EventLogCore> item) {
					                       return item->getModel()->getEventLog() == eventLog;
				                       });
				if (it != eventList.end()) {
					int index = std::distance(eventList.begin(), it);
					if (mLastFoundResult && mLastFoundResult == *it) index = -1;
					mLastFoundResult = *it;
					mCoreModelConnection->invokeToCore([this, index] { emit messageWithFilterFound(index); });
				} else {
					connect(this, &EventLogList::messagesLoadedUpTo, this,
					        [this](std::shared_ptr<linphone::EventLog> event) {
						        auto eventList = getSharedList<EventLogCore>();
						        auto it = std::find_if(eventList.begin(), eventList.end(),
						                               [event](const QSharedPointer<EventLogCore> item) {
							                               return item->getModel()->getEventLog() == event;
						                               });
						        int index = it != eventList.end() ? std::distance(eventList.begin(), it) : -1;
						        if (mLastFoundResult && mLastFoundResult == *it) index = -1;
						        mLastFoundResult = *it;
						        mCoreModelConnection->invokeToCore(
						            [this, index] { emit messageWithFilterFound(index); });
					        });
					loadMessagesUpTo(eventLog);
				}
			} else {
				mCoreModelConnection->invokeToCore([this, index] { emit messageWithFilterFound(index); });
			}
		});
	}
}

void EventLogList::setSelf(QSharedPointer<EventLogList> me) {
	mCoreModelConnection = SafeConnection<EventLogList, CoreModel>::create(me, CoreModel::getInstance());

	mCoreModelConnection->makeConnectToCore(&EventLogList::lUpdate, [this]() {
		mustBeInMainThread(log().arg(Q_FUNC_INFO));
		if (mIsUpdating) {
			connect(this, &EventLogList::isUpdatingChanged, this, [this] {
				if (!mIsUpdating) {
					disconnect(this, &EventLogList::isUpdatingChanged, this, nullptr);
					lUpdate();
				}
			});
			return;
		}
		setIsUpdating(true);
		beginResetModel();
		mList.clear();
		if (!mChatCore) {
			endResetModel();
			setIsUpdating(false);
			return;
		}
		auto chatModel = mChatCore->getModel();
		if (!chatModel) {
			endResetModel();
			setIsUpdating(false);
			return;
		}
		mCoreModelConnection->invokeToModel([this, chatModel]() {
			mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
			auto linphoneLogs = chatModel->getHistoryRange(0, mDisplayItemsStep);
			QList<QSharedPointer<EventLogCore>> *events = new QList<QSharedPointer<EventLogCore>>();
			for (auto it : linphoneLogs) {
				auto model = EventLogCore::create(it);
				events->push_back(model);
			}
			mCoreModelConnection->invokeToCore([this, events] {
				for (auto &event : getSharedList<EventLogCore>()) {
					auto message = event->getChatMessageCore();
					if (message) {
						disconnect(message.get(), &ChatMessageCore::ephemeralDurationChanged, this, nullptr);
						disconnect(message.get(), &ChatMessageCore::deleted, this, nullptr);
					}
				}
				for (auto &event : *events) {
					connectItem(event);
					mList.append(event);
				}
				endResetModel();
				setIsUpdating(false);
			});
		});
	});

	connect(this, &EventLogList::filterChanged, [this](QString filter) {
		mFilter = filter;
		lUpdate();
	});
	lUpdate();
}

QVariant EventLogList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();

	auto core = mList[row].objectCast<EventLogCore>();
	if (core->getChatMessageCore()) {
		switch (role) {
			case Qt::DisplayRole:
				return QVariant::fromValue(new EventLogGui(core));
			case Qt::DisplayRole + 1:
				return "chatMessage";
		}
	} else if (core->getCallHistoryCore()) {
		switch (role) {
			case Qt::DisplayRole:
				return QVariant::fromValue(new EventLogGui(core));
			case Qt::DisplayRole + 1:
				return "callLog";
		}
	} else if (core->isEphemeralRelated()) {
		switch (role) {
			case Qt::DisplayRole:
				return QVariant::fromValue(new EventLogGui(core));
			case Qt::DisplayRole + 1:
				return "ephemeralEvent";
		}
	} else {
		switch (role) {
			case Qt::DisplayRole:
				return QVariant::fromValue(new EventLogGui(core));
			case Qt::DisplayRole + 1:
				return "event";
		}
	}
	return QVariant();
}

QHash<int, QByteArray> EventLogList::roleNames() const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "modelData";
	roles[Qt::DisplayRole + 1] = "eventType";
	return roles;
}
