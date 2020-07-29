#ifndef CONTACTSIMPORTERDATAAPI_H
#define CONTACTSIMPORTERDATAAPI_H

#include <QVariantMap>
#include <linphone++/core.hh>

class ContactsImporterPlugin;
// This class regroup Data interface for importing contacts
class ContactsImporterDataAPI : public QObject {
Q_OBJECT
public:
	ContactsImporterDataAPI(ContactsImporterPlugin * plugin, std::shared_ptr<linphone::Core> core);
	virtual ~ContactsImporterDataAPI();

	virtual bool isValid(const bool &pRequestData=true, QString * pError= nullptr) = 0;	// Test if the passed data is valid. Used for saving.
	virtual void setInputFields(const QVariantMap &inputFields);
	virtual QVariantMap getInputFields();
	virtual void importContacts()=0;
	
	void setSectionConfiguration(const std::string& section);
	virtual void loadConfiguration();
	virtual void saveConfiguration();

signals:
	void inputFieldsChanged(const QVariantMap &inputFields);

	void errorMessage(const QString &message);	// There are errors while requesting. Send a message status.
	void statusMessage(const QString &message);	// Send a message.
	
	void contactsReceived(QVector<QMultiMap<QString,QString> > data);

protected:
	QVariantMap mInputFields;
	std::shared_ptr<linphone::Core> mCore;
	ContactsImporterPlugin * mPlugin;
private:
	std::string mSectionConfigurationName;
};

#endif // CONTACTSIMPORTDATAAPI_H
