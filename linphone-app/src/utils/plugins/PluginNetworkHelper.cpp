#include "include/LinphoneApp/PluginNetworkHelper.hpp"
#include <QObject>
#include <QtNetwork>
// This class is used to define network operation to retrieve Addresses from Network

PluginNetworkHelper::PluginNetworkHelper(){}
PluginNetworkHelper::~PluginNetworkHelper(){}
void PluginNetworkHelper::request(){	// Create QNetworkReply and make network requests
	QNetworkRequest request(prepareRequest());
	
	request.setAttribute(QNetworkRequest::FollowRedirectsAttribute, true);
	mNetworkReply = mManager.get(request);

#if QT_CONFIG(ssl)
	mNetworkReply->ignoreSslErrors();
#endif

	QNetworkReply *data = mNetworkReply.data();

	QObject::connect(data, &QNetworkReply::readyRead, this, &PluginNetworkHelper::handleReadyData);
	QObject::connect(data, &QNetworkReply::finished, this, &PluginNetworkHelper::handleFinished);
	QObject::connect(data, QNonConstOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error), this, &PluginNetworkHelper::handleError);

#if QT_CONFIG(ssl)
	QObject::connect(data, &QNetworkReply::sslErrors, this, &PluginNetworkHelper::handleSslErrors);
#endif
}
void PluginNetworkHelper::handleReadyData(){
	mBuffer.append(mNetworkReply->readAll());
}
void PluginNetworkHelper::handleFinished (){
	if (mNetworkReply->error() == QNetworkReply::NoError){
		mBuffer.append(mNetworkReply->readAll());
		emit requestFinished(mBuffer);
	}else {
		qWarning() << mNetworkReply->errorString();
		emit message(QtWarningMsg, "Error while dealing with network. See logs for details.");
	}
	mBuffer.clear();
}
void PluginNetworkHelper::handleError (QNetworkReply::NetworkError code) {
	if (code != QNetworkReply::OperationCanceledError) {
		QString url = mNetworkReply->url().host();
		QString errorString = mNetworkReply->errorString();
		qWarning() << QStringLiteral("Download failed: %1 from %2").arg(errorString).arg(url);
	}
}
void PluginNetworkHelper::handleSslErrors (const QList<QSslError> &sslErrors){
#if QT_CONFIG(ssl)
	for (const QSslError &error : sslErrors)
		qWarning() << QStringLiteral("SSL error %1 : %2").arg(error.error()).arg(error.errorString());
#else
	Q_UNUSED(sslErrors);
#endif
}
