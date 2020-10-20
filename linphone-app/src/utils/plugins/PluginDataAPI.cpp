#include "include/LinphoneApp/PluginDataAPI.hpp"

#include <linphone++/core.hh>
#include <linphone++/config.hh>

#include <QVariantMap>
#include <QJsonDocument>
#include <QPluginLoader>
// This class regroup Data interface for importing contacts
#include "include/LinphoneApp/LinphonePlugin.hpp"

PluginDataAPI::PluginDataAPI(LinphonePlugin * plugin, void* linphoneCore, QPluginLoader * pluginLoader) : mPlugin(plugin), mLinphoneCore(linphoneCore), mPluginLoader(pluginLoader){
	QVariantMap defaultValues;	
	QJsonDocument doc = QJsonDocument::fromJson(mPlugin->getGUIDescriptionToJson().toUtf8());
	QVariantMap description = doc.toVariant().toMap();
	mPluginLoader->setLoadHints(0);
	for(auto field : description["fields"].toList()){
		auto details = field.toMap();
		if( details.contains("fieldId") && details.contains("defaultData")){
			mInputFields[details["fieldId"].toString()] = details["defaultData"].toString();
		}
	}
	mInputFields["enabled"] = 0;
}
PluginDataAPI::~PluginDataAPI(){
}

void PluginDataAPI::setInputFields(const QVariantMap &inputFields){
	if(mInputFields != inputFields) {
		mInputFields = inputFields;
		if( isValid(false))
			saveConfiguration();
		emit inputFieldsChanged(mInputFields);
	}
}
QVariantMap PluginDataAPI::getInputFields(const PluginCapability& capability){
	return mInputFields;
}
QVariantMap PluginDataAPI::getInputFieldsToSave() {
	return mInputFields;
}
//-----------------------------		CONFIGURATION	---------------------------------------

void PluginDataAPI::setSectionConfiguration(const std::string& section){
	mSectionConfigurationName = section;
}

void PluginDataAPI::loadConfiguration(){
	if( mSectionConfigurationName != "") {
		std::shared_ptr<linphone::Config> config = static_cast<linphone::Core*>(mLinphoneCore)->getConfig();
		QVariantMap importData;
		std::list<std::string> keys = config->getKeysNamesList(mSectionConfigurationName);
		for(auto key : keys){
			std::string value = config->getString(mSectionConfigurationName, key, "");
			importData[QString::fromLocal8Bit(key.c_str(), int(key.size()))] = QString::fromLocal8Bit(value.c_str(), int(value.size()));
		}
		//Do not use setInputFields(importData); as we don't want to save the configuration
		mInputFields = importData;
		emit inputFieldsChanged(mInputFields);
	}
}

void PluginDataAPI::saveConfiguration(){
	if( mSectionConfigurationName != "") {
		std::shared_ptr<linphone::Config> config = static_cast<linphone::Core*>(mLinphoneCore)->getConfig();
		QVariantMap inputsToSave = getInputFieldsToSave();
		config->cleanSection(mSectionConfigurationName);// Remove fields that doesn't exist anymore (like temporary variables)
		for(auto field = inputsToSave.begin() ; field != inputsToSave.end() ; ++field)
			config->setString(mSectionConfigurationName, qPrintable(field.key()), qPrintable(field.value().toString()));
	}
}

//-----------------------------	-------------------------------------------------------

QPluginLoader * PluginDataAPI::getPluginLoader(){
	return mPluginLoader;
}
