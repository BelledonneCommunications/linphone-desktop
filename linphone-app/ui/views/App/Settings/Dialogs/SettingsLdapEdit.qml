import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

// =============================================================================

DialogPlus {
	id: dialog
	
	property LdapModel ldapData
	
	buttons: [
		TextButtonA {
			text: qsTr('cancel')
			
			onClicked: {
				ldapData.unset()
				exit(0)}
		},
		TextButtonB {
			enabled: ldapData.isValid
			text: qsTr('confirm')
			
			onClicked: {ldapData.save()
				exit(1)
			}
		}
	]
	
	buttonsAlignment: Qt.AlignCenter
	
	height: SettingsSipAccountsEditStyle.height
	width: SettingsSipAccountsEditStyle.width
	
	// ---------------------------------------------------------------------------
	
	TabContainer {
		anchors.fill: parent
		
		Column {
			width: parent.width
			Form {
				title: ''
				width: parent.width
				
				FormLine {
					FormGroup {
						label: qsTr('displayNameLabel')//'Display Name'
						TextField {
							id:displayName
							placeholderText : (serverUrl.text?serverUrl.text:serverUrl.placeholderText)
							text:ldapData.displayName
							onTextChanged: Qt.callLater(function(){ldapData.displayName = text})
							Keys.onEnterPressed:  nextItemInFocusChain().forceActiveFocus()
							Keys.onReturnPressed:  nextItemInFocusChain().forceActiveFocus()
							TooltipArea{
								text : qsTr('displayNameTooltip')//'The display name of the server to be shown in the list'
								//tooltipParent: dialog
							}
						}
					}
				}
			}
			
			Form {
				title: qsTr('connectionTitle')//'Connection'
				width: parent.width
				
				FormLine {
					FormGroup {
						label: qsTr('serverLabel')+' *'//'Server URL *'
						TextField {
							id:serverUrl
							placeholderText :"Server"
							text:ldapData.server
							onTextChanged: Qt.callLater(function(){ldapData.server = text})
							Keys.onEnterPressed:  nextItemInFocusChain().forceActiveFocus()
							Keys.onReturnPressed:  nextItemInFocusChain().forceActiveFocus()
							error : ldapData.serverFieldError
							TooltipArea{
								text : qsTr('serverTooltip')//'LDAP Server. eg: ldap:/// for a localhost server or ldap://ldap.example.org/'
								//tooltipParent: dialog
							}
						}
					}
				}
				
				FormLine {
					FormGroup {
						label: qsTr('bindDNLabel')+' *'//'Bind DN *'
						
						TextField {
							id: bindDn
							placeholderText :"Bind DN"
							text:ldapData.bindDn
							error : ldapData.bindDnFieldError
							onTextChanged: Qt.callLater(function(){ldapData.bindDn= text})
							TooltipArea{
								text : qsTr('bindDNTooltip')//'The bind DN is the credential that is used to authenticate against an LDAP.\n eg: cn=ausername,ou=people,dc=bc,dc=com'
								//tooltipParent: dialog
							}
						}
					}
				}
				
				FormLine {
					FormGroup {
						id:passwordGroup
						label: qsTr('passwordLabel')//'Password'
						PasswordField {
							id:password
							text:ldapData.password
							error : ldapData.passwordFieldError
							onTextChanged: Qt.callLater(function(){ldapData.password = text})
							placeholderText :"Password"
						}
					}
				}
				FormLine {
					id:useRow
					width:passwordGroup.width
					FormGroup {
						label: qsTr('useTLSLabel')//'Use TLS'
						Switch {
							id: useTls
							anchors.verticalCenter: parent.verticalCenter
							checked: ldapData.useTls
							onClicked: {
								ldapData.useTls = !checked
							}
							TooltipArea{
								tooltipParent:useRow
								text : qsTr('useTLSTooltip')//'Encrypt transactions by LDAP over TLS(StartTLS). You must use \'ldap\' scheme. \'ldaps\' for LDAP over SSL is non-standardized and deprecated.\nStartTLS in an extension to the LDAP protocol which uses the TLS protocol to encrypt communication. \nIt works by establishing a normal - i.e. unsecured - connection with the LDAP server before a handshake negotiation between the server and the web services is carried out. Here, the server sends its certificate to prove its identity before the secure connection is established.'
							}
						}
					}
					FormGroup {
						label: qsTr('useSalLabel')//'Use Sal'
						Switch {
							id: useSal
							anchors.verticalCenter: parent.verticalCenter
							checked: ldapData.useSal
							onClicked: {
								ldapData.useSal = !checked
							}
							TooltipArea{
								tooltipParent:useRow
								//: 'The dns resolution is done by %1 using Sal. It will pass an IP to LDAP. By doing that, the TLS negociation could not check the hostname. You may deactivate the verifications if wanted to force the connection.'
								text : qsTr('useSalTooltip').arg(applicationName)
							}
						}
					}
				}
				FormLine{
					id:useSalRow
					
					FormGroup {
						label: qsTr('verifyTLSLabel')//'Verify Certificates on TLS'
						ComboBox {
							id:verifyServerCertificates
							currentIndex: ldapData.verifyServerCertificates+1
							model: [qsTr('AutoMode'), qsTr('offMode'), qsTr('onMode')]
							width: parent.width
				  
							onActivated: ldapData.verifyServerCertificates = index-1
							TooltipArea{
								text : qsTr('verifyTLSTooltip')//'Specify whether the tls server certificate must be verified when connecting to a LDAP server.'
								//tooltipParent: dialog
							}
						}
					}
				}
			}
			
			// -----------------------------------------------------------------------
			// NAT and Firewall.
			// -----------------------------------------------------------------------
			
			Form {
				title: qsTr('searchTitle')//'Search'
				width: parent.width
				
				FormLine {
					FormGroup {
						label: qsTr('baseObjectLabel')+' *'//'Base Object *'
						TextField {
							id:baseObject
							placeholderText :qsTr('baseObjectPlaceholder')//"Base Object"
							text:ldapData.baseObject
							error : ldapData.baseObjectFieldError
							onTextChanged: Qt.callLater(function(){ldapData.baseObject = text})
							TooltipArea{
								text : qsTr('baseObjectTooltip')//'BaseObject is a specification for LDAP Search Scopes that specifies that the Search Request should only be performed against the entry specified as the search base DN.\n\nNo entries below it will be considered.'
								//tooltipParent: dialog
							}
						}
					}
					
					
				}
				
				FormLine {
					FormGroup {
						id:filterGroup
						label: qsTr('filterLabel')//'Filter'
						TextField {
							id:filter
							text:ldapData.filter
							error : ldapData.filterFieldError
							onTextChanged: Qt.callLater(function(){ldapData.filter = text})
							placeholderText :"(sn=%s)"
							TooltipArea{
								text : qsTr('filterTooltip')//'The search is base on this filter to search friends. Default value : (sn=%s)'
								//tooltipParent: dialog
							}
						}
					}
				}
				
				
				FormLine {
					id:connectionRow
					width:filterGroup.width
					FormGroup {
						label: qsTr('maxResultsLabel')//'Max Results'
						
						NumericField {
							id:maxResults
							text:ldapData.maxResults
							error : ldapData.maxResultsFieldError
							onTextChanged: Qt.callLater(function(){ldapData.maxResults = text})
							TooltipArea{
								tooltipParent:connectionRow
								text : qsTr('maxResultsTooltip')//'The max results when requesting searches'
							}
						}
					}
					FormGroup {
						label: qsTr('timeoutLabel')
						NumericField {
							id:timeout
							text:ldapData.timeout
							error : ldapData.timeoutFieldError
							onTextChanged: Qt.callLater(function(){ldapData.timeout = text})
							TooltipArea{
								tooltipParent:connectionRow
								text : qsTr('timeoutTooltip')//'The connection and search timeout in seconds. Default is 5'
							}
						}
					}
				}
			}
			// -----------------------------------------------------------------------
			// Parsing
			// -----------------------------------------------------------------------
			
			Form {
				id:parsingForm
				title: qsTr('parsingTitle')//'Parsing'
				width: parent.width
				
				FormLine {
					FormGroup {
						label: qsTr('nameAttributesLabel')//'Name Attributes'
						TextField {
							id:nameAttributes
							placeholderText :'sn'
							text:ldapData.nameAttributes
							error : ldapData.nameAttributesFieldError
							onTextChanged: Qt.callLater(function(){ldapData.nameAttributes = text})
							TooltipArea{
								text : qsTr('nameAttributesTooltip')//'Check these attributes To build Name Friend, separated by a comma and the first is the highest priority. The default value is: sn'
								tooltipParent: nameAttributes
							}
						}
					}
				}
				FormLine {
					FormGroup {
						label: qsTr('sipAttributesLabel')//'Sip Attributes'
						TextField {
							id:sipAttributes
							placeholderText :'mobile,telephoneNumber,homePhone,sn'
							text:ldapData.sipAttributes
							error : ldapData.sipAttributesFieldError
							onTextChanged: Qt.callLater(function(){ldapData.sipAttributes = text})
							TooltipArea{
								text : qsTr('sipAttributesTooltip')//'Check these attributes to build the SIP username in address of Friend. Attributes are separated by a comma and the first is the highest priority. The default value is: mobile,telephoneNumber,homePhone,sn'
								tooltipParent: sipAttributes
							}
						}
					}
				}
				FormLine {
					FormGroup {
						label: qsTr('domainLabel')//'Domain'
						TextField {
							id:domain
							placeholderText : AccountSettingsModel.defaultAccountDomain
							text:ldapData.sipDomain
							error : ldapData.sipDomainFieldError
							onTextChanged: Qt.callLater(function(){ldapData.sipDomain = text})
							TooltipArea{
							//: 'Add the domain to the sip address(username@domain).' Tooltip to explain that this field is used to complete a result with this domain.
								text : qsTr('domainTooltip')//
								//tooltipParent: dialog
							}
						}
					}
				}
			}
			
			// -----------------------------------------------------------------------
			// Misc
			// -----------------------------------------------------------------------
			
			Form {
				title: qsTr('miscLabel')//'Misc'
				width: parent.width
				
				FormLine {
					id:miscLine
					FormGroup {
						label: qsTr('debugLabel')//'Debug'
						Switch {
							id: debugMode
							anchors.verticalCenter: parent.verticalCenter
							checked: ldapData.debug
							onClicked: {
								ldapData.debug = !checked
							}
							TooltipArea{
								tooltipParent:miscLine
								//:'Get verbose logs in log file when doing transactions (useful to debug TLS connections)'
								text : qsTr('debugTooltip')
							}
						}
					}
				}
			}
		}
	}
}
