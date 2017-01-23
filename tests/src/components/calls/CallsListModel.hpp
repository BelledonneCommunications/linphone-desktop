#ifndef CALLS_LIST_MODEL_H_
#define CALLS_LIST_MODEL_H_

#include <QAbstractListModel>

#include "../call/CallModel.hpp"

// =============================================================================

class CoreHandlers;

class CallsListModel : public QAbstractListModel {
  Q_OBJECT;

public:
  CallsListModel (QObject *parent = Q_NULLPTR);
  ~CallsListModel () = default;

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;

  Q_INVOKABLE void launchAudioCall (const QString &sip_uri) const;
  Q_INVOKABLE void launchVideoCall (const QString &sip_uri) const;

private:
  bool removeRow (int row, const QModelIndex &parent = QModelIndex());
  bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;

  void addCall (const std::shared_ptr<linphone::Call> &linphone_call);
  void removeCall (const std::shared_ptr<linphone::Call> &linphone_call);

  QList<CallModel *> m_list;

  std::shared_ptr<CoreHandlers> m_core_handlers;
};

#endif // CALLS_LIST_MODEL_H_
