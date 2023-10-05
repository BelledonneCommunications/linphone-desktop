
#include <QThread>

class Thread : public QThread {
public:
	Thread(QObject *parent = nullptr);

	virtual void run();
};