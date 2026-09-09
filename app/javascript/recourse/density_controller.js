import { Controller } from '/recourse/stimulus.js'

// The arrows at the foot of the sidebar, drawn on a phone alone: a tap puts the words
// back beside every icon the chrome shows — the sidebar's entries, the crumbs, the tabs,
// the foot's own controls — and the next tap takes them away again. The choice goes to
// the server in a cookie, the way the zone does, and the page is asked for again rather
// than reshaped in place: Safari left the row of entries where it was when the words
// came out of hiding, one link over the next, until a reload laid it out afresh.
export default class extends Controller {
  static values = { storage: String }

  toggle() {
    const expanded = document.body.classList.contains('recourse-expanded')
    const density = expanded ? 'compact' : 'expanded'

    document.cookie = `${this.storageValue}=${density}; path=/; max-age=31536000; samesite=lax`
    window.Turbo.visit(window.location.href, { action: 'replace' })
  }
}
