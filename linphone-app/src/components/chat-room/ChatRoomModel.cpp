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

#include <algorithm>

#include <QDateTime>
#include <QDesktopServices>
#include <QElapsedTimer>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QTimer>
#include <QUuid>
#include <QMessageBox>
#include <QUrlQuery>
#include <QImageReader>

#include "app/App.hpp"
#include "app/paths/Paths.hpp"
#include "app/providers/ThumbnailProvider.hpp"
#include "components/contact/ContactModel.hpp"
#include "components/contact/VcardModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/notifier/Notifier.hpp"
#include "components/settings/SettingsModel.hpp"
#include "components/participant/ParticipantModel.hpp"
#include "components/presence/Presence.hpp"
#include "utils/QExifImageHeader.hpp"
#include "utils/Utils.hpp"

#include "ChatRoomModel.hpp"

// =============================================================================

using namespace std;

namespace {
  constexpr int ThumbnailImageFileWidth = 100;
  constexpr int ThumbnailImageFileHeight = 100;

  // In Bytes.
  constexpr qint64 FileSizeLimit = 524288000;
}
// MessageAppData is using to parse what's it in Appdata field of a message
class MessageAppData
{
public:
    MessageAppData(){}
    MessageAppData(const QString&);
    QString m_id;
    QString m_path;
    QString toString()const;
    void fromString(const QString& );
    static QString toString(const QVector<MessageAppData>& );
    static QVector<MessageAppData> fromListString(const QString& );
};
MessageAppData::MessageAppData(const QString& p_data)
{
    fromString(p_data);
}
QString MessageAppData::toString()const
{
    return m_id+':'+m_path;
}
void MessageAppData::fromString(const QString& p_data)
{
    QStringList fields = p_data.split(':');
    if( fields.size() > 1)
    {
        m_id = fields[0];
        m_path = fields[1];
    }
}
QString MessageAppData::toString(const QVector<MessageAppData>& p_data)
{
    QString serialization;
    if( p_data.size() > 0)
    {
        serialization = p_data[0].toString();
        for(int i = 1 ; i < p_data.size() ; ++i)
            serialization += ';'+p_data[i].toString();
    }
    return serialization;
}
QVector<MessageAppData> MessageAppData::fromListString(const QString& p_data)
{
    QVector<MessageAppData> data;
    QStringList files = p_data.split(";");
    for(int i = 0 ; i < files.size() ; ++i)
        data.push_back(MessageAppData(files[i]));
    return data;
}


// There is only one file (thumbnail) in appdata
static inline MessageAppData getMessageAppData (const shared_ptr<linphone::ChatMessage> &message) {
	return MessageAppData(Utils::coreStringToAppString(message->getAppdata()));
}

static inline bool fileWasDownloaded (const shared_ptr<linphone::ChatMessage> &message) {
  const MessageAppData appData = getMessageAppData(message);
  return !appData.m_path.isEmpty() && QFileInfo(appData.m_path).isFile();
}
// Set the thumbnail as the first content
static inline void fillThumbnailProperty (QVariantMap &dest, const shared_ptr<linphone::ChatMessage> &message) {
    if( !dest.contains("thumbnail"))
    {
        MessageAppData thumbnailData = getMessageAppData(message);
        if( thumbnailData.m_id != "")
            dest["thumbnail"] = QStringLiteral("image://%1/%2").arg(ThumbnailProvider::ProviderId).arg(thumbnailData.m_id);
    }
}

// Create a thumbnail from the first content that have a file and store it in Appdata
static inline void createThumbnail (const shared_ptr<linphone::ChatMessage> &message) {
  if (!message->getAppdata().empty())
    return;// Already exist : no need to create one
  std::list<std::shared_ptr<linphone::Content> > contents = message->getContents();
  if( contents.size() > 0)
  {
	MessageAppData thumbnailData;
	thumbnailData.m_path = Utils::coreStringToAppString(contents.front()->getFilePath());
	QImage image(thumbnailData.m_path);
	if( image.isNull()){// Try to determine format from headers
		QImageReader reader(thumbnailData.m_path);
		reader.setDecideFormatFromContent(true);
		QByteArray format = reader.format();
		if(!format.isEmpty())
			image = QImage(thumbnailData.m_path, format);
	}
	if (!image.isNull()){
		int rotation = 0;
		QExifImageHeader exifImageHeader;
		if (exifImageHeader.loadFromJpeg(thumbnailData.m_path))
			rotation = int(exifImageHeader.value(QExifImageHeader::ImageTag::Orientation).toShort());
		QImage thumbnail = image.scaled(
			ThumbnailImageFileWidth, ThumbnailImageFileHeight,
			Qt::KeepAspectRatio, Qt::SmoothTransformation
		);
	
		if (rotation != 0) {
			QTransform transform;
			if (rotation == 3 || rotation == 4)
				transform.rotate(180);
			else if (rotation == 5 || rotation == 6)
				transform.rotate(90);
			else if (rotation == 7 || rotation == 8)
				transform.rotate(-90);
			thumbnail = thumbnail.transformed(transform);
			if (rotation == 2 || rotation == 4 || rotation == 5 || rotation == 7)
				thumbnail = thumbnail.mirrored(true, false);
		}
		QString uuid = QUuid::createUuid().toString();
		thumbnailData.m_id = QStringLiteral("%1.jpg").arg(uuid.mid(1, uuid.length() - 2));
	
		if (!thumbnail.save(Utils::coreStringToAppString(Paths::getThumbnailsDirPath()) + thumbnailData.m_id , "jpg", 100)) {
			qWarning() << QStringLiteral("Unable to create thumbnail of: `%1`.").arg(thumbnailData.m_path);
		}
	}
	message->setAppdata(Utils::appStringToCoreString(thumbnailData.toString()));
  }
}

