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

#include <QQuickWindow>

#include "app/App.hpp"
#include "components/core/CoreManager.hpp"

#include "ChatRoomProxyModel.hpp"
#include "components/chat-events/ChatEvent.hpp"
#include "components/chat-events/ChatMessageModel.hpp"
#include "components/chat-events/ChatNoticeModel.hpp"
#include "components/chat-events/ChatCallModel.hpp"
#include "components/timeline/TimelineListModel.hpp"

// =============================================================================

using namespace std;

QString ChatRoomProxyModel::gCachedText;

// Fetch the L last filtered chat entries.
class ChatRoomProxyModel::ChatRoomModelFilter : public QSortFilterProxyModel {
public:
  ChatRoomModelFilter (QObject *parent) : QSortFilterProxyModel(parent) {}

  int getEntryTypeFilter () {
    return mEntryTypeFilter;
  }

  void setEntryTypeFilter (int type) {
    mEntryTypeFilter = type;
    invalidate();
  }

protected:
  bool filterAcceptsRow (int sourceRow, const QModelIndex &) const override {
    if (mEntryTypeFilter == ChatRoomModel::EntryType::GenericEntry)
      return true;

    QModelIndex index = sourceModel()->index(sourceRow, 0, QModelIndex());
    const QVariantMap data = index.data().toMap();

    return (data["type"].toInt() & mEntryTypeFilter) > 0;
  }

private:
  int mEntryTypeFilter = ChatRoomModel::EntryType::GenericEntry;
};

// =============================================================================

ChatRoomProxyModel::ChatRoomProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(new ChatRoomModelFilter(this));
  //mIsSecure = false;

  App *app = App::getInstance();
  QObject::connect(app->getMainWindow(), &QWindow::activeChanged, this, [this]() {
    handleIsActiveChanged(App::getInstance()->getMainWindow());
  });

  QQuickWindow *callsWindow = app->getCallsWindow();
  if (callsWindow)
    QObject::connect(callsWindow, &QWindow::activeChanged, this, [this, callsWindow]() {
      handleIsActiveChanged(callsWindow);
    });
  sort(0);
}

// -----------------------------------------------------------------------------

#define GET_CHAT_MODEL() \
  if (!mChatRoomModel) \
    return; \
  mChatRoomModel

#define CREATE_PARENT_MODEL_FUNCTION(METHOD) \
  void ChatRoomProxyModel::METHOD () { \
    GET_CHAT_MODEL()->METHOD(); \
  }

#define CREATE_PARENT_MODEL_FUNCTION_WITH_PARAM(METHOD, ARG_TYPE) \
  void ChatRoomProxyModel::METHOD (ARG_TYPE value) { \
    GET_CHAT_MODEL()->METHOD(value); \
  }

#define CREATE_PARENT_MODEL_FUNCTION_WITH_ID(METHOD) \
  void ChatRoomProxyModel::METHOD (int id) { \
    QModelIndex sourceIndex = mapToSource(index(id, 0)); \
    GET_CHAT_MODEL()->METHOD( \
      static_cast<ChatRoomModelFilter *>(sourceModel())->mapToSource(sourceIndex).row() \
    ); \
  }

CREATE_PARENT_MODEL_FUNCTION(removeAllEntries)

CREATE_PARENT_MODEL_FUNCTION_WITH_PARAM(sendFileMessage, const QString &)
CREATE_PARENT_MODEL_FUNCTION_WITH_PARAM(sendMessage, const QString &)

CREATE_PARENT_MODEL_FUNCTION_WITH_ID(removeRow)


#undef GET_CHAT_MODEL
#undef CREATE_PARENT_MODEL_FUNCTION
#undef CREATE_PARENT_MODEL_FUNCTION_WITH_PARAM
#undef CREATE_PARENT_MODEL_FUNCTION_WITH_ID


void ChatRoomProxyModel::compose (const QString& text) {
  if (mChatRoomModel)
    mChatRoomModel->compose();
  gCachedText = text;
}

