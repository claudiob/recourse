import { Controller } from '/recourse/stimulus.js'
import { Tooltip } from '/recourse/bootstrap.bundle.min.js'

// The tooltip naming an icon-only heading. Bootstrap never wires one on its own,
// and a Stimulus lifecycle is what survives Turbo redrawing the table: connect
// makes it, disconnect takes it down before the element goes, so a sorted or
// searched table never strands one over an element that left.
export default class extends Controller {
  connect() {
    this.tooltip = Tooltip.getOrCreateInstance(this.element)
  }

  disconnect() {
    this.tooltip.dispose()
  }
}
