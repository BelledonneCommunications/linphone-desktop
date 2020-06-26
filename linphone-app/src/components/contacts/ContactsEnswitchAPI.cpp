#include "components/contact/VcardModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/core/CoreManager.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "utils/Utils.hpp"

#include "ContactsEnswitchAPI.hpp"

#include <QInputDialog> 

ContactsEnswitchAPI * ContactsEnswitchAPI::gContactsAPI=nullptr;

ContactsEnswitchAPI::ContactsEnswitchAPI(){
	connect(this, SIGNAL(requestFinished(const QByteArray&)), &mData, SLOT(parse(const QByteArray&)));
	connect(&mData, SIGNAL(errorMessage(const QString &)), this, SIGNAL(requestError(const QString &)));
	connect(&mData, SIGNAL(statusMessage(const QString &)), this, SIGNAL(requestMessage(const QString &)));
}
void ContactsEnswitchAPI::copy(ContactsImportDataAPI *pData){
	ContactsEnswitchDataAPI * data = dynamic_cast<ContactsEnswitchDataAPI*>(pData);
	if(data)
		mData.copy(data);
}
void ContactsEnswitchAPI::requestList(ContactsImportDataAPI *pData, QObject *parent, const char *pErrorSlot, const char *pMessageSlot){
	if(!gContactsAPI){
		gContactsAPI = new ContactsEnswitchAPI();
		if(parent){
			connect(gContactsAPI, SIGNAL(requestError(const QString&)), parent, pErrorSlot);
			connect(gContactsAPI, SIGNAL(requestMessage(const QString&)), parent, pMessageSlot);
		}
	}
	if(pData != nullptr && gContactsAPI->isValid(pData)){
		gContactsAPI->copy(pData);
		if(gContactsAPI->isEnabled())
			gContactsAPI->request();
	}
}
bool ContactsEnswitchAPI::isEnabled()const{
	return mData.isEnabled();
}
bool ContactsEnswitchAPI::isValid(ContactsImportDataAPI * pData, const bool &pShowError){
	QString errorMessage;
	ContactsEnswitchDataAPI * data = dynamic_cast<ContactsEnswitchDataAPI*>(pData);
	bool ok = data;
	if(!ok)
		errorMessage = "These data are not Enswitch data";
	else
		ok = pData->isValid(&errorMessage);
	if(!ok && pShowError){
		qWarning() << errorMessage;
		emit requestError(errorMessage);
	}
	return ok;
}
//-----------------------------------------------------------------------------------------

QString ContactsEnswitchAPI::prepareRequest()const{
	return mData.getUrl()+"?auth_username="+mData.getUsername()+";auth_password="+mData.getPassword();
}