static inline void removeFileMessageThumbnail (const shared_ptr<linphone::ChatMessage> &message) {
    if (message && message->getFileTransferInformation()) {
        message->cancelFileTransfer();
        MessageAppData thumbnailFile = getMessageAppData(message);
        if(thumbnailFile.m_id.size() > 0)
        {
            QString thumbnailPath = Utils::coreStringToAppString(Paths::getThumbnailsDirPath()) + thumbnailFile.m_id;
            if (!QFile::remove(thumbnailPath))
                qWarning() << QStringLiteral("Unable to remove `%1`.").arg(thumbnailPath);
        }
        message->setAppdata("");// Remove completely Thumbnail from the message
    }
}

// -----------------------------------------------------------------------------

static inline void fillMessageEntry (QVariantMap &dest, const shared_ptr<linphone::ChatMessage> &message) {
  std::list<std::shared_ptr<linphone::Content>> contents = message->getContents();
  QString txt;
  foreach(auto content, contents){
	  if(content->isText())
		  txt += content->getStringBuffer().c_str();
  }
  dest["content"] = txt;
  dest["isOutgoing"] = message->isOutgoing() || message->getState() == linphone::ChatMessage::State::Idle;

  // Old workaround.
  // It can exist messages with a not delivered status. It's a linphone core bug.
  linphone::ChatMessage::State state = message->getState();
  if (state == linphone::ChatMessage::State::InProgress)
    dest["status"] = ChatRoomModel::MessageStatusNotDelivered;
  else
    dest["status"] = static_cast<ChatRoomModel::MessageStatus>(message->getState());	

  shared_ptr<const linphone::Content> content = message->getFileTransferInformation();
  if (content) {
    dest["fileSize"] = quint64(content->getFileSize());
    dest["fileName"] =Utils::coreStringToAppString(content->getName());
    if (state==linphone::ChatMessage::State::Displayed)
      createThumbnail(message);
     fillThumbnailProperty(dest, message);
     dest["wasDownloaded"] = ::fileWasDownloaded(message);
  }
}

static inline void fillCallStartEntry (QVariantMap &dest, const shared_ptr<linphone::CallLog> &callLog) {
  dest["type"] = ChatRoomModel::CallEntry;
  dest["timestamp"] = QDateTime::fromMSecsSinceEpoch(callLog->getStartDate() * 1000);
  dest["isOutgoing"] = callLog->getDir() == linphone::Call::Dir::Outgoing;
  dest["status"] = static_cast<ChatRoomModel::CallStatus>(callLog->getStatus());
  dest["isStart"] = true;
}

static inline void fillCallEndEntry (QVariantMap &dest, const shared_ptr<linphone::CallLog> &callLog) {
  dest["type"] = ChatRoomModel::CallEntry;
  dest["timestamp"] = QDateTime::fromMSecsSinceEpoch((callLog->getStartDate() + callLog->getDuration()) * 1000);
  dest["isOutgoing"] = callLog->getDir() == linphone::Call::Dir::Outgoing;
  dest["status"] = static_cast<ChatRoomModel::CallStatus>(callLog->getStatus());
  dest["isStart"] = false;
}

// -----------------------------------------------------------------------------

class ChatRoomModel::MessageHandlers : public linphone::ChatMessageListener {
  friend class ChatRoomModel;

public:
  MessageHandlers (ChatRoomModel *ChatRoomModel) : mChatRoomModel(ChatRoomModel) {}

private:
  QList<ChatEntryData>::iterator findMessageEntry (const shared_ptr<linphone::ChatMessage> &message) {
    return find_if(mChatRoomModel->mEntries.begin(), mChatRoomModel->mEntries.end(), [&message](const ChatEntryData &entry) {
      return entry.second == message;
    });
  }

  void signalDataChanged (const QList<ChatEntryData>::iterator &it) {
    int row = int(distance(mChatRoomModel->mEntries.begin(), it));
    emit mChatRoomModel->dataChanged(mChatRoomModel->index(row, 0), mChatRoomModel->index(row, 0));
  }

