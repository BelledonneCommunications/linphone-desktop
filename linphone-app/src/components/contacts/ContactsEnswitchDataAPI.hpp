#ifndef CONTACTSENSWITCHDATAAPI_HPP
#define CONTACTSENSWITCHDATAAPI_HPP

#include <QObject>
#include <QtNetwork>

#include "ContactsImportDataAPI.hpp"

// Enswitch DATA address book importer
class ContactsEnswitchDataAPI :  public QObject, public ContactsImportDataAPI
{
Q_OBJECT
public:	
	ContactsEnswitchDataAPI();
	virtual ~ContactsEnswitchDataAPI(){}
	
	void copy(ContactsEnswitchDataAPI *pData);
	
	QString getUrl()const;
	QString getDomain()const;
	QString getUsername()const;
	QString getPassword()const;
	bool isEnabled()const;
	
	static ContactsImportDataAPI *from(const QVariantMap &pData);// Create a ContactsEnswitchAPI from a Qavriant set
	virtual QVariantMap toVariant() const;	// Translate data into QVariant

// These functions are called by ContactsImportAPI	
	virtual bool isEqual(ContactsImportDataAPI *pData)const;
	virtual bool isValid(QString * pError= nullptr);// Test data and send signal. Used to get feedback
public slots:
	virtual void parse(const QByteArray& p_data);
signals:
	void errorMessage(const QString &error);
	void statusMessage(const QString &message);
private:
// Data
	QString mDomain;
	QString mUrl;
	QString mUsername;
	QString mPassword;
	int mEnabled;

};

#endif // CONTACTSENSWITCHAPI_HPP
