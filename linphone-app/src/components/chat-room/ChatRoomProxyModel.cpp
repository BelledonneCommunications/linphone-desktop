/*
 * Copyright (c) 2010-2022 Belledonne Communications SARL.
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
#include <QTimer>

#include "app/App.hpp"
#include "components/core/CoreManager.hpp"

#include "ChatRoomProxyModel.hpp"
#include "components/chat-events/ChatEvent.hpp"
#include "components/chat-events/ChatMessageModel.hpp"
#include "components/chat-events/ChatNoticeModel.hpp"
#include "components/chat-events/ChatCallModel.hpp"
#include "components/timeline/TimelineListModel.hpp"
#include "components/timeline/TimelineModel.hpp"

// =============================================================================

using namespace std;

// =============================================================================

ChatRoomProxyModel::ChatRoomProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
	mMarkAsReadEnabled = true;
	
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

ChatRoomProxyModel::~ChatRoomProxyModel(){
	setChatRoomModel(nullptr);	// Do remove process like setting haveCall if is Call.
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
		GET_CHAT_MODEL()->METHOD( \
		mapFromSource(static_cast<ChatRoomModel*>(sourceModel())->index(id, 0)).row() \
		); \
	}

CREATE_PARENT_MODEL_FUNCTION(removeAllEntries)

CREATE_PARENT_MODEL_FUNCTION_WITH_PARAM(sendMessage, const QString &)
CREATE_PARENT_MODEL_FUNCTION_WITH_PARAM(forwardMessage, ChatMessageModel *)

CREATE_PARENT_MODEL_FUNCTION_WITH_ID(removeRow)

CREATE_PARENT_MODEL_FUNCTION(deleteChatRoom)

#undef GET_CHAT_MODEL
#undef CREATE_PARENT_MODEL_FUNCTION
#undef CREATE_PARENT_MODEL_FUNCTION_WITH_PARAM
#undef CREATE_PARENT_MODEL_FUNCTION_WITH_ID


void ChatRoomProxyModel::compose (const QString& text) {
	if (mChatRoomModel)
		mChatRoomModel->compose(text);
}

int ChatRoomProxyModel::getEntryTypeFilter () {
	return mEntryTypeFilter;
}

// -----------------------------------------------------------------------------

void ChatRoomProxyModel::loadMoreEntriesAsync(){
	QTimer::singleShot(10, this, &ChatRoomProxyModel::loadMoreEntries);
}

void ChatRoomProxyModel::onMoreEntriesLoaded(const int& count){
	emit moreEntriesLoaded(count);
}
void ChatRoomProxyModel::loadMoreEntries() {
	if(mChatRoomModel ) {
		mChatRoomModel->loadMoreEntries();
	}
}

void ChatRoomProxyModel::setEntryTypeFilter (int type) {
	if (getEntryTypeFilter() != type) {
		mEntryTypeFilter = type;
		invalidate();
		emit entryTypeFilterChanged(type);
	}
}

// -----------------------------------------------------------------------------

bool ChatRoomProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
	bool show = false;

	if (mEntryTypeFilter == ChatRoomModel::EntryType::GenericEntry)
		show = true;
	else{
		QModelIndex index = sourceModel()->index(sourceRow, 0, QModelIndex());
		auto eventModel = sourceModel()->data(index);
		
		if( mEntryTypeFilter == ChatRoomModel::EntryType::CallEntry && eventModel.value<ChatCallModel*>() != nullptr)
			show = true;
		else if( mEntryTypeFilter == ChatRoomModel::EntryType::MessageEntry && eventModel.value<ChatMessageModel*>() != nullptr)
			show = true;
		else if( mEntryTypeFilter == ChatRoomModel::EntryType::NoticeEntry && eventModel.value<ChatNoticeModel*>() != nullptr)
			show = true;
	}
	if( show && mFilterText != ""){
		QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
		auto eventModel = sourceModel()->data(index);
		ChatMessageModel * chatModel = eventModel.value<ChatMessageModel*>();
		if( chatModel){
			QRegularExpression search(QRegularExpression::escape(mFilterText), QRegularExpression::CaseInsensitiveOption | QRegularExpression::UseUnicodePropertiesOption);
			show = chatModel->mContent.contains(search);
		}
	}
	return show;
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
	if(!b)
		return true;
	if(!a)
		return false;
	return a->getTimestamp() < b->getTimestamp();
}
// -----------------------------------------------------------------------------

QString ChatRoomProxyModel::getPeerAddress () const {
	return mChatRoomModel ? mChatRoomModel->getPeerAddress() : mPeerAddress;
}

void ChatRoomProxyModel::setPeerAddress (const QString &peerAddress) {
	mPeerAddress = peerAddress;
	emit peerAddressChanged(mPeerAddress);
}

QString ChatRoomProxyModel::getLocalAddress () const {
	return mChatRoomModel ? mChatRoomModel->getLocalAddress() : mLocalAddress;
}

void ChatRoomProxyModel::setLocalAddress (const QString &localAddress) {
	mLocalAddress = localAddress;
	emit localAddressChanged(mLocalAddress);
}

QString ChatRoomProxyModel::getFullPeerAddress () const {
	return mChatRoomModel ? mChatRoomModel->getFullPeerAddress() : mFullPeerAddress;
}

void ChatRoomProxyModel::setFullPeerAddress (const QString &peerAddress) {
	mFullPeerAddress = peerAddress;
	emit fullPeerAddressChanged(mFullPeerAddress);
}

QString ChatRoomProxyModel::getFullLocalAddress () const {
	return mChatRoomModel ? mChatRoomModel->getFullLocalAddress() : mFullLocalAddress;
}

void ChatRoomProxyModel::setFullLocalAddress (const QString &localAddress) {
	mFullLocalAddress = localAddress;
	emit fullLocalAddressChanged(mFullLocalAddress);
}

bool ChatRoomProxyModel::markAsReadEnabled() const{
	return (mChatRoomModel ? mChatRoomModel->markAsReadEnabled() : false);
}

void ChatRoomProxyModel::enableMarkAsRead(const bool& enable){
	if(mChatRoomModel)
		mChatRoomModel->enableMarkAsRead(enable);
}

QList<QString> ChatRoomProxyModel::getComposers() const{
	return (mChatRoomModel?mChatRoomModel->getComposers():QList<QString>());
}

QString ChatRoomProxyModel::getDisplayNameComposers()const{
	return getComposers().join(", ");
}

QVariant ChatRoomProxyModel::getAt(int row){
	QModelIndex sourceIndex = mapToSource(this->index(row, 0));
	return sourceModel()->data(sourceIndex);
}

void ChatRoomProxyModel::setIsCall(const bool& isCall){
	if(mIsCall != isCall) {
		if(mChatRoomModel){
			if(isCall){
				mChatRoomModel->addBindingCall();
			}else
				mChatRoomModel->removeBindingCall();
		}
		mIsCall = isCall;
		emit isCallChanged();
	}
}

// -----------------------------------------------------------------------------

void ChatRoomProxyModel::reload (ChatRoomModel *chatRoomModel) {
	if(chatRoomModel != mChatRoomModel.get()) {
		if (mChatRoomModel) {
			ChatRoomModel *ChatRoomModel = mChatRoomModel.get();
			QObject::disconnect(ChatRoomModel, &ChatRoomModel::isRemoteComposingChanged, this, &ChatRoomProxyModel::handleIsRemoteComposingChanged);
			QObject::disconnect(ChatRoomModel, &ChatRoomModel::messageReceived, this, &ChatRoomProxyModel::handleMessageReceived);
			QObject::disconnect(ChatRoomModel, &ChatRoomModel::messageSent, this, &ChatRoomProxyModel::handleMessageSent);
			QObject::disconnect(ChatRoomModel, &ChatRoomModel::markAsReadEnabledChanged, this, &ChatRoomProxyModel::markAsReadEnabledChanged);
			QObject::disconnect(ChatRoomModel, &ChatRoomModel::moreEntriesLoaded, this, &ChatRoomProxyModel::onMoreEntriesLoaded);
			QObject::disconnect(ChatRoomModel, &ChatRoomModel::chatRoomDeleted, this, &ChatRoomProxyModel::chatRoomDeleted);
			if(mIsCall)
				mChatRoomModel->removeBindingCall();
		}
		if( mIsCall && chatRoomModel){
			chatRoomModel->addBindingCall();
		}
		
		mChatRoomModel = CoreManager::getInstance()->getTimelineListModel()->getChatRoomModel(chatRoomModel);
		setSourceModel(mChatRoomModel.get());
		if (mChatRoomModel) {
			
			ChatRoomModel *ChatRoomModel = mChatRoomModel.get();
			QObject::connect(ChatRoomModel, &ChatRoomModel::isRemoteComposingChanged, this, &ChatRoomProxyModel::handleIsRemoteComposingChanged);
			QObject::connect(ChatRoomModel, &ChatRoomModel::messageReceived, this, &ChatRoomProxyModel::handleMessageReceived);
			QObject::connect(ChatRoomModel, &ChatRoomModel::messageSent, this, &ChatRoomProxyModel::handleMessageSent);		
			QObject::connect(ChatRoomModel, &ChatRoomModel::markAsReadEnabledChanged, this, &ChatRoomProxyModel::markAsReadEnabledChanged);
			QObject::connect(ChatRoomModel, &ChatRoomModel::moreEntriesLoaded, this, &ChatRoomProxyModel::onMoreEntriesLoaded);
			QObject::connect(ChatRoomModel, &ChatRoomModel::chatRoomDeleted, this, &ChatRoomProxyModel::chatRoomDeleted);
			mChatRoomModel->initEntries();// This way, we don't load huge chat rooms (that lead to freeze GUI)
		}
	}
}

void ChatRoomProxyModel::resetMessageCount(){
	if( mChatRoomModel){
		mChatRoomModel->resetMessageCount();
	}
}

void ChatRoomProxyModel::setFilterText(const QString& text){
	if( mFilterText != text && mChatRoomModel){
		mFilterText = text;
		int currentRowCount = rowCount();
		int newEntries = 0;
		do{
			newEntries = mChatRoomModel->loadMoreEntries();
			invalidate();
			emit filterTextChanged();
		}while( newEntries>0 && currentRowCount == rowCount());
	}
}

int ChatRoomProxyModel::loadTillMessage(ChatMessageModel * message){
	int messageIndex = mChatRoomModel->loadTillMessage(message);
	if( messageIndex>= 0 ) {
		messageIndex = mapFromSource(static_cast<ChatRoomModel*>(sourceModel())->index(messageIndex, 0)).row();
	}
	qDebug() << "Message index from chat room proxy : " << messageIndex;
	return messageIndex;
}

ChatRoomModel *ChatRoomProxyModel::getChatRoomModel () const{
	return mChatRoomModel.get();
	
}

void ChatRoomProxyModel::setChatRoomModel (ChatRoomModel *chatRoomModel){
	if(chatRoomModel){
		reload(chatRoomModel);
		emit chatRoomModelChanged();
		emit isRemoteComposingChanged();
	}else{
		if(mIsCall && mChatRoomModel)
			mChatRoomModel->removeBindingCall();
			mChatRoomModel = nullptr;
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

void ChatRoomProxyModel::handleIsActiveChanged (QWindow *window) {
	if (markAsReadEnabled() && mChatRoomModel && window->isActive() && getParentWindow(this) == window) {
		auto timeline = CoreManager::getInstance()->getTimelineListModel()->getTimeline(mChatRoomModel->getChatRoom(), false);
		if(timeline && timeline->mSelected){
			mChatRoomModel->resetMessageCount();
			mChatRoomModel->focused();
		}
	}
}

void ChatRoomProxyModel::handleIsRemoteComposingChanged () {
	emit isRemoteComposingChanged();
}

void ChatRoomProxyModel::handleMessageReceived (const shared_ptr<linphone::ChatMessage> &message) {
	
	QWindow *window = getParentWindow(this);
	if (mChatRoomModel){
		if(window && window->isActive())
			mChatRoomModel->resetMessageCount();
	}
}

void ChatRoomProxyModel::handleMessageSent (const shared_ptr<linphone::ChatMessage> &) {
}