  shared_ptr<linphone::Buffer> onFileTransferSend (
    const shared_ptr<linphone::ChatMessage> &,
    const shared_ptr<linphone::Content> &,
    size_t,
    size_t
  ) override {
    qWarning() << "`onFileTransferSend` called.";
    return nullptr;
  }

  void onFileTransferProgressIndication (
    const shared_ptr<linphone::ChatMessage> &message,
    const shared_ptr<linphone::Content> &,
    size_t offset,
    size_t
  ) override {
    if (!mChatRoomModel)
      return;

    auto it = findMessageEntry(message);
    if (it == mChatRoomModel->mEntries.end())
      return;

    (*it).first["fileOffset"] = quint64(offset);

    signalDataChanged(it);
  }

  void onMsgStateChanged (const shared_ptr<linphone::ChatMessage> &message, linphone::ChatMessage::State state) override {
    if (!mChatRoomModel)
      return;

    auto it = findMessageEntry(message);
    if (it == mChatRoomModel->mEntries.end())
      return;

    // File message downloaded.
    if (state == linphone::ChatMessage::State::FileTransferDone && !message->isOutgoing()) {
      createThumbnail(message);
      fillThumbnailProperty((*it).first, message);
      (*it).first["wasDownloaded"] = true;
      App::getInstance()->getNotifier()->notifyReceivedFileMessage(message);
    }

    (*it).first["status"] = static_cast<MessageStatus>(state);

    signalDataChanged(it);
  }

  ChatRoomModel *mChatRoomModel;
};

// -----------------------------------------------------------------------------
/*
ChatRoomModel::ChatRoomModel (const QString &peerAddress, const QString &localAddress, const bool& isSecure) {
  CoreManager *coreManager = CoreManager::getInstance();

  mCoreHandlers = coreManager->getHandlers();
  mMessageHandlers = make_shared<MessageHandlers>(this);

  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::Factory> factory(linphone::Factory::get());
  std::shared_ptr<linphone::ChatRoomParams> params = core->createDefaultChatRoomParams();
  std::list<std::shared_ptr<linphone::Address>> participants;
    
  mChatRoom = core->searchChatRoom(params, factory->createAddress(localAddress.toStdString())
								   , factory->createAddress(peerAddress.toStdString())
								   , participants);
  Q_ASSERT(mChatRoom);

  handleIsComposingChanged(mChatRoom);

  // Get messages.
  mEntries.clear();

  QElapsedTimer timer;
  timer.start();

  for (auto &message : mChatRoom->getHistory(0))
    mEntries << qMakePair(
      QVariantMap{
        { "type", EntryType::MessageEntry },
        { "timestamp", QDateTime::fromMSecsSinceEpoch(message->getTime() * 1000) }
      },
      static_pointer_cast<void>(message)
    );

  // Get calls.
  if(!getIsSecure() )
	for (auto &callLog : core->getCallHistory(mChatRoom->getPeerAddress(), mChatRoom->getLocalAddress()))
	    insertCall(callLog);

  qInfo() << QStringLiteral("ChatRoomModel (%1, %2) loaded in %3 milliseconds.")
    .arg(peerAddress).arg(localAddress).arg(timer.elapsed());
  
// Rebind lost handlers
  for(auto i = mEntries.begin() ; i != mEntries.end() ; ++i){
    if(i->first["type"] == EntryType::MessageEntry){
      shared_ptr<linphone::ChatMessage> message = static_pointer_cast<linphone::ChatMessage>(i->second);
      message->removeListener(mMessageHandlers);// Remove old listener if already exists
      message->addListener(mMessageHandlers);
    }
  }
  {
    CoreHandlers *coreHandlers = mCoreHandlers.get();
    QObject::connect(coreHandlers, &CoreHandlers::messageReceived, this, &ChatRoomModel::handleMessageReceived);
    QObject::connect(coreHandlers, &CoreHandlers::callStateChanged, this, &ChatRoomModel::handleCallStateChanged);
    QObject::connect(coreHandlers, &CoreHandlers::isComposingChanged, this, &ChatRoomModel::handleIsComposingChanged);
  }
  if(!mChatRoom)
	  qWarning("TOTO A");
}
*/

