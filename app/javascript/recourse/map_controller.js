import { Controller } from '/recourse/stimulus.js'

// This page of a table on a Google map: every place whose ID is among the rows has its
// area filled in, and the map is fitted round them. The key and the map are the host's,
// read from its credentials; the places are the page's.
export default class extends Controller {
  static values = { key: String, id: String, places: Array }

  async connect() {
    load(this.keyValue)
    const { Map } = await google.maps.importLibrary('maps')
    const { Place } = await google.maps.importLibrary('places')
    const { LatLngBounds } = await google.maps.importLibrary('core')

    const map = new Map(this.element, {
      mapId: this.idValue, gestureHandling: 'none', zoomControl: false,
      disableDefaultUI: true, keyboardShortcuts: false
    })
    const places = new Set(this.placesValue)

    // Counties are the second administrative level, and the layer styles every one
    // Google knows: a function saying which of them are ours is what fills them in.
    map.getFeatureLayer('ADMINISTRATIVE_AREA_LEVEL_2').style = ({ feature }) => {
      if (places.has(feature.placeId)) return FILLED
    }

    const bounds = new LatLngBounds()
    const viewports = [...places].map(id => {
      const place = new Place({ id })
      return place.fetchFields({ fields: ['viewport'] })
                  .then(() => { if (place.viewport) bounds.union(place.viewport) })
                  .catch(console.error)
    })
    await Promise.all(viewports)
    if (!bounds.isEmpty()) map.fitBounds(bounds, 10)
  }
}

const FILLED = {
  strokeColor: '#2D85FF', strokeOpacity: 1.0, strokeWeight: 3.0,
  fillColor: '#2D85FF', fillOpacity: 0.5
}

// Google's own bootstrap, spelled out: `importLibrary` fetches the API the first time
// it is asked for a library, and the API then answers it itself. Once per page, however
// many maps are on it — and a Turbo visit keeps the page, so once per session in practice.
function load(key) {
  const maps = (window.google ||= {}).maps ||= {}
  if (maps.importLibrary) return

  let loading
  maps.importLibrary = (library, ...rest) => {
    loading ||= new Promise((resolve, reject) => {
      const script = document.createElement('script')
      const params = new URLSearchParams({ key, v: 'weekly', loading: 'async', callback: 'google.maps.__ib__' })
      script.src = `https://maps.googleapis.com/maps/api/js?${params}`
      maps.__ib__ = resolve
      script.onerror = () => reject(new Error('The Google Maps API could not be loaded'))
      document.head.append(script)
    })
    return loading.then(() => maps.importLibrary(library, ...rest))
  }
}
