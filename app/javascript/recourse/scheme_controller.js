import { Controller } from '/recourse/stimulus.js'

// The sidebar's one control over how a page looks. A click moves it into the mode it is
// not in, which is what the icon promises: a moon while the page is light, a sun while
// it is dark. The choice belongs to the reader rather than to the app, so it is kept in
// their browser — the layout's own script is what puts it back before the first paint,
// a controller connecting far too late for that.
export default class extends Controller {
  static values = { storage: String }

  // Turbo merges the head on a visit, and the layout's script runs only on a full load.
  // The sidebar is drawn again on every visit, so connecting is the moment to say it again.
  connect() {
    const stored = this.#stored()

    if (stored) { this.#apply(stored.mode) }
  }

  // The other mode, remembered.
  rotate() {
    const mode = this.#mode() === 'dark' ? 'light' : 'dark'

    this.#apply(mode)
    localStorage.setItem(this.storageValue, JSON.stringify({ mode }))
  }

  // The mode goes onto the element every `light-dark()` on the page is resolved against.
  // Checked first: the storage is the reader's own, but what comes back out of it is
  // still not something to write onto the page unread.
  #apply(mode) {
    if (mode === 'light' || mode === 'dark') {
      document.documentElement.dataset.bsTheme = mode
    }
  }

  // What the reader picked last, or nothing at all where they never have.
  #stored() {
    try {
      return JSON.parse(localStorage.getItem(this.storageValue))
    } catch (error) {
      return null
    }
  }

  // Which mode the page is in: whatever has been forced onto it, and otherwise whatever
  // the system asks for, since a page nobody has chosen for follows that.
  #mode() {
    return document.documentElement.dataset.bsTheme ||
      (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light')
  }
}
