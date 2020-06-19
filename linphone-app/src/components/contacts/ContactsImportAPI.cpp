#include "ContactsImportAPI.hpp"

ContactsImportAPI::ContactsImportAPI(ContactsImportDataAPI * pData) : mData(pData)
{
}
ContactsImportAPI::~ContactsImportAPI(){
	delete mData;
}
void ContactsImportAPI::updateData(ContactsImportDataAPI * pData){
	if(pData->isEqual(mData))
		delete pData;
	else{
		delete mData;
		mData = pData;
	}
}
QString ContactsImportAPI::prepareRequest()const{
	return mData->prepareRequest();
}
void ContactsImportAPI::request(){
	if(mData->isValid()){
		QNetworkRequest request(prepareRequest());
		mNetworkReply = mManager.get(request);
		QNetworkReply *data = mNetworkReply.data();
	
		QObject::connect(data, &QNetworkReply::readyRead, this, &ContactsImportAPI::handleReadyData);
		QObject::connect(data, &QNetworkReply::finished, this, &ContactsImportAPI::handleFinished);
		QObject::connect(data, QNonConstOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error), this, &ContactsImportAPI::handleError);

#if QT_CONFIG(ssl)
		QObject::connect(data, &QNetworkReply::sslErrors, this, &ContactsImportAPI::handleSslErrors);
#endif
	}
}

void ContactsImportAPI::handleReadyData(){
	mBuffer.append(mNetworkReply->readAll());
}
void ContactsImportAPI::handleFinished() {
	if (mNetworkReply->error() == QNetworkReply::NoError){
		mBuffer.append(mNetworkReply->readAll());
		emit status(mData->parse(mBuffer));
	}else
		emit status(mNetworkReply->errorString());
	mBuffer.clear();
}

void ContactsImportAPI::handleError (QNetworkReply::NetworkError code) {
	if (code != QNetworkReply::OperationCanceledError)
		qWarning() << QStringLiteral("Download of %1 failed: %2").arg(mData->prepareRequest()).arg(mNetworkReply->errorString());
}

void ContactsImportAPI::handleSslErrors (const QList<QSslError> &sslErrors) {
  #if QT_CONFIG(ssl)
    for (const QSslError &error : sslErrors)
      qWarning() << QStringLiteral("SSL error: %1").arg(error.errorString());
  #else
    Q_UNUSED(sslErrors);
  #endif
}
