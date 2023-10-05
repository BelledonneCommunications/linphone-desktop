
#include <QQmlApplicationEngine>
#include <QSharedPointer>

#include "core/thread/Thread.hpp"
#include "model/core/CoreModel.hpp"

class App : public QObject {
public:
	App(QObject *parent = nullptr);

	void init();
	void initCppInterfaces();

	void onLoggerInitialized();

	QQmlApplicationEngine *mEngine = nullptr;
	Thread *mLinphoneThread = nullptr;
	QSharedPointer<CoreModel> mCoreModel;
};