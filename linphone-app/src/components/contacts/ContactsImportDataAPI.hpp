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
	virtual bool isValid(const bool& pPrintError = true)const = 0;
	virtual QString prepareRequest()const = 0;
	virtual void parse(const QByteArray& p_data) = 0;
};

#endif // CONTACTSIMPORTDATAAPI_H
