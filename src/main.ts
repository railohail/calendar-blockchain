import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'

import VCalendar from 'v-calendar'
import 'v-calendar/style.css'
import './assets/styles/index.css'

import Primevue from 'primevue/config'
import 'primeflex/primeflex.css'
import 'primeicons/primeicons.css'
import 'primevue/resources/themes/lara-dark-blue/theme.css'

import VirtualScroller from 'primevue/virtualscroller'
import Ripple from 'primevue/ripple'
import Dialog from 'primevue/dialog'
import InputText from 'primevue/inputtext'

const app = createApp(App)

app.use(createPinia())
app.use(VCalendar, {})
app.use(Primevue, { ripple: true })

app.directive('ripple', Ripple)

app.component('VirtualScroller', VirtualScroller)
app.component('Dialog', Dialog)
app.component('InputText', InputText)

app.mount('#app')
