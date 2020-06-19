#ifndef CONTACTSENSWITCHAPI_HPP
#define CONTACTSENSWITCHAPI_HPP

#include <QObject>
#include <QtNetwork>

#include "ContactsImportDataAPI.hpp"
#include "ContactsImportAPI.hpp"

class ContactsEnswitchAPI : public ContactsImportDataAPI
{
public:	
	ContactsEnswitchAPI();
	virtual ~ContactsEnswitchAPI(){}

	static ContactsImportAPI * requestList(const ContactsEnswitchAPI &pData, bool *pIsNew =nullptr);	// Call it for importing. pData will be freed automatically

	static ContactsEnswitchAPI from(const QVariantMap &pData);
	virtual QVariantMap to() const;

// These functions are called by ContactsImportAPI	
	virtual bool isEqual(ContactsImportDataAPI *pData)const;
	virtual bool isValid(const bool& pPrintError = true);
	virtual QString prepareRequest()const;
	virtual QString parse(const QByteArray& p_data);
// Data
	QString mDomain;
	QString mUrl;
	QString mUsername;
	QString mPassword;

// Singleton for this kind of importer
	static ContactsImportAPI * gContactsAPI;
};

#endif // CONTACTSENSWITCHAPI_HPP
