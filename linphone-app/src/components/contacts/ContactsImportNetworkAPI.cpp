#include "ContactsImportNetworkAPI.hpp"

ContactsImportNetworkAPI::ContactsImportNetworkAPI(){
}
ContactsImportNetworkAPI::~ContactsImportNetworkAPI(){
}
void ContactsImportNetworkAPI::request(){
	QNetworkRequest request(prepareRequest());
	mNetworkReply = mManager.get(request);
	QNetworkReply *data = mNetworkReply.data();

	QObject::connect(data, &QNetworkReply::readyRead, this, &ContactsImportNetworkAPI::handleReadyData);
	QObject::connect(data, &QNetworkReply::finished, this, &ContactsImportNetworkAPI::handleFinished);
	QObject::connect(data, QNonConstOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error), this, &ContactsImportNetworkAPI::handleError);

#if QT_CONFIG(ssl)
	QObject::connect(data, &QNetworkReply::sslErrors, this, &ContactsImportNetworkAPI::handleSslErrors);
#endif
}

void ContactsImportNetworkAPI::handleReadyData(){
	mBuffer.append(mNetworkReply->readAll());
}
void ContactsImportNetworkAPI::handleFinished() {
	if (mNetworkReply->error() == QNetworkReply::NoError){
		mBuffer.append(mNetworkReply->readAll());
		emit requestFinished(mBuffer);
	}else
		emit requestError(mNetworkReply->errorString());
	mBuffer.clear();
}

void ContactsImportNetworkAPI::handleError (QNetworkReply::NetworkError code) {
	if (code != QNetworkReply::OperationCanceledError)
		qWarning() << QStringLiteral("Download of %1 failed: %2").arg(prepareRequest()).arg(mNetworkReply->errorString());
}

void ContactsImportNetworkAPI::handleSslErrors (const QList<QSslError> &sslErrors) {
  #if QT_CONFIG(ssl)
    for (const QSslError &error : sslErrors)
      qWarning() << QStringLiteral("SSL error: %1").arg(error.errorString());
  #else
    Q_UNUSED(sslErrors);
  #endif
}
