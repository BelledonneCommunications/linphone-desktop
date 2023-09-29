
#include <QSharedPointer>
#include <QQmlApplicationEngine>

#include "model/core/CoreModel.hpp"

class App : public QObject{
public:
	App(QObject * parent = nullptr);
	
	void init();
	
	QQmlApplicationEngine * mEngine = nullptr;
	QSharedPointer<CoreModel> mCoreModel;
};