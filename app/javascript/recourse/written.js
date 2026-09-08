// The mark a write leaves on the row it landed on, and how long it stands for. Two
// things write rows here and both say so this way: a create or an update, which has a
// toast to keep time with, and the square that keeps a row, which has none — so the
// marking is here and the clock belongs to whoever calls it.
export const DELAY = 2000

// Marked, and handed back the way to let it go. Letting go swaps one class for the
// other rather than adding to it: the fade is an animation, and while the first class
// is still on the row it would paint the tint straight back the moment that animation
// ended. Off the row entirely, what paints it afterwards is whatever else the cascade
// says — the tint of a kept row, or nothing.
export function mark(row) {
  if (!row) { return () => {} }

  row.classList.remove('recourse-written-out')
  row.classList.add('recourse-written')

  return () => {
    row.classList.remove('recourse-written')
    row.classList.add('recourse-written-out')
  }
}

// And the same, on a clock of its own, for a write with no message to keep time with.
export function marked(row) {
  const fade = mark(row)

  setTimeout(fade, DELAY)
}