ChatRoomModel::ChatRoomModel (std::shared_ptr<linphone::ChatRoom> chatRoom){
	CoreManager *coreManager = CoreManager::getInstance();
  
	mCoreHandlers = coreManager->getHandlers();
	mMessageHandlers = make_shared<MessageHandlers>(this);
  
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	shared_ptr<linphone::Factory> factory(linphone::Factory::get());
	std::shared_ptr<linphone::ChatRoomParams> params = core->createDefaultChatRoomParams();
	std::list<std::shared_ptr<linphone::Address>> participants;
	
	
	mChatRoom = chatRoom;
	
	Q_ASSERT(mChatRoom);
	
	setLastUpdateTime(QDateTime::fromMSecsSinceEpoch(chatRoom->getLastUpdateTime()));
	setUnreadMessagesCount(chatRoom->getUnreadMessagesCount());
	mMissedCallsCount = 0;
  
	//handleIsComposingChanged(mChatRoom);
  
	// Get messages.
	mEntries.clear();
  
	QElapsedTimer timer;
	timer.start();
  
	for (auto &message : mChatRoom->getHistory(0))
	  mEntries << qMakePair(
		QVariantMap{
		  { "type", EntryType::MessageEntry },
		  { "timestamp", QDateTime::fromMSecsSinceEpoch(message->getTime() * 1000) }
		},
		static_pointer_cast<void>(message)
	  );
  
	// Get calls.
	if(!getIsSecure() )
	  for (auto &callLog : core->getCallHistory(mChatRoom->getPeerAddress(), mChatRoom->getLocalAddress()))
		  insertCall(callLog);
  


	
  // Rebind lost handlers
	for(auto i = mEntries.begin() ; i != mEntries.end() ; ++i){
	  if(i->first["type"] == EntryType::MessageEntry){
		shared_ptr<linphone::ChatMessage> message = static_pointer_cast<linphone::ChatMessage>(i->second);
		message->removeListener(mMessageHandlers);// Remove old listener if already exists
		message->addListener(mMessageHandlers);
	  }
	}
	{
	  CoreHandlers *coreHandlers = mCoreHandlers.get();
	  //QObject::connect(coreHandlers, &CoreHandlers::messageReceived, this, &ChatRoomModel::handleMessageReceived);
	  QObject::connect(coreHandlers, &CoreHandlers::callCreated, this, &ChatRoomModel::handleCallCreated);
	  QObject::connect(coreHandlers, &CoreHandlers::callStateChanged, this, &ChatRoomModel::handleCallStateChanged);
	  //QObject::connect(coreHandlers, &CoreHandlers::isComposingChanged, this, &ChatRoomModel::handleIsComposingChanged);
	}
	if(mChatRoom){
		std::list<std::shared_ptr<linphone::Participant>>  participants = mChatRoom->getParticipants();
		for(auto it = participants.begin() ; it != participants.end() ; ++it){
			mParticipants << new ParticipantModel(*it, this);
		}
	}
}

ChatRoomModel::~ChatRoomModel () {
  mMessageHandlers->mChatRoomModel = nullptr;
}

QHash<int, QByteArray> ChatRoomModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Roles::ChatEntry] = "$chatEntry";
  roles[Roles::SectionDate] = "$sectionDate";
  return roles;
}

int ChatRoomModel::rowCount (const QModelIndex &) const {
  return mEntries.count();
}

QVariant ChatRoomModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (!index.isValid() || row < 0 || row >= mEntries.count())
    return QVariant();

  switch (role) {
    case Roles::ChatEntry: {
      auto &data = mEntries[row].first;
      if (data.contains("type") && data["type"]==EntryType::MessageEntry && !data.contains("content"))
        fillMessageEntry(data, static_pointer_cast<linphone::ChatMessage>(mEntries[row].second));
      return QVariant::fromValue(data);
    }
    case Roles::SectionDate:
      return QVariant::fromValue(mEntries[row].first["timestamp"].toDate());
  }

  return QVariant();
}

bool ChatRoomModel::removeRow (int row, const QModelIndex &) {
  return removeRows(row, 1);
}

bool ChatRoomModel::removeRows (int row, int count, const QModelIndex &parent) {
  int limit = row + count - 1;

  if (row < 0 || count < 0 || limit >= mEntries.count())
    return false;

  beginRemoveRows(parent, row, limit);

  for (int i = 0; i < count; ++i) {
    removeEntry(mEntries[row]);
    mEntries.removeAt(row);
  }

  endRemoveRows();

  if (mEntries.count() == 0)
    emit allEntriesRemoved();
  else if (limit == mEntries.count())
    emit lastEntryRemoved();
  emit focused();// Removing rows is like having focus. Don't wait asynchronous events.
  return true;
}

QString ChatRoomModel::getPeerAddress () const {
  return Utils::coreStringToAppString(
    mChatRoom->getPeerAddress()->asStringUriOnly()
  );
}

QString ChatRoomModel::getLocalAddress () const {
  return Utils::coreStringToAppString(
    mChatRoom->getLocalAddress()->asStringUriOnly()
  );
}
QString ChatRoomModel::getFullPeerAddress () const {
	if(!mChatRoom)
		qWarning("TOTO Z");
  return QString::fromStdString(mChatRoom->getPeerAddress()->asString());
}

QString ChatRoomModel::getFullLocalAddress () const {
  return QString::fromStdString(mChatRoom->getLocalAddress()->asString());
}

QString ChatRoomModel::getSubject () const {
  return QString::fromStdString(mChatRoom->getSubject());
}

