import { Controller } from '/recourse/stimulus.js'
import { Combobox } from '/recourse/bootstrap.bundle.min.js'

// The plugin keeps a menu's value in a hidden input it creates itself, which
// Turbo's DOM surgery knows nothing about: a morphing refresh deletes the input
// while the instance keeps writing to the detached node, and a snapshot restore
// resurrects an old input beside the one a new instance makes — either way the
// next click submits a filter that is stale, doubled or missing. Owning the
// lifecycle here keeps the input and the instance one thing.
//
// And what a menu with several picks reads as. The plugin writes `2 selected`, which
// says how many and not which; the first pick named and the rest counted says both,
// in the words the locale gives `more`. Written after the plugin writes its own — on
// every change, and once the instance is made — so the plugin's text never shows.
export default class extends Controller {
  static values = { more: String }

  connect() {
    // A restored snapshot arrives with the last visit's input baked in. The
    // instance it belonged to is gone, so it is only a second submission.
    if (!Combobox.getInstance(this.element)) { this.#clearStaleInputs() }

    this.combobox = Combobox.getOrCreateInstance(this.element)
    this.#name()
    this.named = () => this.#name()
    this.element.addEventListener('change.bs.combobox', this.named)
    this.morphed = () => this.#remake()
    document.addEventListener('turbo:morph', this.morphed)
  }

  disconnect() {
    document.removeEventListener('turbo:morph', this.morphed)
    this.element.removeEventListener('change.bs.combobox', this.named)
    this.combobox.dispose()
  }

  // Remade whole rather than repaired: the constructor reads the `.selected`
  // items the morph just made truthful, so disposing and starting over syncs the
  // input, the toggle's text and the listeners in one move.
  #remake() {
    if (!this.element.isConnected) { return }

    this.combobox.dispose()
    this.combobox = Combobox.getOrCreateInstance(this.element)
    this.#name()
  }

  // `California + 1 more` over the plugin's `2 selected`. Only a multiple menu with
  // more than one pick: with one, the plugin already names it, and with none it
  // shows the placeholder.
  #name() {
    const picked = this.element.nextElementSibling.querySelectorAll('.menu-item.selected')
    if (!this.element.dataset.bsMultiple || picked.length < 2) { return }

    const first = picked[0].querySelector('.menu-item-content > span:first-child')
    this.element.querySelector('.combobox-value').textContent = this.moreValue
      .replace('%{first}', first.textContent)
      .replace('%{count}', picked.length - 1)
  }

  #clearStaleInputs() {
    const name = this.element.dataset.bsName

    for (const input of this.element.parentNode.querySelectorAll('input[type="hidden"]')) {
      if (input.name === name) { input.remove() }
    }
  }
}
