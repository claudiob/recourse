import { Dialog } from '/recourse/bootstrap.bundle.min.js'

// Turbo hands over the whole warning as one string. The first line is the question
// and each remaining line a paragraph — real paragraphs here, where a confirm() box
// had newlines. Always textContent, never innerHTML: the title carries a record's
// own name, and a name is data.
export default function confirm(message) {
  const dialog = document.querySelector('#recourse-confirm')
  const [title, ...lines] = message.split('\n')
  dialog.querySelector('.dialog-title').textContent = title
  dialog.querySelector('.dialog-body').replaceChildren(...paragraphs(lines))

  return new Promise(resolve => {
    // `onclick` rather than addEventListener: reassigning replaces the previous
    // answer's handler, so asking twice on one page never wires the button twice.
    dialog.querySelector('.recourse-confirm-delete').onclick = () => {
      resolve(true)
      Dialog.getOrCreateInstance(dialog).hide()
    }
    // Cancel, Esc and a click on the backdrop all close through here. After a
    // Delete the promise is settled, and settling it again is a no-op.
    dialog.addEventListener('hidden.bs.dialog', () => resolve(false), { once: true })
    Dialog.getOrCreateInstance(dialog).show()
  })
}

function paragraphs(lines) {
  return lines.filter(line => line).map(line => {
    const paragraph = document.createElement('p')
    paragraph.textContent = line
    return paragraph
  })
}

// Three things outlive a Turbo visit that starts mid-close: the snapshot, which would
// restore an open dialog; `dialog-open` on <html>, which is the scroll lock; and
// `hiding` on the dialog, the class its closing animation runs under. dispose() closes
// instantly and lifts the lock, but cuts the animation short of the end that would
// have taken `hiding` off — and a dialog still wearing it opens invisible the next
// time it is asked, which on a table of Remove buttons is the very next click. In the
// module, so it registers once.
document.addEventListener('turbo:before-cache', () => {
  const dialog = document.querySelector('#recourse-confirm')
  if (dialog?.open) Dialog.getOrCreateInstance(dialog).dispose()
  dialog?.classList.remove('hiding')
})
