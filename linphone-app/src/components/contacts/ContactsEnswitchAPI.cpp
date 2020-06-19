#include "components/contact/VcardModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/core/CoreManager.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "utils/Utils.hpp"

#include "ContactsEnswitchAPI.hpp"
ContactsImportAPI * ContactsEnswitchAPI::gContactsAPI=nullptr;

ContactsEnswitchAPI::ContactsEnswitchAPI(){}

void ContactsEnswitchAPI::requestList(const ContactsEnswitchAPI &pData){
	if( gContactsAPI )// Ensure to have only one instance for this kind of importer
		gContactsAPI->deleteLater();
	gContactsAPI = new ContactsImportAPI(new ContactsEnswitchAPI(pData));
	gContactsAPI->request();
}

ContactsEnswitchAPI ContactsEnswitchAPI::from(const QVariantMap &pData){
	ContactsEnswitchAPI data;
	data.mDomain = pData["domain"].toString();
	data.mUrl = pData["url"].toString();
	data.mUsername = pData["username"].toString();
	data.mPassword = pData["password"].toString();
	return data;
}
QVariantMap ContactsEnswitchAPI::to() const{
	QVariantMap data;
	data["domain"] = mDomain;
	data["url"] = mUrl;
	data["username"] = mUsername;
	data["password"] = mPassword;
	return data;
}
bool ContactsEnswitchAPI::isValid(const bool& pPrintError)const{
	QStringList errors;
	if( mDomain.isEmpty())
		errors << "Domain is empty.";
	if( mUrl.isEmpty())
		errors << "Url is empty.";
	if( mUrl.isEmpty())
		errors << "Username is empty.";
	if( mUrl.isEmpty())
		errors << "Password is empty.";
	if( errors.size() > 0){
		if(pPrintError)
			qWarning() << "Enswitch Data is invalid : " << errors.join(" ");
		return false;
	}else
		return true;
}
//-----------------------------------------------------------------------------------------

QString ContactsEnswitchAPI::prepareRequest()const{
	return mUrl+"?auth_username="+mUsername+";auth_password="+mPassword;
}

void ContactsEnswitchAPI::parse(const QByteArray& p_data){
	QJsonDocument doc = QJsonDocument::fromJson(p_data);
	QJsonArray contacts = doc["data"].toArray();
	for(int i = 0 ; i < contacts.size() ; ++i){
		VcardModel  * card = CoreManager::getInstance()->createDetachedVcardModel();
		SipAddressesModel * sipConvertion = CoreManager::getInstance()->getSipAddressesModel();
		QString t = sipConvertion->interpretSipAddress("sip:json @"+mDomain, false);
		QJsonObject contact = contacts[i].toObject();
		QString mobile = contact["mobile"].toString();
		QString telephone = contact["telephone"].toString();
		QString username = contact["username"].toString();
		QString company =  contact["company"].toString();
		QString email = contact["email"].toString();
		if(!mobile.isEmpty())
			card->addSipAddress(sipConvertion->interpretSipAddress(mobile, false));
		if(!telephone.isEmpty())
			card->addSipAddress(sipConvertion->interpretSipAddress(telephone, false));
		if(!username.isEmpty()){
			card->setUsername(username);
			card->addSipAddress(sipConvertion->interpretSipAddress(username, false));
			if( username.contains('@'))
				card->addEmail(username);
			if(!email.isEmpty() && email != username)
				card->addEmail(email);
		}
		if(!company.isEmpty())
			card->addCompany(company);
		CoreManager::getInstance()->getContactsListModel()->addContact(card);
	}
	qInfo() << contacts.size() << "contacts on Enswitch have been synchronized.";
}


