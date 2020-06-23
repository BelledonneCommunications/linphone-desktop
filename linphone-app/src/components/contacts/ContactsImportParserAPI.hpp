#ifndef CONTACTSIMPORTPARSERAPI_H
#define CONTACTSIMPORTPARSERAPI_H

 #include <QString>

// Interface for using a Generic Parser when dealing Address books
class ContactsImportParserAPI
{
public:
	ContactsImportParserAPI();
	virtual ~ContactsImportParserAPI();
	virtual void parse(const QByteArray& p_data)=0;
	
};

#endif // CONTACTSIMPORTPARSERAPI_H
