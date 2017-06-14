// =============================================================================
// `ListForm.qml` Logic.
// =============================================================================

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function setData (data) {
  var model = values.model

  model.clear()
  data.forEach(function (data) {
    model.append({ $value: data, $isInvalid: false })
  })
}

function setInvalid (index, status) {
  Utils.assert(
    index >= 0 && index < values.model.count,
    'Index ' + index + 'not exists.'
  )

  values.model.setProperty(index, '$isInvalid', status)
}

function updateValue (index, value) {
  var model = values.model

  // Unable to set property directly. Qt uses a cache of the value.
  // It's necessary to remove then insert.
  model.remove(index)
  model.insert(index, {
    $isInvalid: false,
    $value: value
  })
}

// -----------------------------------------------------------------------------

function addValue (value) {
  values.model.append({ $value: value, $isInvalid: false })

  if (value.length === 0) {
    addButton.enabled = false
  }
}

function handleEditionFinished (index, text) {
  var model = values.model
  var oldValue = model.get(index).$value

  if (text.length === 0) {
    // No changes. It must exists at least n min values.
    if (minValues != null && minValues >= model.count) {
      updateValue(index, oldValue)
      return
    }

    model.remove(index)

    if (oldValue.length !== 0) {
      listForm.removed(index, oldValue)
    }
  } else if (text !== oldValue) {
    // Update changes.
    updateValue(index, text)
    listForm.changed(index, oldValue, text)
  }

  addButton.enabled = true
}

function handleItemCreation () {
  if (this.text.length === 0) {
    // FIXME: Find the source of this problem.
    //
    // Magic code. If it's the first inserted value,
    // an event or a callback steal the item focus.
    // I suppose it's an internal Qt qml event...
    //
    // So, I choose to run a callback executed after this
    // internal event.
    Utils.setTimeout(values, 0, this.forceActiveFocus)
  }
}