QString ChatRoomModel::getUsername () const {
	std::string username = mChatRoom->getSubject();
	if(username != ""){
		return QString::fromStdString(username);
	}
	if( mChatRoom->getNbParticipants() == 1){
		auto participants = mChatRoom->getParticipants();	
		auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(QString::fromStdString((*participants.begin())->getAddress()->asString()));
		if(contact)
			return contact->getVcardModel()->getUsername();
	}
	username = mChatRoom->getPeerAddress()->getDisplayName();
	if(username != "")
		return QString::fromStdString(username);
	username = mChatRoom->getPeerAddress()->getUsername();
	if(username != "")
		return QString::fromStdString(username);
	return QString::fromStdString(mChatRoom->getPeerAddress()->asStringUriOnly());
}

QString ChatRoomModel::getAvatar () const {
	if( mChatRoom->getNbParticipants() == 1){
		auto participants = mChatRoom->getParticipants();	
		auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(QString::fromStdString((*participants.begin())->getAddress()->asString()));
		if(contact)
			return contact->getVcardModel()->getAvatar();
	}
	return "";
}

int ChatRoomModel::getPresenceStatus() const {
	if( mChatRoom->getNbParticipants() == 1){
		auto participants = mChatRoom->getParticipants();	
		auto contact = CoreManager::getInstance()->getContactsListModel()->findContactModelFromSipAddress(QString::fromStdString((*participants.begin())->getAddress()->asString()));
		if(contact)
			return contact->getPresenceLevel();
		else
			return 0;
	}else
		return 0;
	//return Presence::getPresenceLevel(1);
	//return mChatRoom->getConsolidatedPresence();
}

void ChatRoomModel::setLastUpdateTime(const QDateTime& lastUpdateDate) {
	if(mLastUpdateTime != lastUpdateDate ) {
		mLastUpdateTime = lastUpdateDate;
		emit lastUpdateTimeChanged();
	}	
}

void ChatRoomModel::setUnreadMessagesCount(const int& count){
	if(count != mUnreadMessagesCount){
		mUnreadMessagesCount = count;
		emit unreadMessagesCountChanged();
	}
}

void ChatRoomModel::setMissedCallsCount(const int& count){
	if(count != mMissedCallsCount){
		mMissedCallsCount = count;
		emit missedCallsCountChanged();
	}
}


void ChatRoomModel::leaveChatRoom (){
	mChatRoom->leave();
	mChatRoom->getCore()->deleteChatRoom(mChatRoom);
}
/*
void ChatRoomModel::setSipAddresses (const QString &peerAddress, const QString &localAddress, const bool& isSecure) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::Factory> factory(linphone::Factory::get());
  std::shared_ptr<linphone::ChatRoomParams> params = core->createDefaultChatRoomParams();
  std::list<std::shared_ptr<linphone::Address>> participants;
    
  mChatRoom = core->searchChatRoom(params, factory->createAddress(localAddress.toStdString())
								   , factory->createAddress(peerAddress.toStdString())
								   , participants);
  Q_ASSERT(mChatRoom);

  handleIsComposingChanged(mChatRoom);

  // Get messages.
  mEntries.clear();

  QElapsedTimer timer;
  timer.start();

  for (auto &message : mChatRoom->getHistory(0))
    mEntries << qMakePair(
      QVariantMap{
        { "type", EntryType::MessageEntry },
        { "timestamp", QDateTime::fromMSecsSinceEpoch(message->getTime() * 1000) }
      },
      static_pointer_cast<void>(message)
    );

  // Get calls.
  if(!getIsSecure() )
	for (auto &callLog : core->getCallHistory(mChatRoom->getPeerAddress(), mChatRoom->getLocalAddress()))
	    insertCall(callLog);

  qInfo() << QStringLiteral("ChatRoomModel (%1, %2) loaded in %3 milliseconds.")
    .arg(peerAddress).arg(localAddress).arg(timer.elapsed());
  
  if(!mChatRoom)
	  qWarning("TOTO C");

}
*/

bool ChatRoomModel::getIsSecure() const{
	return mChatRoom->getSecurityLevel() == linphone::ChatRoomSecurityLevel::Encrypted
			|| mChatRoom->getSecurityLevel() == linphone::ChatRoomSecurityLevel::Safe;
}

bool ChatRoomModel::getIsRemoteComposing () const {
  return mIsRemoteComposing;
}

//QList<ParticipantModel *> ChatRoomModel::getParticipants() const{
QString ChatRoomModel::getParticipants() const{
	QStringList participants;
	for(auto it = mParticipants.begin() ; it != mParticipants.end() ; ++it)
		participants << (*it)->getAddress();
	
	return participants.join(",");
}

// -----------------------------------------------------------------------------

void ChatRoomModel::removeEntry (int id) {
  qInfo() << QStringLiteral("Removing chat entry: %1 of (%2, %3).")
    .arg(id).arg(getPeerAddress()).arg(getLocalAddress());

  if (!removeRow(id))
    qWarning() << QStringLiteral("Unable to remove chat entry: %1").arg(id);
}

