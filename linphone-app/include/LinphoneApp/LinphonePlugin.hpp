#ifndef LINPHONE_APP_PLUGIN_H
#define LINPHONE_APP_PLUGIN_H
#include <QtPlugin>
#include <QObject>
#include <QVersionNumber>
// Overload this class to make a plugin for the address book importer

#ifdef ENABLE_APP_EXPORT_PLUGIN
	#define LINPHONEAPP_DLL_API Q_DECL_EXPORT
#else
	#define LINPHONEAPP_DLL_API Q_DECL_IMPORT
#endif

class QPluginLoader;
class PluginDataAPI;

class LinphonePlugin
{
// These macro are an example to use in the custom plugin
//Q_OBJECT
//Q_PLUGIN_METADATA(IID LinphonePlugin_iid FILE "PluginExample.json")// You have to set the Capabilities for your plugin
//Q_INTERFACES(LinphonePlugin)
//-----------------------------------------------------------
public:
	virtual ~LinphonePlugin() {}
	
//	Specific to DataAPI. See their section
	virtual QString getGUIDescriptionToJson() const = 0;// Describe the GUI to be used for the plugin. Json are in Utf8
	
	virtual PluginDataAPI * createInstance(void* core, QPluginLoader * pluginLoader) = 0;// Create an instance of the plugin in LinphoneAppPluginType.
};

#define LinphonePlugin_iid "linphoneApp.LinphonePlugin/1.0"
Q_DECLARE_INTERFACE(LinphonePlugin, LinphonePlugin_iid)

#endif // LINPHONE_APP_PLUGIN_H
