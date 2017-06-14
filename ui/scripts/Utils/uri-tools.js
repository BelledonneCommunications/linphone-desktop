// =============================================================================
// Library to deal with URI.
// See: https://tools.ietf.org/html/rfc3986#section-1.3
// =============================================================================

.pragma library

// Options.

// If true, strings starting with `www.` can be detected.
// Not standard but helpful.
var SUPPORTS_URL = true

// Level 0. --------------------------------------------------------------------

var URI_DEC_OCTET = '(?:' +
  '25[0-5]' +
  '|' + '2[0-4]\\d' +
  '|' + '1\\d{2}' +
  '|' + '[1-9]\\d' +
  '|' + '\\d' +
')'

var URI_H16 = '[0-9A-Fa-f]{1,4}'
var URI_PCT_ENCODED = '%[A-Fa-f\\d]{2}'
var URI_PORT =  '\\d*'
var URI_SCHEME = '[a-zA-Z][\\w+\-\.]*'
var URI_SUB_DELIMS = '[!$&\'()*+,;=]'
var URI_UNRESERVED = '[\\w\-\._~]'

// Level 1. --------------------------------------------------------------------

var URI_IPV_FUTURE = 'v[0-9A-Fa-f]+\\.' + '(?:' +
  URI_UNRESERVED +
  URI_SUB_DELIMS +
  ':' +
')'

var URI_IPV4_ADDRESS = URI_DEC_OCTET + '\\.' + URI_DEC_OCTET + '\\.' +
  URI_DEC_OCTET + '\\.' + URI_DEC_OCTET

var URI_PCHAR = '(?:' +
  URI_UNRESERVED +
  '|' + URI_PCT_ENCODED +
  '|' + URI_SUB_DELIMS +
  '|' + '[:@]' +
')'

var URI_REG_NAME = '(?:' +
  URI_UNRESERVED +
  '|' + URI_PCT_ENCODED +
  '|' + URI_SUB_DELIMS +
')*'

var URI_USERINFO = '(?:' +
  URI_UNRESERVED +
  '|' + URI_PCT_ENCODED +
  '|' + URI_SUB_DELIMS +
  '|' + ':' +
')*'

// Level 2. --------------------------------------------------------------------

var URI_FRAGMENT = '(?:' +
  URI_PCHAR +
  '|' + '[/?]' +
')*'

var URI_LS32 = '(?:' +
  URI_H16 + ':' + URI_H16 +
  '|' + URI_IPV4_ADDRESS +
')'

var URI_QUERY = '(?:' +
  URI_PCHAR +
  '|' + '[/?]' +
')*'

var URI_SEGMENT = URI_PCHAR + '*'
var URI_SEGMENT_NZ = URI_PCHAR + '+'

// Level 3. --------------------------------------------------------------------

var URI_IPV6_ADDRESS = '(?:' +
  '(?:' + URI_H16 + ':){6}' + URI_LS32 +
  '|' +  '::(?:' + URI_H16 + ':){5}' + URI_LS32 +
  '|' +  '\\[' + URI_H16 + '\\]::(?:' + URI_H16 + ':){4}' + URI_LS32 +
  '|' +  '\\[' + '(?:' + URI_H16 + ':)?' + URI_H16 + '\\]::(?:' + URI_H16 + ':){3}' + URI_LS32 +
  '|' +  '\\[' + '(?:' + URI_H16 + ':){0,2}' + URI_H16 + '\\]::(?:' + URI_H16 + ':){2}' + URI_LS32 +
  '|' +  '\\[' + '(?:' + URI_H16 + ':){0,3}' + URI_H16 + '\\]::' + URI_H16 + ':' + URI_LS32 +
  '|' +  '\\[' + '(?:' + URI_H16 + ':){0,4}' + URI_H16 + '\\]::' + URI_LS32 +
  '|' +  '\\[' + '(?:' + URI_H16 + ':){0,5}' + URI_H16 + '\\]::' + URI_H16 +
  '|' +  '\\[' + '(?:' + URI_H16 + ':){0,6}' + URI_H16 + '\\]::' +
')'

var URI_PATH_ABEMPTY = '(?:' + '/' + URI_SEGMENT + ')*'

var URI_PATH_ABSOLUTE = '/' +
  '(?:' + URI_SEGMENT_NZ + '(?:' + '/' + URI_SEGMENT + ')*' + ')?'

var URI_PATH_ROOTLESS =
  URI_SEGMENT_NZ + '(?:' + '/' + URI_SEGMENT + ')*'

// Level 4. --------------------------------------------------------------------

var URI_IP_LITERAL = '\\[' +
  '(?:' +
    URI_IPV6_ADDRESS +
    '|' + URI_IPV_FUTURE +
  ')' +
'\\]'

// Level 5. --------------------------------------------------------------------

var URI_HOST = '(?:' +
  URI_REG_NAME +
  '|' + URI_IPV4_ADDRESS +
  '|' + URI_IP_LITERAL +
')'

// Level 6. --------------------------------------------------------------------

var URI_AUTHORITY = '(?:' + URI_USERINFO + '@' + ')?' +
  URI_HOST +
  '(?:' + ':' + URI_PORT + ')?'

// Level 7. --------------------------------------------------------------------

// `path-empty` not used.
var URI_HIER_PART = '(?:' +
  '//' + URI_AUTHORITY + URI_PATH_ABEMPTY +
  '|' + URI_PATH_ABSOLUTE +
  '|' + URI_PATH_ROOTLESS +
')'

// Level 8. --------------------------------------------------------------------

// Regex to match URI. It respects the RFC 3986.
var URI = (SUPPORTS_URL
  ? '(?:' + URI_SCHEME + ':' + '|' + 'www\\.' + ')'
  :  URI_SCHEME + ':'
) + URI_HIER_PART + '(?:' + '\\?' + URI_QUERY + ')?' +
  '(?:' + '#' + URI_FRAGMENT + ')?'

var URI_REGEX = new RegExp('(' + URI + ')', 'g')