void ChatRoomModel::removeAllEntries () {
  qInfo() << QStringLiteral("Removing all chat entries of: (%1, %2).")
    .arg(getPeerAddress()).arg(getLocalAddress());

  beginResetModel();

  for (auto &entry : mEntries)
    removeEntry(entry);

  mEntries.clear();

  endResetModel();

  emit allEntriesRemoved();
  emit focused();// Removing all entries is like having focus. Don't wait asynchronous events.
}

// -----------------------------------------------------------------------------

void ChatRoomModel::sendMessage (const QString &message) {
  shared_ptr<linphone::ChatMessage> _message = mChatRoom->createMessageFromUtf8("");
  _message->getContents().begin()->get()->setUtf8Text(message.toUtf8().toStdString());
  _message->removeListener(mMessageHandlers);// Remove old listener if already exists
  _message->addListener(mMessageHandlers);

  _message->send();

  emit messageSent(_message);
}

void ChatRoomModel::resendMessage (int id) {
  if (id < 0 || id > mEntries.count()) {
    qWarning() << QStringLiteral("Entry %1 not exists.").arg(id);
    return;
  }

  const ChatEntryData entry = mEntries[id];
  const QVariantMap map = entry.first;

  if (map["type"] != EntryType::MessageEntry) {
    qWarning() << QStringLiteral("Unable to resend entry %1. It's not a message.").arg(id);
    return;
  }

  switch (map["status"].toInt()) {
    case MessageStatusFileTransferError:
    case MessageStatusNotDelivered: {
      shared_ptr<linphone::ChatMessage> message = static_pointer_cast<linphone::ChatMessage>(entry.second);
      message->removeListener(mMessageHandlers);// Remove old listener if already exists
      message->addListener(mMessageHandlers);
      message->send();

      break;
    }

    default:
      qWarning() << QStringLiteral("Unable to resend message: %1. Bad state.").arg(id);
  }
}

void ChatRoomModel::sendFileMessage (const QString &path) {
  QFile file(path);
  if (!file.exists())
    return;

  qint64 fileSize = file.size();
  if (fileSize > FileSizeLimit) {
    qWarning() << QStringLiteral("Unable to send file. (Size limit=%1)").arg(FileSizeLimit);
    return;
  }

  shared_ptr<linphone::Content> content = CoreManager::getInstance()->getCore()->createContent();
  {
    QStringList mimeType = QMimeDatabase().mimeTypeForFile(path).name().split('/');
    if (mimeType.length() != 2) {
      qWarning() << QStringLiteral("Unable to get supported mime type for: `%1`.").arg(path);
      return;
    }
    content->setType(Utils::appStringToCoreString(mimeType[0]));
    content->setSubtype(Utils::appStringToCoreString(mimeType[1]));
  }
  content->setSize(size_t(fileSize)); 
  content->setName(Utils::appStringToCoreString( QFileInfo(file).fileName()));
  shared_ptr<linphone::ChatMessage> message = mChatRoom->createFileTransferMessage(content);
  message->getContents().front()->setFilePath(Utils::appStringToCoreString(path));
  message->removeListener(mMessageHandlers);// Remove old listener if already exists
  message->addListener(mMessageHandlers);

  createThumbnail(message);

  message->send();

  emit messageSent(message);
}

// -----------------------------------------------------------------------------

void ChatRoomModel::downloadFile (int id) {
  const ChatEntryData entry = getFileMessageEntry(id);
  if (!entry.second)
    return;

  shared_ptr<linphone::ChatMessage> message = static_pointer_cast<linphone::ChatMessage>(entry.second);

  switch (static_cast<MessageStatus>(message->getState())) {
    case MessageStatusDelivered:
    case MessageStatusDeliveredToUser:
    case MessageStatusDisplayed:
    case MessageStatusFileTransferDone:
      break;

    default:
      qWarning() << QStringLiteral("Unable to download file of entry %1. It was not uploaded.").arg(id);
      return;
  }  
  bool soFarSoGood;
  const QString safeFilePath = Utils::getSafeFilePath(
    QStringLiteral("%1%2")
      .arg(CoreManager::getInstance()->getSettingsModel()->getDownloadFolder())
      .arg(entry.first["fileName"].toString()),
    &soFarSoGood
  );

  if (!soFarSoGood) {
    qWarning() << QStringLiteral("Unable to create safe file path for: %1.").arg(id);
    return;
  }
  message->removeListener(mMessageHandlers);// Remove old listener if already exists
  message->addListener(mMessageHandlers);

  message->getContents().front()->setFilePath(Utils::appStringToCoreString(safeFilePath));

  if( !message->isFileTransfer()){
    QMessageBox::warning(nullptr, "Download File", "This file was already downloaded and is no more on the server. Your peer have to resend it if you want to get it");
  }else
  {
    if (!message->downloadContent(message->getFileTransferInformation()))
        qWarning() << QStringLiteral("Unable to download file of entry %1.").arg(id);
  }
}

