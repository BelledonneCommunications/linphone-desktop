import QtQuick 2.7
import QtTest 1.1

// Explicit import, `utils.js` is not accessible in resources file
// when tests are executed.
import './utils.js' as Utils

TestCase {
  name: 'UtilsTests'

  function test_snakeToCamel_data () {
    return [
      { input: 'foo_bar', output: 'fooBar' },
      { input: 'george_abitbol', output: 'georgeAbitbol' },
      { input: 'billTremendousAndHubert', output: 'billTremendousAndHubert' },
      { input: 'foo_bAr_BAZ', output: 'fooBArBAZ' },
    ]
  }

  function test_snakeToCamel (data) {
    compare(Utils.snakeToCamel(data.input), data.output)
  }
}
