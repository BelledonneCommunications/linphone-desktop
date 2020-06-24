#ifndef CONTACTSENSWITCHAPI_HPP
#define CONTACTSENSWITCHAPI_HPP

#include <QObject>
#include <QtNetwork>

#include "ContactsEnswitchDataAPI.hpp"
#include "ContactsImportNetworkAPI.hpp"


// All-in-one for Enswitch address book importer
class ContactsEnswitchAPI :  public ContactsImportNetworkAPI
{
Q_OBJECT
public:	
	ContactsEnswitchAPI();
	virtual ~ContactsEnswitchAPI(){}
	void copy(ContactsImportDataAPI *pData);

	static void requestList(ContactsImportDataAPI *pData, QObject *parent, const char *pErrorSlot);	// Call it for importing. Do connection.

	bool isEnabled()const;
	bool isValid(ContactsImportDataAPI * pData, const bool &pShowError = true);// Test if data is valid

	virtual QString prepareRequest()const;

// Data
	ContactsEnswitchDataAPI mData;

// Singleton for this kind of importer
	static ContactsEnswitchAPI * gContactsAPI;

};

#endif // CONTACTSENSWITCHAPI_HPP
