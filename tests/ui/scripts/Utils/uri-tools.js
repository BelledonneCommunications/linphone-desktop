// ===================================================================
// Library to deal with URI.
// ===================================================================

.pragma library

// Options.

// If true, strings starting with `www.` can be detected.
// Not standard but helpful.
var SUPPORTS_URL = true

// Level 0. ----------------------------------------------------------

var URI_PCT_ENCODED = '%[A-Fa-f\\d]{2}'
var URI_PORT =  '\\d*'
var URI_SCHEME = '[a-zA-Z][\\w+\-\.]*'
var URI_SUB_DELIMS = '[!$&\'()*+,;=]'
var URI_UNRESERVED = '[\\w\-\._~]'

// Level 1. ----------------------------------------------------------

var URI_HOST = '(' +
  '(' +
    URI_UNRESERVED +
    '|' + URI_PCT_ENCODED +
    '|' + URI_SUB_DELIMS +
  ')*' +
')'

var URI_PCHAR = '(?:' +
  URI_UNRESERVED +
  '|' + URI_PCT_ENCODED +
  '|' + URI_SUB_DELIMS +
  '|' + '[:@]' +
')'

var URI_USERINFO = '(?:' +
  URI_UNRESERVED +
  '|' + URI_PCT_ENCODED +
  '|' + URI_SUB_DELIMS +
  '|' + ':' +
')*'

// Level 2. ----------------------------------------------------------

var URI_AUTHORITY = '(?:' + URI_USERINFO + '@' + ')?' +
  URI_HOST +
  '(?:' + ':' + URI_PORT + ')?'

var URI_FRAGMENT = '(?:' +
  URI_PCHAR +
  '|' + '[/?]' +
')*'

var URI_QUERY = '(?:' +
  URI_PCHAR +
  '|' + '[/?]' +
')*'

var URI_SEGMENT = URI_PCHAR + '*'
var URI_SEGMENT_NZ = URI_PCHAR + '+'

// Level 3. ----------------------------------------------------------

var URI_PATH_ABEMPTY = '(?:' + '/' + URI_SEGMENT + ')*'

var URI_PATH_ABSOLUTE = '/' +
  '(?:' + URI_SEGMENT_NZ + '(?:' + '/' + URI_SEGMENT + ')*' + ')?'

var URI_PATH_ROOTLESS =
  URI_SEGMENT_NZ + '(?:' + '/' + URI_SEGMENT + ')*'

// Level 4. ----------------------------------------------------------

// `path-empty` not used.
var URI_HIER_PART = '(?:' +
  '//' + URI_AUTHORITY + URI_PATH_ABEMPTY +
  '|' + URI_PATH_ABSOLUTE +
  '|' + URI_PATH_ROOTLESS +
')'

// Level 5. ----------------------------------------------------------

// Regex to match URI. It respects the RFC 3986.
// But many features are not supported like IP format.
var URI = (SUPPORTS_URL
  ? '(?:' + URI_SCHEME + ':' + '|' + 'www\\.' + ')'
  :  URI_SCHEME + ':'
) + URI_HIER_PART + '(?:' + '\\?' + URI_QUERY + ')?' +
'(?:' + '#' + URI_FRAGMENT + ')?'

var URI_REGEX = new RegExp(URI, 'g')

// ===================================================================

/* TODO: Supports:

   URI-reference = URI / relative-ref

   absolute-URI  = scheme ":" hier-part [ "?" query ]

   relative-ref  = relative-part [ "?" query ] [ "#" fragment ]

   relative-part = "//" authority path-abempty
                 / path-absolute
                 / path-noscheme
                 / path-empty

   host          = IP-literal / IPv4address / reg-name

   IP-literal    = "[" ( IPv6address / IPvFuture  ) "]"

   IPvFuture     = "v" 1*HEXDIG "." 1*( unreserved / sub-delims / ":" )

   IPv6address   =                            6( h16 ":" ) ls32
                 /                       "::" 5( h16 ":" ) ls32
                 / [               h16 ] "::" 4( h16 ":" ) ls32
                 / [ *1( h16 ":" ) h16 ] "::" 3( h16 ":" ) ls32
                 / [ *2( h16 ":" ) h16 ] "::" 2( h16 ":" ) ls32
                 / [ *3( h16 ":" ) h16 ] "::"    h16 ":"   ls32
                 / [ *4( h16 ":" ) h16 ] "::"              ls32
                 / [ *5( h16 ":" ) h16 ] "::"              h16
                 / [ *6( h16 ":" ) h16 ] "::"

   h16           = 1*4HEXDIG
   ls32          = ( h16 ":" h16 ) / IPv4address
   IPv4address   = dec-octet "." dec-octet "." dec-octet "." dec-octet

   dec-octet     = DIGIT                 ; 0-9
                 / %x31-39 DIGIT         ; 10-99
                 / "1" 2DIGIT            ; 100-199
                 / "2" %x30-34 DIGIT     ; 200-249
                 / "25" %x30-35          ; 250-255

   reg-name      = *( unreserved / pct-encoded / sub-delims )

   path          = path-abempty    ; begins with "/" or is empty
                 / path-absolute   ; begins with "/" but not "//"
                 / path-noscheme   ; begins with a non-colon segment
                 / path-rootless   ; begins with a segment
                 / path-empty      ; zero characters

   path-noscheme = segment-nz-nc *( "/" segment )

   segment-nz-nc = 1*( unreserved / pct-encoded / sub-delims / "@" )
                 ; non-zero-length segment without any colon ":"

   reserved      = gen-delims / sub-delims
   gen-delims    = ":" / "/" / "?" / "#" / "[" / "]" / "@"
*/
