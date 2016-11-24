#ifndef CHAT_MODEL_H_
#define CHAT_MODEL_H_

#include <QObject>

// ===================================================================

class ChatModel : public QObject {
  Q_OBJECT;

  Q_PROPERTY(
    QString remoteSipAddress
    READ getRemoteSipAddress
    WRITE setRemoteSipAddress
    NOTIFY remoteSipAddressChanged
  );

public:
  ChatModel (QObject *parent = Q_NULLPTR);

signals:
  void remoteSipAddressChanged (QString remote_sip_address);

private:
  QString getRemoteSipAddress () const {
    return m_remote_sip_address;
  }
  void setRemoteSipAddress (QString &remote_sip_address) {
    m_remote_sip_address = remote_sip_address;
  }

  QString m_remote_sip_address;
};

#endif // CHAT_MODEL_H_
