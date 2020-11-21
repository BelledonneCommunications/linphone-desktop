#ifndef NETWORKAPI_HPP
#define NETWORKAPI_HPP

#include <QObject>
#include <QtNetwork>


#include <LinphoneApp/PluginNetworkHelper.hpp>

class DataAPI;
class PluginDataAPI;
// Interface between Network API and Data.
class NetworkAPI :  public PluginNetworkHelper
{
Q_OBJECT
public:	
	NetworkAPI(DataAPI * data);
	virtual ~NetworkAPI();

	bool isEnabled()const;	// Interface to test if data is enabled
	bool isValid(PluginDataAPI * pData, const bool &pShowError = true);// Test if data is valid

	virtual QString prepareRequest()const;// Prepare request for URL
	
	void startRequest();

// Data
	DataAPI * mData;
	int mCurrentStep;

};

#endif // NETWORKAPI_HPP
