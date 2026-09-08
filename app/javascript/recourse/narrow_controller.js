import { Controller } from '/recourse/stimulus.js'

// One menu narrowed by another: the states picked on the left leave only their
// counties on the right. The narrowing menu's `change.bs.combobox` is routed here, and
// every option or group heading carrying a `data-narrow-key` is kept or held back by
// whether its key is among the values picked — one value from a single menu, a list
// from a multiple one, and nothing picked means nothing held back. Held back with
// `d-none`, which the plugin's own search leaves alone: it filters by `style.display`,
// and resets that on every open.
export default class extends Controller {
  // Bootstrap's `trigger` writes what it was handed onto the event itself rather than
  // under `detail`, so the value is the event's own property.
  pick(event) {
    const keys = [event.value].flat().filter(key => key !== '')

    for (const option of this.element.querySelectorAll('[data-narrow-key]')) {
      option.classList.toggle('d-none', keys.length > 0 && !keys.includes(option.dataset.narrowKey))
    }
  }
}
