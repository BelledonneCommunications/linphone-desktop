#include "ContactsImporterNetworkAPI.hpp"
#include <QObject>
#include <QtNetwork>
// This class is used to define network operation to retrieve Addresses from Network

ContactsImporterNetworkAPI::ContactsImporterNetworkAPI(){}
ContactsImporterNetworkAPI::~ContactsImporterNetworkAPI(){}
void ContactsImporterNetworkAPI::request(){	// Create QNetworkReply and make network requests
	QNetworkRequest request(prepareRequest());
	
	request.setAttribute(QNetworkRequest::FollowRedirectsAttribute, true);
	mNetworkReply = mManager.get(request);

#if QT_CONFIG(ssl)
	mNetworkReply->ignoreSslErrors();
#endif

	QNetworkReply *data = mNetworkReply.data();

	QObject::connect(data, &QNetworkReply::readyRead, this, &ContactsImporterNetworkAPI::handleReadyData);
	QObject::connect(data, &QNetworkReply::finished, this, &ContactsImporterNetworkAPI::handleFinished);
	QObject::connect(data, QNonConstOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error), this, &ContactsImporterNetworkAPI::handleError);

#if QT_CONFIG(ssl)
	QObject::connect(data, &QNetworkReply::sslErrors, this, &ContactsImporterNetworkAPI::handleSslErrors);
#endif
}
void ContactsImporterNetworkAPI::handleReadyData(){
	mBuffer.append(mNetworkReply->readAll());
}
void ContactsImporterNetworkAPI::handleFinished (){
	if (mNetworkReply->error() == QNetworkReply::NoError){
		mBuffer.append(mNetworkReply->readAll());
		emit requestFinished(mBuffer);
	}else
		emit requestError(mNetworkReply->errorString());
	mBuffer.clear();
}
void ContactsImporterNetworkAPI::handleError (QNetworkReply::NetworkError code) {
	if (code != QNetworkReply::OperationCanceledError) {
		QString url = mNetworkReply->url().host();
		QString errorString = mNetworkReply->errorString();
		qWarning() << QStringLiteral("Download of %1 failed: %2").arg(url).arg(errorString);
	}
}
void ContactsImporterNetworkAPI::handleSslErrors (const QList<QSslError> &sslErrors){
#if QT_CONFIG(ssl)
	for (const QSslError &error : sslErrors)
		qWarning() << QStringLiteral("SSL error %1 : %2").arg(error.error()).arg(error.errorString());
#else
	Q_UNUSED(sslErrors);
#endif
}