void ChatRoomModel::openFile (int id, bool showDirectory) {
  const ChatEntryData entry = getFileMessageEntry(id);
  if (!entry.second)
    return;

  shared_ptr<linphone::ChatMessage> message = static_pointer_cast<linphone::ChatMessage>(entry.second);
  if (!entry.first["wasDownloaded"].toBool()) {
    downloadFile(id);
  }else{
    QFileInfo info(getMessageAppData(message).m_path);
    QDesktopServices::openUrl(
      QUrl(QStringLiteral("file:///%1").arg(showDirectory ? info.absolutePath() : info.absoluteFilePath()))
    );
  }
}

bool ChatRoomModel::fileWasDownloaded (int id) {
  const ChatEntryData entry = getFileMessageEntry(id);
  return entry.second && ::fileWasDownloaded(static_pointer_cast<linphone::ChatMessage>(entry.second));
}

void ChatRoomModel::compose () {
  mChatRoom->compose();
}

void ChatRoomModel::resetMessageCount () {
  if (mChatRoom->getUnreadMessagesCount() > 0){
    mChatRoom->markAsRead();// Marking as read is only for messages. Not for calls.
	setUnreadMessagesCount(mChatRoom->getUnreadMessagesCount());
  }
  mMissedCallsCount = 0;
  emit messageCountReset();
}
std::shared_ptr<linphone::ChatRoom> ChatRoomModel::getChatRoom(){
	return mChatRoom;
}
// -----------------------------------------------------------------------------

const ChatRoomModel::ChatEntryData ChatRoomModel::getFileMessageEntry (int id) {
  if (id < 0 || id > mEntries.count()) {
    qWarning() << QStringLiteral("Entry %1 not exists.").arg(id);
    return ChatEntryData();
  }

  const ChatEntryData entry = mEntries[id];
  if (entry.first["type"] != EntryType::MessageEntry) {
    qWarning() << QStringLiteral("Unable to download entry %1. It's not a message.").arg(id);
    return ChatEntryData();
  }

  shared_ptr<linphone::ChatMessage> message = static_pointer_cast<linphone::ChatMessage>(entry.second);
  if (!message->getFileTransferInformation()) {
    qWarning() << QStringLiteral("Entry %1 is not a file message.").arg(id);
    return ChatEntryData();
  }

  return entry;
}

// -----------------------------------------------------------------------------

void ChatRoomModel::removeEntry (ChatEntryData &entry) {
  int type = entry.first["type"].toInt();

  switch (type) {
    case ChatRoomModel::MessageEntry: {
      shared_ptr<linphone::ChatMessage> message = static_pointer_cast<linphone::ChatMessage>(entry.second);
      removeFileMessageThumbnail(message);
      mChatRoom->deleteMessage(message);
      break;
    }

    case ChatRoomModel::CallEntry: {
      if (entry.first["status"].toInt() == CallStatusSuccess) {
        // WARNING: Unable to remove symmetric call here. (start/end)
        // We are between `beginRemoveRows` and `endRemoveRows`.
        // A solution is to schedule a `removeEntry` call in the Qt main loop.
        shared_ptr<void> linphonePtr = entry.second;
        QTimer::singleShot(0, this, [this, linphonePtr]() {
          auto it = find_if(mEntries.begin(), mEntries.end(), [linphonePtr](const ChatEntryData &entry) {
            return entry.second == linphonePtr;
          });

          if (it != mEntries.end())
            removeEntry(int(distance(mEntries.begin(), it)));
        });
      }

      CoreManager::getInstance()->getCore()->removeCallLog(static_pointer_cast<linphone::CallLog>(entry.second));
      break;
    }

    default:
      qWarning() << QStringLiteral("Unknown chat entry type: %1.").arg(type);
  }
}

void ChatRoomModel::insertCall (const shared_ptr<linphone::CallLog> &callLog) {
  linphone::Call::Status status = callLog->getStatus();

  auto insertEntry = [this](
    const ChatEntryData &entry,
    const QList<ChatEntryData>::iterator *start = nullptr
  ) {
    auto it = lower_bound(start ? *start : mEntries.begin(), mEntries.end(), entry, [](const ChatEntryData &a, const ChatEntryData &b) {
      return a.first["timestamp"] < b.first["timestamp"];
    });

    int row = int(distance(mEntries.begin(), it));

    beginInsertRows(QModelIndex(), row, row);
    it = mEntries.insert(it, entry);
    endInsertRows();

    return it;
  };

  // Add start call.
  QVariantMap start;
  fillCallStartEntry(start, callLog);
  auto it = insertEntry(qMakePair(start, static_pointer_cast<void>(callLog)));

  // Add end call. (if necessary)
  if (status == linphone::Call::Status::Success) {
    QVariantMap end;
    fillCallEndEntry(end, callLog);
    insertEntry(qMakePair(end, static_pointer_cast<void>(callLog)), &it);
  }
}

