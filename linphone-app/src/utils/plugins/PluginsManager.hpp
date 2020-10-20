//const QVersionNumber ContactsImporterPlugin::gPluginVersion = QVersionNumber::fromString(PLUGIN_CONTACT_VERSION);
//const QVersionNumber ContactsImporterPlugin::gPluginVersion = QVersionNumber::fromString("1.0.0");
//const QVersionNumber _ContactsImporterPlugin::gPluginVersion = QVersionNumber::fromString("1.0.0");
#ifndef PLUGINS_MANAGER_MODEL_H_
#define PLUGINS_MANAGER_MODEL_H_

#include <QObject>
#include <QVariantList>

// =============================================================================

class ContactsImporterModel;
class PluginDataAPI;
class QPluginLoader;

class PluginsModel : public QObject{
public:
	PluginsModel(QObject *parent = nullptr) : QObject(parent){}
	virtual ~PluginsModel(){}
	virtual void setDataAPI(PluginDataAPI*) = 0;
	virtual PluginDataAPI* getDataAPI() = 0;
	virtual int getIdentity()const = 0;
	virtual QVariantMap getFields() = 0;
};
class PluginsManager : public QObject{
Q_OBJECT
public:
	PluginsManager (QObject *parent = Q_NULLPTR);
	
	static QPluginLoader * getPlugin(const QString &pluginIdentity);	// Return a plugin loader with Hints to 0 (unload will force Qt to remove the plugin from memory).
	static QVariantList getPlugins(const int& capabilities = -1);	// Return all loaded plugins that have selected capabilities (PluginCapability flags)
	static void * createInstance(const QString &pluginIdentity);	//Return a data instance from a plugin name.
	static QJsonDocument getJson(const QString &pluginIdentity);	// Get the description of the plugin int the Json format.

	Q_INVOKABLE static void openNewPlugin(const QString &pTitle); // Open a File Dialog. Test if the file can be load and have a matched version. Replace old plugins from custom paths and with the same plugin title.
	static QVariantMap getDefaultValues(const QString& pluginIdentity);	// Get the default values of each fields for th eplugin
	QVariantMap getPluginDescription(const QString& pluginIdentity);



	QList<PluginsModel*> getImporterModels(const QStringList &capabilities);
	static QMap<QString, QString> gPluginsMap;	// Map between Identity and plugin path
	static QString gPluginsConfigSection;	// The root name of the plugin's section in configuration file
};


#endif // CONTACTS_IMPORTER_PLUGINS_MANAGER_MODEL_H_
