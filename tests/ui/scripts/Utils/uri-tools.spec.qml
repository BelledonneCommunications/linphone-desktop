import QtTest 1.1

import './uri-tools.js' as UriTools

// =============================================================================

TestCase {
  function test_regexExists () {
    compare(
      UriTools.URI_REGEX instanceof RegExp,
      true,
      '`URI_REGEX` is not a `RegExp` or is undefined.'
    )
  }

  function test_urlSupport () {
    compare(
      typeof UriTools.SUPPORTS_URL,
      'boolean',
      '`SUPPORTS_URL` is not a `Boolean` or is undefined.'
    )
  }

  function test_matchUri_data () {
    return [
      {
        input: 'http://www.LaRmInA.com/',
        output: [ 'http://www.LaRmInA.com/' ]
      }, {
        input: 'http://foob%3Dbar@baz.fr',
        output: [ 'http://foob%3Dbar@baz.fr' ]
      }, {
        input: 'file://a/b/c/;d',
        output: [ 'file://a/b/c/;d' ]
      }, {
        input: 'ftp://0/',
        output: [ 'ftp://0/' ]
      }, {
        input: 'mailto://valentin.cognito@domain.unknown',
        output: [ 'mailto://valentin.cognito@domain.unknown' ]
      }, {
        input: 'mailto://sLimAne@egypt',
        output: [ 'mailto://sLimAne@egypt' ]
      }, {
        input: 'file://beetlejuice-beetlejuice-beetlejui...',
        output: [ 'file://beetlejuice-beetlejuice-beetlejui...' ]
      }, {
        input: 'https://gitlab@localhost',
        output: [ 'https://gitlab@localhost' ]
      }, {
        input: 'xmpp:von.zimmel@reich.org',
        output: [ 'xmpp:von.zimmel@reich.org' ]
      }, {
        input: 'dot.dot://dot.dot.dot@dot.dot.dot',
        output: [ 'dot.dot://dot.dot.dot@dot.dot.dot' ]
      }, {
        input: 'A:B',
        output: [ 'A:B' ]
      }, {
        input: 'foo://a=B.7z*+9aZb;$.!,!,!_(~_~)_-&\':',
        output: [ 'foo://a=B.7z*+9aZb;$.!,!,!_(~_~)_-&\':' ]
      }, {
        input: 'foo+bar+baz://hey:1800/it-s-me?a&b=12',
        output: [ 'foo+bar+baz://hey:1800/it-s-me?a&b=12' ]
      }, {
        input: 'nsa://localhost:666',
        output: [ 'nsa://localhost:666' ]
      }, {
        input: 'protocol://U$3r:p@sswd/WwW.L33t.sp3',
        output: [ 'protocol://U$3r:p@sswd/WwW.L33t.sp3' ]
      }, {
        input: 'http://a/B/c?a&b&c',
        output: [ 'http://a/B/c?a&b&c' ]
      }, {
        input: '1http://www.linphone.org',
        output: [ 'http://www.linphone.org' ]
      }, {
        input: '://www.linphone.org',
        output: UriTools.SUPPORTS_URL
          ? [ 'www.linphone.org' ]
          : null
      }, {
        input: 'http',
        output: null
      }, {
        input: '/path/',
        output: null
      }
    ]
  }

  function test_matchUri (data) {
    compare(data.input.match(UriTools.URI_REGEX), data.output)
  }
}
