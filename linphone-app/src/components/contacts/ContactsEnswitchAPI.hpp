#ifndef CONTACTSENSWITCHAPI_HPP
#define CONTACTSENSWITCHAPI_HPP

#include <QObject>
#include <QtNetwork>

#include "ContactsEnswitchDataAPI.hpp"
#include "ContactsImportNetworkAPI.hpp"


// All-in-one for Enswitch address book importer
// Interface between Network API and Data.
class ContactsEnswitchAPI :  public ContactsImportNetworkAPI
{
Q_OBJECT
public:	
	ContactsEnswitchAPI();
	virtual ~ContactsEnswitchAPI(){}
	void copy(ContactsImportDataAPI *pData);	// Copy a ContactsEnswitchDataAPI to the current Data. Ensure to get a ContactsEnswitchDataAPI. It doesn't replace data instance to keep signal/slot connections

	static void requestList(ContactsImportDataAPI *pData, QObject *parent, const char *pErrorSlot);	// Call it for importing. Do connection with requestError(const QString&) .

	bool isEnabled()const;	// Interface to test if data is enabled
	bool isValid(ContactsImportDataAPI * pData, const bool &pShowError = true);// Test if data is valid

	virtual QString prepareRequest()const;// Prepare request for URL

// Data
	ContactsEnswitchDataAPI mData;

// Singleton for this kind of importer
	static ContactsEnswitchAPI * gContactsAPI;

};

#endif // CONTACTSENSWITCHAPI_HPP