void ChatRoomModel::insertMessageAtEnd (const shared_ptr<linphone::ChatMessage> &message) {
  int row = mEntries.count();

  beginInsertRows(QModelIndex(), row, row);

  QVariantMap map{
    { "type", EntryType::MessageEntry },
    { "timestamp", QDateTime::fromMSecsSinceEpoch(message->getTime() * 1000) }
  };
  fillMessageEntry(map, message);
  mEntries << qMakePair(map, static_pointer_cast<void>(message));

  endInsertRows();
}

// -----------------------------------------------------------------------------

void ChatRoomModel::handleCallStateChanged (const shared_ptr<linphone::Call> &call, linphone::Call::State state) {
  if (state == linphone::Call::State::End || state == linphone::Call::State::Error){
	  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	  std::shared_ptr<linphone::ChatRoomParams> params = core->createDefaultChatRoomParams();
	  std::list<std::shared_ptr<linphone::Address>> participants;
		
	  auto chatRoom = core->searchChatRoom(params, mChatRoom->getLocalAddress()
									   , call->getRemoteAddress()
									   , participants);
	  if( mChatRoom == chatRoom){
		  insertCall(call->getCallLog());
		  setMissedCallsCount(mMissedCallsCount+1);
	  }
    //mChatRoom == CoreManager::getInstance()->getCore()->findChatRoom(call->getRemoteAddress(), mChatRoom->getLocalAddress())
  }
}

void ChatRoomModel::handleCallCreated(const shared_ptr<linphone::Call> &call){
}
//----------------------------------------------------------
//------				CHAT ROOM HANDLERS
//----------------------------------------------------------

void ChatRoomModel::onIsComposingReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & remoteAddress, bool isComposing){
	if (isComposing != mIsRemoteComposing) {
      mIsRemoteComposing = isComposing;
      emit isRemoteComposingChanged(mIsRemoteComposing);
    }
}
void ChatRoomModel::onMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){
	setUnreadMessagesCount(chatRoom->getUnreadMessagesCount());
	/*
	insertMessageAtEnd(message);
    emit messageReceived(message);*/
}
void ChatRoomModel::onNewEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	qWarning() << "New Event" <<(int) eventLog->getType();
	if( eventLog->getType() == linphone::EventLog::Type::ConferenceCallEnd ){
		setMissedCallsCount(mMissedCallsCount+1);
	}
	/*auto message = eventLog->getChatMessage();
	if(message){
		insertMessageAtEnd(message);
		emit messageReceived(message);
	}*/
}
void ChatRoomModel::onChatMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) {
	
	auto message = eventLog->getChatMessage();
	if(message){
		insertMessageAtEnd(message);
		emit messageReceived(message);
		setLastUpdateTime(QDateTime::fromMSecsSinceEpoch(chatRoom->getLastUpdateTime()));
	}
}
void ChatRoomModel::onChatMessageSending(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	auto message = eventLog->getChatMessage();
	if(message){
		insertMessageAtEnd(message);
	    emit messageReceived(message);
		setLastUpdateTime(QDateTime::fromMSecsSinceEpoch(chatRoom->getLastUpdateTime()));
	}
}
void ChatRoomModel::onChatMessageSent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){
	/*auto message = eventLog->getChatMessage();
	if(message){
		insertMessageAtEnd(message);
	    emit messageReceived(message);
	}*/
}
void ChatRoomModel::onParticipantAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void ChatRoomModel::onParticipantRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void ChatRoomModel::onParticipantAdminStatusChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void ChatRoomModel::onStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, linphone::ChatRoom::State newState){}
void ChatRoomModel::onSecurityEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void ChatRoomModel::onSubjectChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog) {
	emit subjectChanged(getSubject());
	emit usernameChanged(getUsername());
}
void ChatRoomModel::onUndecryptableMessageReceived(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){}
void ChatRoomModel::onParticipantDeviceAdded(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void ChatRoomModel::onParticipantDeviceRemoved(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void ChatRoomModel::onConferenceJoined(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void ChatRoomModel::onConferenceLeft(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void ChatRoomModel::onEphemeralEvent(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void ChatRoomModel::onEphemeralMessageTimerStarted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void ChatRoomModel::onEphemeralMessageDeleted(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::EventLog> & eventLog){}
void ChatRoomModel::onConferenceAddressGeneration(const std::shared_ptr<linphone::ChatRoom> & chatRoom){}
void ChatRoomModel::onParticipantRegistrationSubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){}
void ChatRoomModel::onParticipantRegistrationUnsubscriptionRequested(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<const linphone::Address> & participantAddress){}
void ChatRoomModel::onChatMessageShouldBeStored(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message){}
void ChatRoomModel::onChatMessageParticipantImdnStateChanged(const std::shared_ptr<linphone::ChatRoom> & chatRoom, const std::shared_ptr<linphone::ChatMessage> & message, const std::shared_ptr<const linphone::ParticipantImdnState> & state){}
