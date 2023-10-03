#include "LoginPage.hpp"
#include <QTimer>


LoginPage::LoginPage(QObject * parent) : QObject(parent){

}

bool LoginPage::isLogged() {
	static bool testLog = false;
	QTimer::singleShot(2000, [&]() mutable{
		testLog = true;
		emit isLoggedChanged();
	});
	return testLog;
}