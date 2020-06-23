#include "components/contact/VcardModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/core/CoreManager.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "utils/Utils.hpp"

#include "ContactsEnswitchAPI.hpp"

#include <QInputDialog> 

ContactsEnswitchAPI * ContactsEnswitchAPI::gContactsAPI=nullptr;

ContactsEnswitchAPI::ContactsEnswitchAPI(){
	connect(this, SIGNAL(requestFinished(const QByteArray&)), this, SLOT(parse(const QByteArray&)));
}

void ContactsEnswitchAPI::updateData(ContactsImportDataAPI * pData){
	//if(!isEqual(pData))
		copy(pData);
}
void ContactsEnswitchAPI::copy(ContactsImportDataAPI *pData){
	ContactsEnswitchAPI * data = dynamic_cast<ContactsEnswitchAPI*>(pData);
	mUrl = data->mUrl;
	mDomain = data->mDomain;
	mPassword = data->mPassword;
	mUsername = data->mUsername;
	mEnabled = data->mEnabled;
}
bool ContactsEnswitchAPI::isEqual(ContactsImportDataAPI *pData)const{
	ContactsEnswitchAPI * data = dynamic_cast<ContactsEnswitchAPI*>(pData);
	if( data)
		return data->mUrl == mUrl && data->mDomain == mDomain && data->mUsername==mUsername && data->mEnabled==mEnabled;
	else
		return false;
}
void ContactsEnswitchAPI::requestList(ContactsImportDataAPI *pData, QObject *parent, const char *pErrorSlot){
	if(!gContactsAPI){
		gContactsAPI = new ContactsEnswitchAPI();
		if(parent)
			connect(gContactsAPI, SIGNAL(requestError(const QString&)), parent, pErrorSlot);
	}
	if(pData != nullptr && gContactsAPI->isValid(pData)){
		gContactsAPI->updateData(pData);
		if(gContactsAPI->mEnabled>0)
			gContactsAPI->request();
	}
}

ContactsImportDataAPI * ContactsEnswitchAPI::from(const QVariantMap &pData){
	ContactsEnswitchAPI *data = new ContactsEnswitchAPI();
	data->mDomain = pData["domain"].toString();
	data->mUrl = pData["url"].toString();
	data->mUsername = pData["username"].toString();
	data->mPassword = pData["password"].toString();
	data->mEnabled = pData["enabled"].toInt();
	return data;
}
QVariantMap ContactsEnswitchAPI::toVariant() const{
	QVariantMap data;
	data["domain"] = mDomain;
	data["url"] = mUrl;
	data["username"] = mUsername;
	data["password"] = mPassword;
	data["enabled"] = mEnabled;
	return data;
}
bool ContactsEnswitchAPI::isValid(ContactsImportDataAPI * pData, const bool &pShowError){
	ContactsEnswitchAPI * data = dynamic_cast<ContactsEnswitchAPI*>(pData);
	QStringList errors;
	if( !data)
		errors << "These data are not Enswitch data";
	else {
		if( data->mDomain.isEmpty())
			errors << "Domain is empty.";
		if( data->mUrl.isEmpty())
			errors << "Url is empty.";
		if( data->mUsername.isEmpty())
			errors << "Username is empty.";
		if( data->mPassword.isEmpty()){
			data->mPassword = QInputDialog::getText(nullptr, "Enswitch Address Book","Password",QLineEdit::EchoMode::Password);
			if( data->mPassword.isEmpty())
				errors << "Password is empty.";
		}
	}
	if( errors.size() > 0){
		if(pShowError){
			QString message = "Enswitch Data is invalid : " + errors.join(" ");
			qWarning() << message;
			emit requestError(message);
		}
		return false;
	}else
		return true;
}
//-----------------------------------------------------------------------------------------

QString ContactsEnswitchAPI::prepareRequest()const{
	return mUrl+"?auth_username="+mUsername+";auth_password="+mPassword;
}

void ContactsEnswitchAPI::parse(const QByteArray& p_data){
	QString statusText;
	QJsonDocument doc = QJsonDocument::fromJson(p_data);
	QJsonArray responses = doc["responses"].toArray();
	if( responses.size() > 0 ){
		QVariant code = responses[0].toObject()["code"].toVariant();		
		if( code.toInt() != 200) {
			statusText = responses[0].toObject()["message"].toString()+", Code="+code.toString();
		}else{
			QJsonArray contacts = doc["data"].toArray();
			
			for(int i = 0 ; i < contacts.size() ; ++i){
				VcardModel  * card = CoreManager::getInstance()->createDetachedVcardModel();
				SipAddressesModel * sipConvertion = CoreManager::getInstance()->getSipAddressesModel();
				QString t = sipConvertion->interpretSipAddress("sip:json @"+mDomain, false);
				QJsonObject contact = contacts[i].toObject();
				QString mobile = contact["mobile"].toString();
				QString telephone = contact["telephone"].toString();
				QString username = contact["username"].toString();
				//QString company =  contact["company"].toString();	// TODO : Add company and email if selected from an option.
				//QString email = contact["email"].toString();
				if(!mobile.isEmpty())
					card->addSipAddress(sipConvertion->interpretSipAddress(mobile, false));
				if(!telephone.isEmpty())
					card->addSipAddress(sipConvertion->interpretSipAddress(telephone, false));
				if(!username.isEmpty()){
					card->setUsername(username);
					card->addSipAddress(sipConvertion->interpretSipAddress(username, false));
					if( username.contains('@'))
						card->addEmail(username);
				//	if(!email.isEmpty() && email != username)
				//		card->addEmail(email);
				}
				//if(!company.isEmpty())
				//	card->addCompany(company);
				if( card->getSipAddresses().size()>0)
					CoreManager::getInstance()->getContactsListModel()->addContact(card);
			}
			qInfo() << contacts.size() << "contacts on Enswitch have been synchronized.";
		}
	}
	if( !statusText.isEmpty())
		emit requestError(statusText);
}


