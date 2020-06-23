#ifndef CONTACTSENSWITCHAPI_HPP
#define CONTACTSENSWITCHAPI_HPP

#include <QObject>
#include <QtNetwork>

#include "ContactsImportDataAPI.hpp"
#include "ContactsImportParserAPI.hpp"
#include "ContactsImportNetworkAPI.hpp"


// All-in-one for Enswitch address book importer
class ContactsEnswitchAPI :  public ContactsImportNetworkAPI, public ContactsImportDataAPI, public ContactsImportParserAPI
{
Q_OBJECT
public:	
	ContactsEnswitchAPI();
	virtual ~ContactsEnswitchAPI(){}
	void updateData(ContactsImportDataAPI * pData);
	void copy(ContactsImportDataAPI *pData);

	static void requestList(ContactsImportDataAPI *pData, QObject *parent, const char *pErrorSlot);	// Call it for importing. Do connection.

	static ContactsImportDataAPI *from(const QVariantMap &pData);// Create a ContactsEnswitchAPI from a Qavriant set
	virtual QVariantMap toVariant() const;	// Translate data into QVariant

// These functions are called by ContactsImportAPI	
	virtual bool isEqual(ContactsImportDataAPI *pData)const;
	virtual bool isValid(ContactsImportDataAPI * pData, const bool &pShowError = true);// Test data and send signal. Used to get feedback
	virtual QString prepareRequest()const;
// Data
	QString mDomain;
	QString mUrl;
	QString mUsername;
	QString mPassword;
	int mEnabled;

// Singleton for this kind of importer
	static ContactsEnswitchAPI * gContactsAPI;
public slots:
	virtual void parse(const QByteArray& p_data);

};

#endif // CONTACTSENSWITCHAPI_HPP
