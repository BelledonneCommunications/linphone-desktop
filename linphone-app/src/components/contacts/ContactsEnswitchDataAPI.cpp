#include "components/contact/VcardModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/core/CoreManager.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "utils/Utils.hpp"

#include "ContactsEnswitchDataAPI.hpp"

#include <QInputDialog> 

ContactsEnswitchDataAPI::ContactsEnswitchDataAPI(){
}
void ContactsEnswitchDataAPI::copy(ContactsEnswitchDataAPI *pData){
	mUrl = pData->mUrl;
	mDomain = pData->mDomain;
	mUsername = pData->mUsername;
	mPassword = pData->mPassword;
	mEnabled = pData->mEnabled;
}
QString ContactsEnswitchDataAPI::getUrl()const{
	return mUrl;
}
QString ContactsEnswitchDataAPI::getDomain()const{
	return mDomain;
}
QString ContactsEnswitchDataAPI::getUsername()const{
	return mUsername;
}
QString ContactsEnswitchDataAPI::getPassword()const{
	return mPassword;
}
bool ContactsEnswitchDataAPI::isEnabled()const{
	return mEnabled>0;
}
bool ContactsEnswitchDataAPI::isEqual(ContactsImportDataAPI *pData)const{
	ContactsEnswitchDataAPI * data = dynamic_cast<ContactsEnswitchDataAPI*>(pData);
	if( data)
		return data->mUrl == mUrl && data->mDomain == mDomain && data->mUsername==mUsername && data->mEnabled==mEnabled;
	else
		return false;
}

ContactsImportDataAPI * ContactsEnswitchDataAPI::from(const QVariantMap &pData){
	ContactsEnswitchDataAPI *data = new ContactsEnswitchDataAPI();
	data->mDomain = pData["domain"].toString();
	data->mUrl = pData["url"].toString();
	data->mUsername = pData["username"].toString();
	data->mPassword = pData["password"].toString();
	data->mEnabled = pData["enabled"].toInt();
	return data;
}
QVariantMap ContactsEnswitchDataAPI::toVariant() const{
	QVariantMap data;
	data["domain"] = mDomain;
	data["url"] = mUrl;
	data["username"] = mUsername;
	data["password"] = mPassword;
	data["enabled"] = mEnabled;
	return data;
}
bool ContactsEnswitchDataAPI::isValid( QString * pError){
	QStringList errors;
	if( mDomain.isEmpty())
		errors << "Domain is empty.";
	if( mUrl.isEmpty())
		errors << "Url is empty.";
	if( mUsername.isEmpty())
		errors << "Username is empty.";
	if( mPassword.isEmpty()){
		mPassword = QInputDialog::getText(nullptr, "Enswitch Address Book","Password",QLineEdit::EchoMode::Password);
		if( mPassword.isEmpty())
			errors << "Password is empty.";
	}
	if( errors.size() > 0){
		if(pError)
			*pError = "Enswitch Data is invalid : " + errors.join(" ");
		return false;
	}else
		return true;
}
//-----------------------------------------------------------------------------------------

void ContactsEnswitchDataAPI::parse(const QByteArray& p_data){
	QString statusText;
	QJsonDocument doc = QJsonDocument::fromJson(p_data);
	QJsonArray responses = doc["responses"].toArray();
	if( responses.size() > 0 ){
		QVariant code = responses[0].toObject()["code"].toVariant();		
		if( code.toInt() != 200) {
			statusText = responses[0].toObject()["message"].toString()+", Code="+code.toString();
		}else{
			QJsonArray contacts = doc["data"].toArray();
			int contactCount = 0;
			
			for(int i = 0 ; i < contacts.size() ; ++i){
				VcardModel  * card = CoreManager::getInstance()->createDetachedVcardModel();
				SipAddressesModel * sipConvertion = CoreManager::getInstance()->getSipAddressesModel();
				QJsonObject contact = contacts[i].toObject();
				QString mobile = contact["mobile"].toString();
				QString telephone = contact["telephone"].toString();
				QString username = contact["username"].toString();
				//QString company =  contact["company"].toString();	// TODO : Add company and email if selected from an option.
				//QString email = contact["email"].toString();
				if(!mobile.isEmpty())
					card->addSipAddress(sipConvertion->interpretSipAddress(mobile+"@"+mDomain, false));
				if(!telephone.isEmpty())
					card->addSipAddress(sipConvertion->interpretSipAddress(telephone+"@"+mDomain, false));
				if(!username.isEmpty()){
					card->setUsername(username);
					QString convertedUsername = sipConvertion->interpretSipAddress(username, mDomain);
					if(!convertedUsername.contains(mDomain)){
						convertedUsername = convertedUsername.replace('@',"%40")+"@"+mDomain;
					}
					card->addSipAddress(convertedUsername);
					if( username.contains('@'))
						card->addEmail(username);
				//	if(!email.isEmpty() && email != username)
				//		card->addEmail(email);
				}
				//if(!company.isEmpty())
				//	card->addCompany(company);
				if( card->getSipAddresses().size()>0){
					CoreManager::getInstance()->getContactsListModel()->addContact(card);
					++contactCount;
				}
			}
			QString messageStatus = QString::number(contactCount) +" contact"+(contactCount>1?"s":"")+" on Enswitch have been synchronized at "+QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
			emit statusMessage(messageStatus);
			qInfo() << messageStatus;
		}
	}
	if( !statusText.isEmpty())
		emit errorMessage(statusText);
}


