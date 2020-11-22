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
// First, get all fields where their target is ALL. It will be act as a "default field"
	for(auto field : description["fields"].toList()){
		auto details = field.toMap();
		if( details.contains("fieldId") && details.contains("defaultData")){
			int fieldCapability = details["capability"].toInt();
			if( fieldCapability == PluginCapability::ALL){
				for(int capability = PluginCapability::CONTACTS ; capability != PluginCapability::LAST ; ++capability){
					mInputFields[static_cast<PluginCapability>(capability)][details["fieldId"].toString()] = details["defaultData"].toString();		
				}
			}
		}
	}
// Second, get all fields that are not for ALL and add them	
	for(auto field : description["fields"].toList()){
		auto details = field.toMap();
		if( details.contains("fieldId") && details.contains("defaultData")){
			int fieldCapability = details["capability"].toInt();
			if( fieldCapability> PluginCapability::NOTHING)
				mInputFields[static_cast<PluginCapability>(fieldCapability)][details["fieldId"].toString()] = details["defaultData"].toString();		
		}
	}
	for(auto inputFields : mInputFields)
		inputFields["enabled"] = 0;
}
PluginDataAPI::~PluginDataAPI(){
}

void PluginDataAPI::setInputFields(const PluginCapability& pCapability, const QVariantMap &inputFields){
	for(int capabilityIndex = (pCapability == PluginCapability::ALL?PluginCapability::CONTACTS:pCapability); capabilityIndex != (pCapability == PluginCapability::ALL?PluginCapability::LAST:pCapability+1) ; ++capabilityIndex){
		PluginCapability selectedCapability = static_cast<PluginCapability>(capabilityIndex);
		if(mInputFields[selectedCapability] != inputFields) {
			mInputFields[selectedCapability] = inputFields;
			if( isValid(false))
				saveConfiguration(selectedCapability);
			emit inputFieldsChanged(selectedCapability, mInputFields[selectedCapability]);
		}
	}
}

QMap<PluginDataAPI::PluginCapability, QVariantMap> PluginDataAPI::getInputFields(const PluginCapability& capability){
	if( capability == PluginCapability::ALL)
		return mInputFields;
	else{
		QMap<PluginDataAPI::PluginCapability, QVariantMap> data;
		data[capability] = mInputFields[capability];
		return data;
	}
}
QMap<PluginDataAPI::PluginCapability, QVariantMap> PluginDataAPI::getInputFieldsToSave(const PluginCapability& capability) {
	return getInputFields(capability);
}
//-----------------------------		CONFIGURATION	---------------------------------------

void PluginDataAPI::setSectionConfiguration(const QString& section){
	mSectionConfigurationName = section;
}

void PluginDataAPI::loadConfiguration(const PluginCapability& pCapability){
	if( mSectionConfigurationName != "") {
		for(int capabilityIndex = (pCapability == PluginCapability::ALL?PluginCapability::CONTACTS:pCapability); capabilityIndex != (pCapability == PluginCapability::ALL?PluginCapability::LAST:pCapability+1) ; ++capabilityIndex){
			PluginCapability currentCapability = static_cast<PluginCapability>(capabilityIndex);
			std::shared_ptr<linphone::Config> config = static_cast<linphone::Core*>(mLinphoneCore)->getConfig();
			QVariantMap importData;
			std::string sectionName = (mSectionConfigurationName+"_"+QString::number(capabilityIndex)).toStdString();
			std::list<std::string> keys = config->getKeysNamesList(sectionName);
			for(auto key : keys){
				std::string value = config->getString(sectionName, key, "");
				importData[QString::fromLocal8Bit(key.c_str(), int(key.size()))] = QString::fromLocal8Bit(value.c_str(), int(value.size()));
			}
			//Do not use setInputFields(importData); as we don't want to save the configuration
			mInputFields[currentCapability] = importData;
			emit inputFieldsChanged(currentCapability, mInputFields[currentCapability]);
		}
	}
}

void PluginDataAPI::saveConfiguration(const PluginCapability& pCapability){
	if( mSectionConfigurationName != "") {
		auto inputs = getInputFieldsToSave(pCapability);
		for(QMap<PluginCapability, QVariantMap>::Iterator input = inputs.begin() ; input != inputs.end() ; ++input){
			PluginCapability currentCapability = input.key();
			std::string sectionName = (mSectionConfigurationName+"_"+QString::number(currentCapability)).toStdString();
			std::shared_ptr<linphone::Config> config = static_cast<linphone::Core*>(mLinphoneCore)->getConfig();
			QVariantMap inputsToSave = inputs[currentCapability];
			config->cleanSection(sectionName);// Remove fields that doesn't exist anymore (like temporary variables)
			for(auto field = inputsToSave.begin() ; field != inputsToSave.end() ; ++field)
				config->setString(sectionName, qPrintable(field.key()), qPrintable(field.value().toString()));
		}
	}
}
void PluginDataAPI::cleanAllConfigurations(){
	for(int capabilityIndex = PluginCapability::ALL ; capabilityIndex != PluginCapability::LAST ; ++capabilityIndex){
		std::string sectionName = (mSectionConfigurationName+"_"+QString::number(capabilityIndex)).toStdString();		
		std::shared_ptr<linphone::Config> config = static_cast<linphone::Core*>(mLinphoneCore)->getConfig();
		config->cleanSection(sectionName);
	}
}
//-----------------------------	-------------------------------------------------------

QPluginLoader * PluginDataAPI::getPluginLoader(){
	return mPluginLoader;
}
