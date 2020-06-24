#ifndef CONTACTSIMPORTDATAAPI_H
#define CONTACTSIMPORTDATAAPI_H


#include <QVariantMap>
// This class regroup Data interface for importing contacts
class ContactsImportDataAPI
{
public:
	ContactsImportDataAPI();
	virtual ~ContactsImportDataAPI();

	virtual QVariantMap toVariant() const=0;

	virtual bool isEqual(ContactsImportDataAPI * pData)const = 0;	// Test if data is the same of the current data
	virtual bool isValid(QString * pError= nullptr) = 0;	// Test if the passed data is valid
	virtual void parse(const QByteArray& pData) = 0;	// Parse pData and build a set of data
};

#endif // CONTACTSIMPORTDATAAPI_H
