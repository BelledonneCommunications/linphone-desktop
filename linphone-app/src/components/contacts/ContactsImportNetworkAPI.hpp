#ifndef CONTACTSIMPORTNETWORKAPI_H
#define CONTACTSIMPORTNETWORKAPI_H

#include <QObject>
#include <QtNetwork>
#include "ContactsImportDataAPI.hpp"
// This class is used to define network operation to retrieve Addresses from Network
class ContactsImportNetworkAPI : public QObject
{
Q_OBJECT
public:
	ContactsImportNetworkAPI();
	virtual ~ContactsImportNetworkAPI();
	virtual QString prepareRequest()const=0;	// Called when requesting an Url.
	

	void request();	// Create QNetworkReply and make network requests

	QPointer<QNetworkReply> mNetworkReply;
	QNetworkAccessManager mManager;
signals:
	void requestFinished(const QByteArray &data);	// The request is over and have data
	void requestError(const QString &status);	// There are errors while requesting. Send a message status.
	void requestMessage(const QString &message);	// Send a message.
	
private:
	void handleReadyData();
	void handleFinished ();
	void handleError (QNetworkReply::NetworkError code);
	void handleSslErrors (const QList<QSslError> &errors);

	QByteArray mBuffer;
};

#endif // CONTACTSIMPORTNETWORKAPI_H
