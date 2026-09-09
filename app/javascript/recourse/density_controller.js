import { Controller } from '/recourse/stimulus.js'

// The arrows at the foot of the sidebar, drawn on a phone alone: a tap puts the words
// back beside every icon the chrome shows — the sidebar's entries, the crumbs, the tabs,
// the foot's own controls — and the next tap takes them away again. The choice goes to
// the server in a cookie, the way the zone does, so the next page is drawn with the
// words in rather than drawn without them and widened once a script runs.
export default class extends Controller {
  static values = { storage: String }

  toggle() {
    const expanded = document.body.classList.toggle('recourse-expanded')
    const density = expanded ? 'expanded' : 'compact'

    document.cookie = `${this.storageValue}=${density}; path=/; max-age=31536000; samesite=lax`
  }
}
