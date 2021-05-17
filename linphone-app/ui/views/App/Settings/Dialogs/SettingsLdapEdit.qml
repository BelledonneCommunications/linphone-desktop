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
	
	centeredButtons: true
	
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
							onTextChanged: ldapData.displayName = text
							Keys.onReturnPressed:  nextItemInFocusChain().forceActiveFocus()
							TooltipArea{
								text : qsTr('displayNameTooltip')//'The display name of the server to be shown in the list'
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
							onTextChanged: ldapData.server = text
							Keys.onReturnPressed:  nextItemInFocusChain().forceActiveFocus()
							error : ldapData.serverFieldError
							TooltipArea{
								text : qsTr('serverTooltip')//'LDAP Server. eg: ldap:/// for a localhost server or ldap://ldap.example.org/'
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
							onTextChanged: ldapData.bindDn= text
							TooltipArea{
								text : qsTr('bindDNTooltip')//'The bind DN is the credential that is used to authenticate against an LDAP.\n eg: cn=ausername,ou=people,dc=bc,dc=com'
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
							onTextChanged: ldapData.password = text
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
								text : qsTr('useSalTooltip')//'The dns resolution is done by Linphone using Sal. It will pass an IP to LDAP. By doing that, the TLS negociation could not check the hostname. You may deactivate the verifications if wanted to force the connection.'
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
							onTextChanged: ldapData.baseObject = text
							TooltipArea{
								text : qsTr('baseObjectTooltip')//'BaseObject is a specification for LDAP Search Scopes that specifies that the Search Request should only be performed against the entry specified as the search base DN.\n\nNo entries below it will be considered.'
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
							onTextChanged: ldapData.filter = text
							placeholderText :"(sn=%s)"
							TooltipArea{
								text : qsTr('filterTooltip')//'The search is base on this filter to search friends. Default value : (sn=%s)'
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
							onTextChanged: ldapData.maxResults = text
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
							onTextChanged: ldapData.timeout = text
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
							onTextChanged: ldapData.nameAttributes = text
							TooltipArea{
								text : qsTr('nameAttributesTooltip')//'Check these attributes To build Name Friend, separated by a comma and the first is the highest priority. The default value is: sn'
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
							onTextChanged: ldapData.sipAttributes = text
							TooltipArea{
								text : qsTr('sipAttributesTooltip')//'Check these attributes to build the SIP username in address of Friend. Attributes are separated by a comma and the first is the highest priority. The default value is: mobile,telephoneNumber,homePhone,sn'
							}
						}
					}
				}
				FormLine {
					FormGroup {
						label: qsTr('domainLabel')//'Domain'
						TextField {
							id:domain
							placeholderText :'sip.linphone.org'
							text:ldapData.sipDomain
							error : ldapData.sipDomainFieldError
							onTextChanged: ldapData.sipDomain = text
							TooltipArea{
								text : qsTr('domainTooltip')//'Add the domain to the sip address(username@domain). The default value is sip.linphone.org'
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
								text : qsTr('debugTooltip')//'Get verbose logs in Linphone log file when doing transactions (useful to debug TLS connections)'
							}
						}
					}
				}
			}
		}
	}
}
