
#include <QQmlApplicationEngine>
#include <QSharedPointer>

#include "model/core/CoreModel.hpp"

class App : public QObject {
public:
	App(QObject *parent = nullptr);

	void init();
	void initCppInterfaces();

	QQmlApplicationEngine *mEngine = nullptr;
	QSharedPointer<CoreModel> mCoreModel;
};