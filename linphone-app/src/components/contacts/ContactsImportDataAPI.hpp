#ifndef CONTACTSIMPORTDATAAPI_H
#define CONTACTSIMPORTDATAAPI_H


#include <QVariantMap>

class ContactsImportDataAPI
{
public:
	ContactsImportDataAPI();
	virtual ~ContactsImportDataAPI();

	virtual QVariantMap to() const=0;
	
// These functions are called by ContactsImportAPI
	virtual bool isEqual(ContactsImportDataAPI * pData)const = 0;
	virtual bool isValid(const bool& pPrintError = true) = 0;
	virtual QString prepareRequest()const = 0;
	virtual QString parse(const QByteArray& pData) = 0;// Return an error message
};

#endif // CONTACTSIMPORTDATAAPI_H
