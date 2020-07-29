#ifndef CONTACTSIMPORTPLUGIN_H
#define CONTACTSIMPORTPLUGIN_H
#include <QtPlugin>
#include <QObject>
// Overload this class to make a plugin for the address book importer

#include <linphone++/core.hh>

class ContactsImporterDataAPI;

class ContactsImporterPlugin
{
public:
	virtual ~ContactsImporterPlugin() {}
	virtual QString descriptionToJson() const = 0;// Describe the plugin. Json are in Utf8
	virtual ContactsImporterDataAPI * createInstance(std::shared_ptr<linphone::Core> core) = 0;
};

#define ContactsImporterPlugin_iid "linphone.ContactsImporterPlugin"
Q_DECLARE_INTERFACE(ContactsImporterPlugin, ContactsImporterPlugin_iid)

#endif // CONTACTSIMPORTPLUGIN_H
