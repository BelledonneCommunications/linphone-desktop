

#include <QObject>

class LoginPage : public QObject{
Q_OBJECT

public:
	LoginPage(QObject * parent = nullptr);
	
	Q_PROPERTY(bool isLogged READ isLogged NOTIFY isLoggedChanged)
	
	bool isLogged();
	
signals:
	void isLoggedChanged();
};