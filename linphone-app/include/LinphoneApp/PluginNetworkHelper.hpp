#ifndef LINPHONE_APP_NETWORK_HELPER_H
#define LINPHONE_APP_NETWORK_HELPER_H

#include <QObject>
#include <QtNetwork>
// This class is used to define network operation to retrieve Addresses from Network


#ifdef ENABLE_APP_EXPORT_PLUGIN
	#include "LinphonePlugin.hpp"
#else
	#include <LinphoneApp/LinphonePlugin.hpp>
#endif

class LINPHONEAPP_DLL_API PluginNetworkHelper : public QObject
{
Q_OBJECT
public:
	PluginNetworkHelper();
	virtual ~PluginNetworkHelper();
	virtual QString prepareRequest()const=0;	// Called when requesting an Url.

	void request();

	QPointer<QNetworkReply> mNetworkReply;
	QNetworkAccessManager mManager;
signals:
	void requestFinished(const QByteArray &data);	// The request is over and have data
	void message(const QtMsgType &type, const QString &message);
	
private:
	void handleReadyData();
	void handleFinished ();
	void handleError (QNetworkReply::NetworkError code);
	void handleSslErrors (const QList<QSslError> &sslErrors);

	QByteArray mBuffer;
};

#endif // LINPHONE_APP_NETWORK_HELPER_H
