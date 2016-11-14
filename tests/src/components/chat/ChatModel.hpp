#ifndef CHAT_MODEL_H_
#define CHAT_MODEL_H_

#include <QObject>

// ===================================================================

class ChatModel : public QObject {
  Q_OBJECT;

public:
  ChatModel (QObject *parent = Q_NULLPTR);
};

#endif // CHAT_MODEL_H_