// -----------------------------------------------------------------------------

void ChatRoomProxyModel::loadMoreEntries () {
  int count = rowCount();
  int parentCount = sourceModel()->rowCount();

  if (count < parentCount) {
    // Do not increase `mMaxDisplayedEntries` if it's not necessary...
    // Limit qml calls.
    if (count == mMaxDisplayedEntries)
      mMaxDisplayedEntries += EntriesChunkSize;

    invalidateFilter();

    count = rowCount() - count;
    if (count > 0)
      emit moreEntriesLoaded(count);
  }
}

void ChatRoomProxyModel::setEntryTypeFilter (int type) {
  ChatRoomModelFilter *ChatRoomModelFilter = static_cast<ChatRoomProxyModel::ChatRoomModelFilter *>(sourceModel());

  if (ChatRoomModelFilter->getEntryTypeFilter() != type) {
    ChatRoomModelFilter->setEntryTypeFilter(type);
    emit entryTypeFilterChanged(type);
  }
}

// -----------------------------------------------------------------------------

bool ChatRoomProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &) const {
  return sourceModel()->rowCount() - sourceRow <= mMaxDisplayedEntries;
}
bool ChatRoomProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
	auto l = sourceModel()->data(left);
	auto r = sourceModel()->data(right);
	
	ChatEvent * a = l.value<ChatMessageModel*>();// l.value<ChatEvent*>() cannot be used
	if(!a)
		a = l.value<ChatNoticeModel*>();
	if(!a)
		a = l.value<ChatCallModel*>();
	ChatEvent * b = r.value<ChatMessageModel*>();
	if(!b)
		b = r.value<ChatNoticeModel*>();
	if(!b)
		b = r.value<ChatCallModel*>();
	
	return a->mTimestamp < b->mTimestamp;
}
// -----------------------------------------------------------------------------

QString ChatRoomProxyModel::getPeerAddress () const {
  return mChatRoomModel ? mChatRoomModel->getPeerAddress() : mPeerAddress;//QString("");
}

void ChatRoomProxyModel::setPeerAddress (const QString &peerAddress) {
  mPeerAddress = peerAddress;
  emit peerAddressChanged(mPeerAddress);
  //reload();
}

QString ChatRoomProxyModel::getLocalAddress () const {
  return mChatRoomModel ? mChatRoomModel->getLocalAddress() : mLocalAddress;//QString("");
}

void ChatRoomProxyModel::setLocalAddress (const QString &localAddress) {
  mLocalAddress = localAddress;
  emit localAddressChanged(mLocalAddress);
  //reload();
}

QString ChatRoomProxyModel::getFullPeerAddress () const {
  return mChatRoomModel ? mChatRoomModel->getFullPeerAddress() : mFullPeerAddress;//QString("");
}

void ChatRoomProxyModel::setFullPeerAddress (const QString &peerAddress) {
  mFullPeerAddress = peerAddress;
  emit fullPeerAddressChanged(mFullPeerAddress);
  //reload();
}

QString ChatRoomProxyModel::getFullLocalAddress () const {
  return mChatRoomModel ? mChatRoomModel->getFullLocalAddress() : mFullLocalAddress;//QString("");
}

void ChatRoomProxyModel::setFullLocalAddress (const QString &localAddress) {
  mFullLocalAddress = localAddress;
  emit fullLocalAddressChanged(mFullLocalAddress);
  //reload();
}
/*
bool ChatRoomProxyModel::isSecure () const {
  return mChatRoomModel ? mChatRoomModel->isSecure() : false;
}

void ChatRoomProxyModel::setIsSecure (const int &secure) {
  mIsSecure = secure;
  emit isSecureChanged(mIsSecure);
}
*/

/*
bool ChatRoomProxyModel::getIsRemoteComposing () const {
  return mChatRoomModel ? mChatRoomModel->getIsRemoteComposing() : false;
}*/

