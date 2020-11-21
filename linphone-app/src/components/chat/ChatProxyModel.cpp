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

#include "ChatProxyModel.hpp"

// =============================================================================

using namespace std;

QString ChatProxyModel::gCachedText;

// Fetch the L last filtered chat entries.
class ChatProxyModel::ChatModelFilter : public QSortFilterProxyModel {
public:
  ChatModelFilter (QObject *parent) : QSortFilterProxyModel(parent) {}

  ChatModel::EntryType getEntryTypeFilter () {
    return mEntryTypeFilter;
  }

  void setEntryTypeFilter (ChatModel::EntryType type) {
    mEntryTypeFilter = type;
    invalidate();
  }

protected:
  bool filterAcceptsRow (int sourceRow, const QModelIndex &) const override {
    if (mEntryTypeFilter == ChatModel::EntryType::GenericEntry)
      return true;

    QModelIndex index = sourceModel()->index(sourceRow, 0, QModelIndex());
    const QVariantMap data = index.data().toMap();

    return data["type"].toInt() == mEntryTypeFilter;
  }

private:
  ChatModel::EntryType mEntryTypeFilter = ChatModel::EntryType::GenericEntry;
};

// =============================================================================

ChatProxyModel::ChatProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(new ChatModelFilter(this));

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
  if (!mChatModel) \
    return; \
  mChatModel

#define CREATE_PARENT_MODEL_FUNCTION(METHOD) \
  void ChatProxyModel::METHOD () { \
    GET_CHAT_MODEL()->METHOD(); \
  }

#define CREATE_PARENT_MODEL_FUNCTION_WITH_PARAM(METHOD, ARG_TYPE) \
  void ChatProxyModel::METHOD (ARG_TYPE value) { \
    GET_CHAT_MODEL()->METHOD(value); \
  }

#define CREATE_PARENT_MODEL_FUNCTION_WITH_ID(METHOD) \
  void ChatProxyModel::METHOD (int id) { \
    QModelIndex sourceIndex = mapToSource(index(id, 0)); \
    GET_CHAT_MODEL()->METHOD( \
      static_cast<ChatModelFilter *>(sourceModel())->mapToSource(sourceIndex).row() \
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


void ChatProxyModel::compose (const QString& text) {
  if (mChatModel)
    mChatModel->compose();
  gCachedText = text;
}

// -----------------------------------------------------------------------------

void ChatProxyModel::loadMoreEntries () {
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

void ChatProxyModel::setEntryTypeFilter (ChatModel::EntryType type) {
  ChatModelFilter *chatModelFilter = static_cast<ChatModelFilter *>(sourceModel());

  if (chatModelFilter->getEntryTypeFilter() != type) {
    chatModelFilter->setEntryTypeFilter(type);
    emit entryTypeFilterChanged(type);
  }
}

// -----------------------------------------------------------------------------

bool ChatProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &) const {
  return sourceModel()->rowCount() - sourceRow <= mMaxDisplayedEntries;
}

// -----------------------------------------------------------------------------

QString ChatProxyModel::getPeerAddress () const {
  return mChatModel ? mChatModel->getPeerAddress() : QString("");
}

void ChatProxyModel::setPeerAddress (const QString &peerAddress) {
  mPeerAddress = peerAddress;
  reload();
}

QString ChatProxyModel::getLocalAddress () const {
  return mChatModel ? mChatModel->getLocalAddress() : QString("");
}

void ChatProxyModel::setLocalAddress (const QString &localAddress) {
  mLocalAddress = localAddress;
  reload();
}

QString ChatProxyModel::getFullPeerAddress () const {
  return mChatModel ? mChatModel->getFullPeerAddress() : QString("");
}

void ChatProxyModel::setFullPeerAddress (const QString &peerAddress) {
  mFullPeerAddress = peerAddress;
  //reload();
}

QString ChatProxyModel::getFullLocalAddress () const {
  return mChatModel ? mChatModel->getFullLocalAddress() : QString("");
}

void ChatProxyModel::setFullLocalAddress (const QString &localAddress) {
  mFullLocalAddress = localAddress;
  //reload();
}

bool ChatProxyModel::getIsRemoteComposing () const {
  return mChatModel ? mChatModel->getIsRemoteComposing() : false;
}

QString ChatProxyModel::getCachedText() const{
  return gCachedText;
}

// -----------------------------------------------------------------------------

void ChatProxyModel::reload () {
  mMaxDisplayedEntries = EntriesChunkSize;

  if (mChatModel) {
    ChatModel *chatModel = mChatModel.get();
    QObject::disconnect(chatModel, &ChatModel::isRemoteComposingChanged, this, &ChatProxyModel::handleIsRemoteComposingChanged);
    QObject::disconnect(chatModel, &ChatModel::messageReceived, this, &ChatProxyModel::handleMessageReceived);
    QObject::disconnect(chatModel, &ChatModel::messageSent, this, &ChatProxyModel::handleMessageSent);
  }

  mChatModel = CoreManager::getInstance()->getChatModel(mPeerAddress, mLocalAddress);

  if (mChatModel) {

    ChatModel *chatModel = mChatModel.get();
    QObject::connect(chatModel, &ChatModel::isRemoteComposingChanged, this, &ChatProxyModel::handleIsRemoteComposingChanged);
    QObject::connect(chatModel, &ChatModel::messageReceived, this, &ChatProxyModel::handleMessageReceived);
    QObject::connect(chatModel, &ChatModel::messageSent, this, &ChatProxyModel::handleMessageSent);
  }

  static_cast<ChatModelFilter *>(sourceModel())->setSourceModel(mChatModel.get());
}
void ChatProxyModel::resetMessageCount(){
	if( mChatModel){
		mChatModel->resetMessageCount();
	}
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

void ChatProxyModel::handleIsActiveChanged (QWindow *window) {
  if (mChatModel && window->isActive() && getParentWindow(this) == window) {
    mChatModel->resetMessageCount();
    mChatModel->focused();
  }
}

void ChatProxyModel::handleIsRemoteComposingChanged (bool status) {
  emit isRemoteComposingChanged(status);
}

void ChatProxyModel::handleMessageReceived (const shared_ptr<linphone::ChatMessage> &) {
  mMaxDisplayedEntries++;

  QWindow *window = getParentWindow(this);
  if (window && window->isActive())
    mChatModel->resetMessageCount();
}

void ChatProxyModel::handleMessageSent (const shared_ptr<linphone::ChatMessage> &) {
  mMaxDisplayedEntries++;
}
