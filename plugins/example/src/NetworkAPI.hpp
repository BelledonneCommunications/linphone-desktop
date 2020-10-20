#ifndef NETWORKAPI_HPP
#define NETWORKAPI_HPP

#include <QObject>
#include <QtNetwork>


#include <LinphoneApp/PluginNetworkHelper.hpp>

class DataAPI;
class PluginDataAPI;
// All-in-one for Enswitch address book importer
// Interface between Network API and Data.
class NetworkAPI :  public PluginNetworkHelper
{
Q_OBJECT
public:	
	NetworkAPI(DataAPI * data);
	virtual ~NetworkAPI();
	void copy(PluginDataAPI *pData);	// Copy a ContactsEnswitchDataAPI to the current Data. Ensure to get a ContactsEnswitchDataAPI. It doesn't replace data instance to keep signal/slot connections

	bool isEnabled()const;	// Interface to test if data is enabled
	bool isValid(PluginDataAPI * pData, const bool &pShowError = true);// Test if data is valid

	virtual QString prepareRequest()const;// Prepare request for URL
	
	void startRequest();

// Data
	DataAPI * mData;
	int mCurrentStep;

};

#endif // NETWORKAPI_HPP
