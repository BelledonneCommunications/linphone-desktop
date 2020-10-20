#ifndef LINPHONE_APP_PLUGIN_DATA_H
#define LINPHONE_APP_PLUGIN_DATA_H

#include <QVariantMap>

#ifdef ENABLE_APP_EXPORT_PLUGIN
	#include "include/LinphoneApp/LinphonePlugin.hpp"
#else
	#include <LinphoneApp/LinphonePlugin.hpp>
#endif

class QPluginLoader;
class LinphonePlugin;

// This class regroup Data interface for importing contacts
class LINPHONEAPP_DLL_API PluginDataAPI : public QObject {
Q_OBJECT
public:
	typedef enum{ALL=-1, NOTHING=0, CONTACTS=1} PluginCapability;
	PluginDataAPI(LinphonePlugin * plugin, void * linphoneCore, QPluginLoader * pluginLoader);
	virtual ~PluginDataAPI();

	virtual bool isValid(const bool &pRequestData=true, QString * pError= nullptr) = 0;	// Test if the passed data is valid. Used for saving.
	virtual void setInputFields(const QVariantMap &inputFields);// Set all inputs
	virtual QVariantMap getInputFields(const PluginCapability& capability);// Get all inputs
	virtual QVariantMap getInputFieldsToSave();// Get all inputs to save in config file.
	
// Configuration management
	void setSectionConfiguration(const std::string& section);
	virtual void loadConfiguration();
	virtual void saveConfiguration();

	QPluginLoader * getPluginLoader();// Used to retrieve the loader that created this instance, in order to unload it

	virtual void run(const PluginCapability& actionType)=0;

signals:
	void dataReceived(const PluginCapability& actionType, QVector<QMultiMap<QString,QString> > data);
//------------------------------------

	void inputFieldsChanged(const QVariantMap &inputFields);		// Input fields have been changed
	void message(const QtMsgType& type, const QString &message);		// Send a message to GUI


protected:
	QVariantMap mInputFields;
	void * mLinphoneCore;
	LinphonePlugin * mPlugin;
	QPluginLoader * mPluginLoader;
private:
	std::string mSectionConfigurationName;
};

#endif // LINPHONE_APP_PLUGIN_DATA_H
