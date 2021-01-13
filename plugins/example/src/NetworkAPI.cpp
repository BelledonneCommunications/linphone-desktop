#include "NetworkAPI.hpp"
#include "DataAPI.hpp"

#include <QInputDialog> 
#include <LinphoneApp/PluginDataAPI.hpp>


NetworkAPI::NetworkAPI(DataAPI * data) : mData(data){
	if(mData ) {
		connect(this, SIGNAL(requestFinished(const QByteArray&)), mData, SLOT(parse(const QByteArray&)));
		connect(this, &NetworkAPI::message, mData, &DataAPI::message);
	}
}

NetworkAPI::~NetworkAPI(){
}

bool NetworkAPI::isEnabled()const{
	return mData && mData->isEnabled();
}
bool NetworkAPI::isValid(PluginDataAPI * pData, const bool &pShowError){
	QString errorMessage;
	DataAPI * data = dynamic_cast<DataAPI*>(pData);
	bool ok = data;
	if(!ok)
		errorMessage = "These data are invalid";
	else
		ok = pData->isValid(true, &errorMessage);
	if(!ok && pShowError){
		qWarning() << errorMessage;
		emit message(QtMsgType::QtWarningMsg, errorMessage);
	}
	return ok;
}
//-----------------------------------------------------------------------------------------

QString NetworkAPI::prepareRequest()const{
	QString url = mData->getUrl()+"?user="+mData->getUsername()+"&";
	if( mData->getKey() != "")
		url += "key="+mData->getKey();
	else
		url += "password="+mData->getPassword();
	return url;
}

void NetworkAPI::startRequest() {
	bool doRequest = false;
	if(isValid(mData)){
		if(isEnabled()){
			mCurrentStep=0;
			doRequest = true;
		}
	}
	if(doRequest)
		request();
	else
		mData->parse(QByteArray());
}
