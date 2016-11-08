// ===================================================================
// Library to deal with URI.
// ===================================================================

// Level 0. ----------------------------------------------------------

var URI_PCT_ENCODED = '(%[[:xdigit:]]{2})'
var URI_PORT =  '([\\d]*)'
var URI_SCHEME = '([[:alpha:]][[:alnum:]+\\-.]*)'
var URI_SUB_DELIMS = '[!$&\'()*+,;=]'
var URI_UNRESERVED = '[[:alnum:]\\-._~]'

// Level 1. ----------------------------------------------------------

var URI_HOST = '(' +
  '(' +
    URI_UNRESERVED +
    '|' + URI_PCT_ENCODED +
    '|' + URI_SUB_DELIMS +
  ')*' +
')'

var URI_PCHAR = '(' +
  URI_UNRESERVED +
  '|' + URI_PCT_ENCODED +
  '|' + URI_SUB_DELIMS +
  '|' + '[:@]' +
')'


var URI_USERINFO = '(' +
  '(' +
    URI_UNRESERVED +
    '|' + URI_PCT_ENCODED +
    '|' + URI_SUB_DELIMS +
    '|' + ':' +
  ')*' +
')'

// Level 2. ----------------------------------------------------------

var URI_AUTHORITY = '(' +
  '(' +
    URI_USERINFO + '@' +
  ')?' + URI_HOST + '(' +
    ':' + URI_PORT +
  ')?' +
')'

var URI_FRAGMENT = '(' +
  '(' +
    URI_PCHAR +
    '|' + '[/?]' +
  ')*' +
')'


var URI_QUERY = '(' +
  '(' +
    URI_PCHAR +
    '|' + '[/?]' +
  ')*' +
')'

var URI_SEGMENT = '(' + URI_PCHAR + '*' + ')'
var URI_SEGMENT_NZ = '(' + URI_PCHAR + '+' + ')'

// Level 3. ----------------------------------------------------------

var URI_PATH_ABEMPTY = '(' + '(' + '/' + URI_SEGMENT + ')*' + ')'

var URI_PATH_ABSOLUTE = '(' +
  '/' + '(' +
    URI_SEGMENT_NZ + '(' + '/' + URI_SEGMENT + ')*' +
  ')?' +
')'

var URI_PATH_ROOTLESS = '(' +
  URI_SEGMENT_NZ + '(' + '/' + URI_SEGMENT + ')*' +
')'

// Level 4. ----------------------------------------------------------

var URI_HIER_PART = '(' +
  '//' + URI_AUTHORITY + URI_PATH_ABEMPTY +
  '|' + URI_PATH_ABSOLUTE +
  '|' + URI_PATH_ROOTLESS +
')'

// Level 5. ----------------------------------------------------------

// Regex to match URI. It respects the RFC 3986.
var URI_REGEX = '(' +
  URI_SCHEME + ':' + URI_HIER_PART + '(' +
    '\\?' + URI_QUERY +
  ')?' + '(' + '#' + URI_FRAGMENT + ')?' +
')'

// ===================================================================

function test () {
  console.log(URI_REGEX)
}
test()