QList<QString> ChatRoomProxyModel::getComposers() const{
	return (mChatRoomModel?mChatRoomModel->getComposers():QList<QString>());
}

QString ChatRoomProxyModel::getDisplayNameComposers()const{
	return getComposers().join(", ");
}

QString ChatRoomProxyModel::getCachedText() const{
  return gCachedText;
}

// -----------------------------------------------------------------------------

void ChatRoomProxyModel::reload (ChatRoomModel *chatRoomModel) {
  mMaxDisplayedEntries = EntriesChunkSize;

  if (mChatRoomModel) {
    ChatRoomModel *ChatRoomModel = mChatRoomModel.get();
    QObject::disconnect(ChatRoomModel, &ChatRoomModel::isRemoteComposingChanged, this, &ChatRoomProxyModel::handleIsRemoteComposingChanged);
    QObject::disconnect(ChatRoomModel, &ChatRoomModel::messageReceived, this, &ChatRoomProxyModel::handleMessageReceived);
    QObject::disconnect(ChatRoomModel, &ChatRoomModel::messageSent, this, &ChatRoomProxyModel::handleMessageSent);
  }

  //mChatRoomModel = CoreManager::getInstance()->getChatRoomModel(mPeerAddress, mLocalAddress, mIsSecure);
  //if(mChatRoom)
	mChatRoomModel = CoreManager::getInstance()->getTimelineListModel()->getChatRoomModel(chatRoomModel);
  
  if(!mChatRoomModel)
	qWarning() << "mChatRoomModel is null!";

  if (mChatRoomModel) {

    ChatRoomModel *ChatRoomModel = mChatRoomModel.get();
    QObject::connect(ChatRoomModel, &ChatRoomModel::isRemoteComposingChanged, this, &ChatRoomProxyModel::handleIsRemoteComposingChanged);
    QObject::connect(ChatRoomModel, &ChatRoomModel::messageReceived, this, &ChatRoomProxyModel::handleMessageReceived);
    QObject::connect(ChatRoomModel, &ChatRoomModel::messageSent, this, &ChatRoomProxyModel::handleMessageSent);
  }

  static_cast<ChatRoomModelFilter *>(sourceModel())->setSourceModel(mChatRoomModel.get());
  invalidate();
}
void ChatRoomProxyModel::resetMessageCount(){
	if( mChatRoomModel){
		mChatRoomModel->resetMessageCount();
	}
}

ChatRoomModel *ChatRoomProxyModel::getChatRoomModel () const{
	return mChatRoomModel.get();
	
}

void ChatRoomProxyModel::setChatRoomModel (ChatRoomModel *chatRoomModel){
	reload(chatRoomModel);
	emit chatRoomModelChanged();
	emit isRemoteComposingChanged();
}
// -----------------------------------------------------------------------------

static inline QWindow *getParentWindow (QObject *object) {
  App *app = App::getInstance();
  const QWindow *mainWindow = app->getMainWindow();
  const QWindow *callsWindow = app->getCallsWindow();
  for (QObject *parent = object->parent(); parent; parent = parent->parent())
    if (parent == mainWindow || parent == callsWindow)
      return static_cast<QWindow *>(parent);
  return nullptr;
}

void ChatRoomProxyModel::handleIsActiveChanged (QWindow *window) {
  if (mChatRoomModel && window->isActive() && getParentWindow(this) == window) {
    mChatRoomModel->resetMessageCount();
    mChatRoomModel->focused();
  }
}

void ChatRoomProxyModel::handleIsRemoteComposingChanged () {
  emit isRemoteComposingChanged();
}

void ChatRoomProxyModel::handleMessageReceived (const shared_ptr<linphone::ChatMessage> &) {
  mMaxDisplayedEntries++;

  QWindow *window = getParentWindow(this);
  if (window && window->isActive())
    mChatRoomModel->resetMessageCount();
}

void ChatRoomProxyModel::handleMessageSent (const shared_ptr<linphone::ChatMessage> &) {
  mMaxDisplayedEntries++;
}
