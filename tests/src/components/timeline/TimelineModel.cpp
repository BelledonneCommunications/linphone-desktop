#include <algorithm>

#include <QDateTime>
#include <linphone++/linphone.hh>

#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "TimelineModel.hpp"

using namespace std;

// ===================================================================

TimelineModel::TimelineModel (QObject *parent): QAbstractListModel(parent) {
  // Returns an iterator entry position to insert a new entry.
  auto search_entry = [this](
    const QVariantMap &map,
    const QList<QMap<QString, QVariant> >::iterator *start = NULL
  ) {
    return lower_bound(
      start ? *start : m_entries.begin(), m_entries.end(), map,
      [](const QVariantMap &a, const QVariantMap &b) {
        return a["timestamp"] > b["timestamp"];
      }
    );
  };

  shared_ptr<linphone::Core> core(CoreManager::getInstance()->getCore());

  // Insert chat rooms events.
  for (const auto &chat_room : core->getChatRooms()) {
    list<shared_ptr<linphone::ChatMessage> > history = chat_room->getHistory(0);

    if (history.size() == 0)
      continue;

    // Last message must be at the end of history.
    shared_ptr<linphone::ChatMessage> message = history.back();

    // Insert event message in timeline entries.
    QVariantMap map;
    map["timestamp"] = QDateTime::fromTime_t(message->getTime());
    map["sipAddresses"] = Utils::linphoneStringToQString(
      chat_room->getPeerAddress()->asString()
    );

    m_entries.insert(search_entry(map), map);
  }

  // Insert calls events.
  QHash<QString, bool> address_done;
  for (const auto &call_log : core->getCallLogs()) {
    // Get a sip uri to check.
    QString address = Utils::linphoneStringToQString(
      call_log->getRemoteAddress()->asString()
    );

    if (address_done.value(address))
      continue; // Already used.

    address_done[address] = true;

    // Make a new map.
    QVariantMap map;
    map["timestamp"] = QDateTime::fromTime_t(
      call_log->getStartDate() + call_log->getDuration()
    );
    map["sipAddresses"] = address;

    // Search existing entry.
    auto it = find_if(
      m_entries.begin(), m_entries.end(), [&address](const QVariantMap &map) {
        return address == map["sipAddresses"].toString();
      }
    );

    // Is it a new entry?
    if (it == m_entries.cend())
      m_entries.insert(search_entry(map), map);
    else if (map["timestamp"] > (*it)["timestamp"]) {
      // Remove old entry and insert.
      it = m_entries.erase(it);

      if (it != m_entries.cbegin())
        it--;

      m_entries.insert(search_entry(map, &it), map);
    }
  }
}

int TimelineModel::rowCount (const QModelIndex &) const {
  return m_entries.count();
}

QHash<int, QByteArray> TimelineModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$timelineEntry";
  return roles;
}

QVariant TimelineModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (row < 0 || row >= m_entries.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return m_entries[row];

  return QVariant();
}
