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

// =============================================================================

using namespace std;

QString ChatRoomProxyModel::gCachedText;

// Fetch the L last filtered chat entries.
class ChatRoomProxyModel::ChatRoomModelFilter : public QSortFilterProxyModel {
public:
  ChatRoomModelFilter (QObject *parent) : QSortFilterProxyModel(parent) {}

  ChatRoomModel::EntryType getEntryTypeFilter () {
    return mEntryTypeFilter;
  }

  void setEntryTypeFilter (ChatRoomModel::EntryType type) {
    mEntryTypeFilter = type;
    invalidate();
  }

protected:
  bool filterAcceptsRow (int sourceRow, const QModelIndex &) const override {
    if (mEntryTypeFilter == ChatRoomModel::EntryType::GenericEntry)
      return true;

    QModelIndex index = sourceModel()->index(sourceRow, 0, QModelIndex());
    const QVariantMap data = index.data().toMap();

    return data["type"].toInt() == mEntryTypeFilter;
  }

private:
  ChatRoomModel::EntryType mEntryTypeFilter = ChatRoomModel::EntryType::GenericEntry;
};

// =============================================================================

ChatRoomProxyModel::ChatRoomProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(new ChatRoomModelFilter(this));
  mIsSecure = false;

  App *app = App::getInstance();
  QObject::connect(app->getMainWindow(), &QWindow::activeChanged, this, [this]() {
    handleIsActiveChanged(App::getInstance()->getMainWindow());
  });

  QQuickWindow *callsWindow = app->getCallsWindow();
  if (callsWindow)
    QObject::connect(callsWindow, &QWindow::activeChanged, this, [this, callsWindow]() {
      handleIsActiveChanged(callsWindow);
    });
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

CREATE_PARENT_MODEL_FUNCTION(removeAllEntries);

CREATE_PARENT_MODEL_FUNCTION_WITH_PARAM(sendFileMessage, const QString &);
CREATE_PARENT_MODEL_FUNCTION_WITH_PARAM(sendMessage, const QString &);

CREATE_PARENT_MODEL_FUNCTION_WITH_ID(downloadFile);
CREATE_PARENT_MODEL_FUNCTION_WITH_ID(openFile);
CREATE_PARENT_MODEL_FUNCTION_WITH_ID(openFileDirectory);
CREATE_PARENT_MODEL_FUNCTION_WITH_ID(removeEntry);
CREATE_PARENT_MODEL_FUNCTION_WITH_ID(resendMessage);

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

void ChatRoomProxyModel::setEntryTypeFilter (ChatRoomModel::EntryType type) {
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

// -----------------------------------------------------------------------------

QString ChatRoomProxyModel::getPeerAddress () const {
  return mChatRoomModel ? mChatRoomModel->getPeerAddress() : QString("");
}

void ChatRoomProxyModel::setPeerAddress (const QString &peerAddress) {
  mPeerAddress = peerAddress;
  //reload();
}

QString ChatRoomProxyModel::getLocalAddress () const {
  return mChatRoomModel ? mChatRoomModel->getLocalAddress() : QString("");
}

void ChatRoomProxyModel::setLocalAddress (const QString &localAddress) {
  mLocalAddress = localAddress;
  //reload();
}

QString ChatRoomProxyModel::getFullPeerAddress () const {
  return mChatRoomModel ? mChatRoomModel->getFullPeerAddress() : QString("");
}

void ChatRoomProxyModel::setFullPeerAddress (const QString &peerAddress) {
  mFullPeerAddress = peerAddress;
  //reload();
}

QString ChatRoomProxyModel::getFullLocalAddress () const {
  return mChatRoomModel ? mChatRoomModel->getFullLocalAddress() : QString("");
}

void ChatRoomProxyModel::setFullLocalAddress (const QString &localAddress) {
  mFullLocalAddress = localAddress;
  //reload();
}

int ChatRoomProxyModel::getIsSecure () const {
  return mChatRoomModel ? mChatRoomModel->getIsSecure() : -1;
}

void ChatRoomProxyModel::setIsSecure (const int &secure) {
  mIsSecure = secure;
}

bool ChatRoomProxyModel::getIsRemoteComposing () const {
  return mChatRoomModel ? mChatRoomModel->getIsRemoteComposing() : false;
}

QString ChatRoomProxyModel::getCachedText() const{
  return gCachedText;
}

// -----------------------------------------------------------------------------

void ChatRoomProxyModel::reload () {
  mMaxDisplayedEntries = EntriesChunkSize;

  if (mChatRoomModel) {
    ChatRoomModel *ChatRoomModel = mChatRoomModel.get();
    QObject::disconnect(ChatRoomModel, &ChatRoomModel::isRemoteComposingChanged, this, &ChatRoomProxyModel::handleIsRemoteComposingChanged);
    QObject::disconnect(ChatRoomModel, &ChatRoomModel::messageReceived, this, &ChatRoomProxyModel::handleMessageReceived);
    QObject::disconnect(ChatRoomModel, &ChatRoomModel::messageSent, this, &ChatRoomProxyModel::handleMessageSent);
  }

  //mChatRoomModel = CoreManager::getInstance()->getChatRoomModel(mPeerAddress, mLocalAddress, mIsSecure);
  //if(mChatRoom)
		mChatRoomModel = CoreManager::getInstance()->getChatRoomModel(mChatRoom);
  

  if (mChatRoomModel) {

    ChatRoomModel *ChatRoomModel = mChatRoomModel.get();
    QObject::connect(ChatRoomModel, &ChatRoomModel::isRemoteComposingChanged, this, &ChatRoomProxyModel::handleIsRemoteComposingChanged);
    QObject::connect(ChatRoomModel, &ChatRoomModel::messageReceived, this, &ChatRoomProxyModel::handleMessageReceived);
    QObject::connect(ChatRoomModel, &ChatRoomModel::messageSent, this, &ChatRoomProxyModel::handleMessageSent);
  }

  static_cast<ChatRoomModelFilter *>(sourceModel())->setSourceModel(mChatRoomModel.get());
}
void ChatRoomProxyModel::resetMessageCount(){
	if( mChatRoomModel){
		mChatRoomModel->resetMessageCount();
	}
}

ChatRoomModel *ChatRoomProxyModel::getChatRoomModel () const{
	return mChatRoomModel.get();
	
}
void ChatRoomProxyModel::setChatRoomModel (ChatRoomModel *ChatRoomModel){
	mChatRoom = ChatRoomModel->getChatRoom();
	reload();
	emit chatRoomModelChanged();
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

void ChatRoomProxyModel::handleIsRemoteComposingChanged (bool status) {
  emit isRemoteComposingChanged(status);
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
