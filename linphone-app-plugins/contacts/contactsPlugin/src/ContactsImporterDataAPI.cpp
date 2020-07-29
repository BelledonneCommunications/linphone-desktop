#include "ContactsImporterDataAPI.hpp"

#include <linphone++/config.hh>

#include <QVariantMap>
#include <QJsonDocument>
// This class regroup Data interface for importing contacts
#include "ContactsImporterPlugin.hpp"

ContactsImporterDataAPI::ContactsImporterDataAPI(ContactsImporterPlugin * plugin, std::shared_ptr<linphone::Core> core) : mPlugin(plugin), mCore(core){
	QVariantMap defaultValues;
	QJsonDocument doc = QJsonDocument::fromJson(mPlugin->descriptionToJson().toUtf8());
	QVariantMap description = doc.toVariant().toMap();
	for(auto field : description["fields"].toList()){
		auto details = field.toMap();
		if( details.contains("fieldId") && details.contains("defaultData")){
			mInputFields[details["fieldId"].toString()] = details["defaultData"].toString();
		}
	}
	mInputFields["enabled"] = 0;
}
ContactsImporterDataAPI::~ContactsImporterDataAPI(){}

void ContactsImporterDataAPI::setInputFields(const QVariantMap &inputFields){
	if(mInputFields != inputFields) {
		mInputFields = inputFields;
		if( isValid(false))
			saveConfiguration();
		emit inputFieldsChanged(mInputFields);
	}
}
QVariantMap ContactsImporterDataAPI::getInputFields(){
	return mInputFields;
}

//-----------------------------		CONFIGURATION	---------------------------------------

void ContactsImporterDataAPI::setSectionConfiguration(const std::string& section){
	mSectionConfigurationName = section;
}

void ContactsImporterDataAPI::loadConfiguration(){
	if( mSectionConfigurationName != "") {
		std::shared_ptr<linphone::Config> config = mCore->getConfig();
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

void ContactsImporterDataAPI::saveConfiguration(){
	if( mSectionConfigurationName != "") {
		std::shared_ptr<linphone::Config> config = mCore->getConfig();
		QVariantMap inputsToSave = getInputFields();
		config->cleanSection(mSectionConfigurationName);// Remove fields that doesn't exist anymore (like temporary variables)
		for(auto field = inputsToSave.begin() ; field != inputsToSave.end() ; ++field)
			config->setString(mSectionConfigurationName, qPrintable(field.key()), qPrintable(field.value().toString()));
	}
}

//-----------------------------	-------------------------------------------------------


