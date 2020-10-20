#include "DataAPI.hpp"
#include "NetworkAPI.hpp"
#include "Plugin.hpp"

#include <QInputDialog> 
#include <QPluginLoader>
#include <linphone++/proxy_config.hh>

DataAPI::DataAPI(Plugin *plugin, void * core, QPluginLoader * pluginLoader) :PluginDataAPI(plugin, core, pluginLoader){
	auto proxyConfig = static_cast<linphone::Core*>(mLinphoneCore)->getDefaultProxyConfig();
	QVariantMap account;
	std::string domain;
	if(proxyConfig)
		domain = proxyConfig->getDomain();
	else{
		proxyConfig = static_cast<linphone::Core*>(mLinphoneCore)->createProxyConfig();
		if(proxyConfig)
			domain = proxyConfig->getDomain();
		if(domain == "")
			domain = "sip.linphone.org";
	}
	mInputFields["SIP_Domain"] =  QString::fromLocal8Bit(domain.c_str(), int(domain.size()));
}

QString DataAPI::getUrl()const{
	return mInputFields["URL"].toString();
}
QString DataAPI::getDomain()const{
	return mInputFields["SIP_Domain"].toString();
}
QString DataAPI::getUsername()const{
	return mInputFields["Username"].toString();
}
QString DataAPI::getPassword()const{
	return mInputFields["Password"].toString();
}
QString DataAPI::getKey()const{
	return mInputFields["Key"].toString();
}
bool DataAPI::isEnabled()const{
	return mInputFields["enabled"].toInt()>0;
}
void DataAPI::setPassword(const QString &password){
	mInputFields["Password"] = password;
}

bool DataAPI::isValid(const bool &pRequestData, QString * pError){
	QStringList errors;
	if( getDomain().isEmpty())
		errors << "Domain is empty.";
	if( getUrl().isEmpty())
		errors << "Url is empty.";
	if( getUsername().isEmpty())
		errors << "Username is empty.";
	if( getPassword().isEmpty() && getKey().isEmpty()){
		if(pRequestData)
			setPassword(QInputDialog::getText(nullptr, "Linphone example Address Book","Password",QLineEdit::EchoMode::Password));
		if( getPassword().isEmpty())
			errors << "Password is empty.";
	}
	if( errors.size() > 0){
		if(pError)
			*pError = "Data is invalid : " + errors.join(" ");
		return false;
	}else
		return true;
}

QVariantMap DataAPI::getInputFieldsToSave(){// Remove Password from config file
	QVariantMap data = mInputFields;
	data.remove("Password");
	return data;
}

void  DataAPI::run(const PluginCapability& actionType){
	if( actionType == PluginCapability::CONTACTS){
		NetworkAPI * network = new NetworkAPI(this);
		QObject::connect(this, &PluginDataAPI::dataReceived, network, &DataAPI::deleteLater);
		network->startRequest();
	}
}
//-----------------------------------------------------------------------------------------

void DataAPI::parse(const QByteArray& p_data){
	QVector<QMultiMap<QString,QString> > parsedData;
	QString statusText;
	if(!p_data.isEmpty()) {
		QJsonDocument doc = QJsonDocument::fromJson(p_data);
		QJsonObject responses = doc.object();
		QString status = responses["status"].toString();
		QString comment = responses["comment"].toString();
		if( responses.size() == 0){
			statusText = "Contacts are not in Json format.";
		}else if( status != "OK"){
			statusText = status;
			if( statusText.isEmpty())
				statusText = "Cannot parse the request: The URL may not be valid.";
			if(!comment.isEmpty())
				statusText += " "+comment;
			if( mInputFields.contains("Key")){
				QVariantMap newInputs = mInputFields;
				newInputs.remove("Key");// Reset key on error
				setInputFields(newInputs);
			}
		}else{
			if( responses.contains("key")){
				QVariantMap newInputs = mInputFields;
				newInputs["Key"] = responses["key"].toString();
				setInputFields(newInputs);
			}
			if( responses.contains("contacts")){
				QJsonArray contacts = responses["contacts"].toArray();
				int contactCount = 0;
				for(int i = 0 ; i < contacts.size() ; ++i){
					QMultiMap<QString, QString> cardData;
					QJsonObject contact = contacts[i].toObject();
					QString phoneNumber = contact["number"].toString();
					QStringList name;
					bool haveData = false;
					QString company =  contact["company"].toString();
					
					
					if( contact.contains("firstname") && contact["firstname"].toString() != "")
						name << contact["firstname"].toString();
					if( contact.contains("surname") && contact["surname"].toString() != "")
						name << contact["surname"].toString();
					
					if(name.size() > 0){
						QString username = name.join(" ");
						cardData.insert("displayName", username);
					}
					if(!phoneNumber.isEmpty()) {
						cardData.insert("phoneNumber", phoneNumber);
						cardData.insert("sipUsername", phoneNumber);
						haveData = true;
					}
					if(!company.isEmpty())
						cardData.insert("organization", company);
					if( haveData){
						cardData.insert("sipDomain", mInputFields["SIP_Domain"].toString());
						parsedData.push_back(cardData);
						++contactCount;
					}
				}
				QString messageStatus = QString::number(contactCount) +" contact"+(contactCount>1?"s":"")+" have been synchronized at "+QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
				emit message(QtInfoMsg, messageStatus);
				qInfo() << messageStatus;
			}
		}
	}else
		statusText = "Cannot parse the request: The URL may not be valid.";
	if( !statusText.isEmpty())
		emit message(QtWarningMsg, statusText);
	emit dataReceived(PluginDataAPI::CONTACTS, parsedData);
}


