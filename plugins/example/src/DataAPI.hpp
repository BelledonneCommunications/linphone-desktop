#ifndef DATAAPI_HPP
#define DATAAPI_HPP

#include <QObject>
#include <QtNetwork>
#include <QVariantMap>

#include <LinphoneApp/PluginDataAPI.hpp>
#include <linphone++/core.hh>

class Plugin;
class QPluginLoader;

// Example of address book importer

class DataAPI :  public PluginDataAPI
{
Q_OBJECT
public:	
	DataAPI(Plugin *plugin, void *core, QPluginLoader * pluginLoader);
	virtual ~DataAPI(){}

	QString getUrl()const;
	QString getDomain()const;
	QString getUsername()const;
	QString getPassword()const;
	QString getKey()const;
	bool isEnabled()const;
	
	void setPassword(const QString &password);

	virtual bool isValid(const bool &requestData, QString * pError= nullptr);// Test data and send signal. Used to get feedback

	virtual QMap<PluginDataAPI::PluginCapability, QVariantMap> getInputFieldsToSave(const PluginCapability& capability);
	
	virtual void run(const PluginCapability& actionType);
public slots:
	virtual void parse(const QByteArray& p_data);
signals:
	void inputFieldsChanged(const PluginCapability& capability, const QVariantMap &inputs);	// The plugin made updates on input
};

#endif // DATAAPI_HPP
