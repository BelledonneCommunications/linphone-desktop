import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import App.Styles 1.0

import 'SettingsLdapEdit.js' as Logic

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
	
	//Component.onCompleted: Logic.initForm(ldapData)
	
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
						label: 'Display Name'
						TextField {
							id:displayName
							placeholderText : (serverUrl.text?serverUrl.text:serverUrl.placeholderText)
							text:ldapData.displayName
							onTextChanged: ldapData.displayName = text
							Keys.onReturnPressed:  nextItemInFocusChain().forceActiveFocus()
							TooltipArea{
								text : 'LDAP Server. eg: ldap:/// for a localhost server or ldap://ldap.example.org/'
							}
						}
					}
				}
			}
			
			Form {
				title: 'Connection'
				width: parent.width
				
				FormLine {
					FormGroup {
						label: 'Server URL *'
						TextField {
							id:serverUrl
							placeholderText :"Server"
							text:ldapData.server
							onTextChanged: ldapData.server = text
							Keys.onReturnPressed:  nextItemInFocusChain().forceActiveFocus()
							error : ldapData.serverFieldError
							TooltipArea{
								text : 'LDAP Server. eg: ldap:/// for a localhost server or ldap://ldap.example.org/'
							}
						}
					}
				}
				
				FormLine {
					FormGroup {
						label: 'Bind DN *'
						
						TextField {
							id: bindDn
							placeholderText :"Bind DN"
							text:ldapData.bindDn
							error : ldapData.bindDnFieldError
							onTextChanged: ldapData.bindDn= text
							TooltipArea{
								text : 'The bindDN DN is the credential that is used to authenticate against an LDAP.\n eg: cn=ausername,ou=people,dc=bc,dc=com'
							}
						}
					}
				}
				
				FormLine {
					FormGroup {
						label: 'Password'
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
					FormGroup {
						label: 'Use TLS'
						Switch {
							id: useTls
							anchors.verticalCenter: parent.verticalCenter
							checked: ldapData.useTls
							onClicked: {
								ldapData.useTls = !checked
							}
							TooltipArea{
								tooltipParent:useRow
								text : 'Encrypt transactions by LDAP over TLS(StartTLS). You must use \'ldap\' scheme. \'ldaps\' for LDAP over SSL is non-standardized and deprecated.\nStartTLS in an extension to the LDAP protocol which uses the TLS protocol to encrypt communication. \nIt works by establishing a normal - i.e. unsecured - connection with the LDAP server before a handshake negotiation between the server and the web services is carried out. Here, the server sends its certificate to prove its identity before the secure connection is established.'
							}
						}
					}
					FormGroup {
						label: 'Use Sal'
						Switch {
							id: useSal
							anchors.verticalCenter: parent.verticalCenter
							checked: ldapData.useSal
							onClicked: {
								ldapData.useSal = !checked
							}
							TooltipArea{
								tooltipParent:useRow
								text : 'The dns resolution is done by Linphone using Sal. It will pass an IP to LDAP. By doing that, the TLS negociation could not check the hostname. You may deactivate the verifications if wanted to force the connection.'
							}
						}
					}
				}
				FormLine{
					id:useSalRow
					
					FormGroup {
						label: 'Verify Certificates on TLS'
						ComboBox {
							id:verifyServerCertificates
							currentIndex: ldapData.verifyServerCertificates+1
							model: ["Auto", "Off", "On"]
							width: parent.width
				  
							onActivated: ldapData.verifyServerCertificates = index-1
							TooltipArea{
								text : 'Specify whether the tls server certificate must be verified when connecting to a LDAP server.'
							}
						}
					}
				}
			}
			
			// -----------------------------------------------------------------------
			// NAT and Firewall.
			// -----------------------------------------------------------------------
			
			Form {
				title: 'Search'
				width: parent.width
				
				FormLine {
					FormGroup {
						label: 'Base Object *'
						TextField {
							id:baseObject
							placeholderText :"Base Object"
							text:ldapData.baseObject
							error : ldapData.baseObjectFieldError
							onTextChanged: ldapData.baseObject = text
							TooltipArea{
								text : 'BaseObject is a specification for LDAP Search Scopes that specifies that the Search Request should only be performed against the entry specified as the search base DN.\n\nNo entries below it will be considered.'
							}
						}
					}
					
					
				}
				
				FormLine {
					FormGroup {
						label: 'Filter'
						TextField {
							id:filter
							text:ldapData.filter
							error : ldapData.filterFieldError
							onTextChanged: ldapData.filter = text
							placeholderText :"(sn=%s)"
							TooltipArea{
								text : 'The search is base on this filter to search friends. Default value : (sn=%s)'
							}
						}
					}
				}
				
				FormLine {
					FormGroup {
						label: 'Max Results'
						
						NumericField {
							id:maxResults
							text:ldapData.maxResults
							error : ldapData.maxResultsFieldError
							onTextChanged: ldapData.maxResults = text
							TooltipArea{
								text : 'The max results when requesting searches'
							}
						}
					}
				}
			}
			// -----------------------------------------------------------------------
			// Parsing
			// -----------------------------------------------------------------------
			
			Form {
				title: 'Parsing'
				width: parent.width
				
				FormLine {
					FormGroup {
						label: 'Name Attributes'
						TextField {
							id:nameAttributes
							placeholderText :'sn'
							text:ldapData.nameAttributes
							error : ldapData.nameAttributesFieldError
							onTextChanged: ldapData.nameAttributes = text
							TooltipArea{
								text : 'Check these attributes To build Name Friend, separated by a comma and the first is the highest priority. The default value is: sn'
							}
						}
					}
				}
				FormLine {
					FormGroup {
						label: 'Sip Attributes'
						TextField {
							id:sipAttributes
							placeholderText :'mobile,telephoneNumber,homePhone,sn'
							text:ldapData.sipAttributes
							error : ldapData.sipAttributesFieldError
							onTextChanged: ldapData.sipAttributes = text
							TooltipArea{
								text : 'Check these attributes to build the SIP username in address of Friend. Attributes are separated by a comma and the first is the highest priority. The default value is: mobile,telephoneNumber,homePhone,sn'
							}
						}
					}
				}
				FormLine {
					FormGroup {
						label: 'Scheme'
						TextField {
							id:scheme
							placeholderText :'sip'
							text:ldapData.sipScheme
							error : ldapData.sipSchemeFieldError
							onTextChanged: ldapData.sipScheme = text
							TooltipArea{
								text : 'Add the scheme to the sip address(scheme:username@domain). The default value is sip'
							}
						}
					}
				}
				FormLine {
					FormGroup {
						label: 'Domain'
						TextField {
							id:domain
							placeholderText :'sip.linphone.org'
							text:ldapData.sipDomain
							error : ldapData.sipDomainFieldError
							onTextChanged: ldapData.sipDomain = text
							TooltipArea{
								text : 'Add the domain to the sip address(scheme:username@domain). The default value is sip.linphone.org'
							}
						}
					}
				}
			}
			
			// -----------------------------------------------------------------------
			// Misc
			// -----------------------------------------------------------------------
			
			Form {
				title: 'Misc'
				width: parent.width
				
				FormLine {
					id:miscLine
					FormGroup {
						label: 'Debug'
						Switch {
							id: debugMode
							anchors.verticalCenter: parent.verticalCenter
							checked: ldapData.debug
							onClicked: {
								ldapData.debug = !checked
							}
							TooltipArea{
								tooltipParent:miscLine
								text : 'Get verbose logs in Linphone log file when doing transactions (useful to debug TLS connections)'
							}
						}
					}
				}
			}
		}
	}
}
