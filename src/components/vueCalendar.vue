<template>
  <div class="p-4">
    <Button class="px-4 py-2 rounded border mb-4" label="Add activity" @click="visible = true" />
    <Dialog
      v-model:visible="visible"
      position="left"
      modal
      header="EVENT"
      :style="{ width: '25rem' }"
    >
      <div class="p-fluid">
        <div class="p-field mb-4">
          <label for="activity" class="font-semibold">Activity</label>
          <InputText id="activity" v-model="activity" autocomplete="off" />
        </div>
        <div class="p-field mb-4">
          <label for="date" class="font-semibold">Date</label>
          <Calendar v-model="date" dateFormat="dd/mm/yy" />
        </div>
        <div class="p-field mb-4">
          <label class="font-semibold">Color</label>
          <div class="p-d-flex p-flex-wrap">
            <div v-for="color in colors" :key="color.value" class="p-field-checkbox mr-3">
              <RadioButton :id="color.value" :value="color.value" v-model="selectedColor" />
              <label :for="color.value" class="ml-2" :class="color.textClass">{{
                color.label
              }}</label>
            </div>
          </div>
        </div>
      </div>

      <template #footer>
        <div class="p-d-flex p-jc-end">
          <Button class="p-button-secondary mr-2" label="Cancel" @click="visible = false"></Button>
          <Button label="Save" @click="saveEvent"></Button>
        </div>
      </template>
    </Dialog>
    <v-calendar
      ref="calendar"
      :rows="1"
      :first-day-of-week="2"
      class="w-full rounded-none border-0"
      :masks="{ weekdays: 'WWWW' }"
      :attributes="attributes"
      :key="ghettoUpdate"
      :isDark="true"
    >
      <template v-slot:day-content="props">
        <div v-if="props.day.inMonth" class="h-24 min-h-24">
          <div class="p-2">
            <span class="font-semibold">{{ props.day.day }}</span>
          </div>

          <template v-if="props.attributes">
            <VirtualScroller
              :items="getEventsForDate(props.day.date)"
              :itemSize="30"
              :buffer="2"
              class="event-scroller"
            >
              <template v-slot:item="{ item, index }">
                <div :key="index" :class="[item.class, 'event-item']">
                  <div class="p-d-flex p-ai-center p-jc-between">
                    <span class="text-truncate">{{ item.name }}</span>
                    <div class="p-d-flex p-jc-end">
                      <!-- Add p-jc-end class here -->
                      <Button
                        class="p-button-text p-button-sm p-mr-1"
                        style="width: 20px"
                        icon="pi pi-pencil"
                        @click="editEvent(getEventIndex(item))"
                      ></Button>
                      <Button
                        class="p-button-text p-button-sm"
                        icon="pi pi-trash"
                        style="width: 20px"
                        @click="deleteEvent(getEventIndex(item))"
                      ></Button>
                    </div>
                  </div>
                </div>
              </template>
            </VirtualScroller>
          </template>
        </div>
      </template>
    </v-calendar>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import Calendar from 'primevue/calendar'
import RadioButton from 'primevue/radiobutton'
import Button from 'primevue/button'
import Web3 from 'web3'
import MyContractArtifact from '../../truffle/build/contracts/MyContract.json'

const web3 = ref(null)
const accounts = ref([])
const myContract = ref(null)
const editIndex = ref(null)
const visible = ref(false)
const date = ref()
const calendar = ref(null)
const ghettoUpdate = ref(0)
const activity = ref('')
const selectedColor = ref('bg-yellow-400')
const colors = ref([
  { label: 'Yellow', value: 'bg-yellow-400', textClass: 'text-yellow-400' },
  { label: 'Blue', value: 'bg-blue-400', textClass: 'text-blue-400' },
  { label: 'Green', value: 'bg-green-400', textClass: 'text-green-400' },
  { label: 'Red', value: 'bg-red-400', textClass: 'text-red-400' },
  { label: 'Purple', value: 'bg-purple-400', textClass: 'text-purple-400' }
])

const attributes = ref([
  {
    key: 'events',
    dates: [],
    customData: {
      events: []
    }
  }
])
const getEventIndex = (event) => {
  return attributes.value[0].customData.events.findIndex(
    (e) => e.name === event.name && e.date.getTime() === event.date.getTime()
  )
}
const editEvent = async (index) => {
  const event = attributes.value[0].customData.events[index]
  if (event) {
    activity.value = event.name
    date.value = new Date(event.date)
    selectedColor.value = event.class
    editIndex.value = index
    visible.value = true
  }
}

const deleteEvent = async (index) => {
  try {
    console.log('Deleting event with index:', index)
    await myContract.value.methods.deleteEvent(parseInt(index)).send({ from: accounts.value[0] })
    await fetchEvents()
  } catch (error) {
    console.error('Error deleting event:', error)
    // Log additional information about the error
    console.log('Index:', index)
    console.log('Accounts:', accounts.value)
    console.log('Contract:', myContract.value)
  }
}

const saveEvent = async () => {
  if (activity.value && date.value) {
    try {
      const timestamp = Math.floor(new Date(date.value).getTime() / 1000)
      if (editIndex.value !== null) {
        await myContract.value.methods
          .editEvent(editIndex.value, activity.value, timestamp, selectedColor.value)
          .send({ from: accounts.value[0] })
        editIndex.value = null
      } else {
        await myContract.value.methods
          .addEvent(activity.value, timestamp, selectedColor.value)
          .send({ from: accounts.value[0] })
      }
      activity.value = ''
      date.value = null
      selectedColor.value = 'bg-yellow-400'
      visible.value = false
      await fetchEvents()
    } catch (error) {
      console.error('Error saving event:', error)
    }
  }
}
const fetchEvents = async () => {
  try {
    const eventsCount = await myContract.value.methods.getEventsCount().call()
    const fetchedEvents = []

    for (let i = 0; i < Number(eventsCount); i++) {
      const event = await myContract.value.methods.getEvent(i).call()
      fetchedEvents.push({
        name: event[0],
        date: new Date(Number(event[1]) * 1000),
        class: event[2]
      })
    }

    attributes.value[0].customData.events = fetchedEvents
    ghettoUpdate.value += 1
  } catch (error) {
    console.error('Error fetching events:', error)
  }
}

onMounted(async () => {
  // Initialize Web3
  if (window.ethereum) {
    web3.value = new Web3(window.ethereum)
    try {
      // Request account access if needed
      await window.ethereum.enable()
      // Get user accounts
      accounts.value = await web3.value.eth.getAccounts()
    } catch (error) {
      console.error('User denied account access')
    }
  }
  // Initialize the contract
  const networkId = await web3.value.eth.net.getId()
  const deployedNetwork = MyContractArtifact.networks[networkId]
  myContract.value = new web3.value.eth.Contract(
    MyContractArtifact.abi,
    deployedNetwork && deployedNetwork.address
  )

  // Fetch events from the blockchain
  await fetchEvents()
})
const getEventsForDate = (date) => {
  const events = attributes.value[0].customData.events
  const filteredEvents = events.filter((event) => {
    const eventDate = new Date(event.date)
    return (
      eventDate.getFullYear() === date.getFullYear() &&
      eventDate.getMonth() === date.getMonth() &&
      eventDate.getDate() === date.getDate()
    )
  })
  return filteredEvents
}
</script>

<style>
.vc-day:not(.on-right) {
  border-right: 1px solid rgb(226, 232, 240);
}
.vc-day:not(.on-left) {
  border-right: 1px solid rgb(226, 232, 240);
}
.vc-day:not(.on-bottom) {
  border-bottom: 1px solid rgb(226, 232, 240);
}
.vc-text-sm {
  font-size: 14px !important;
}
.event-scroller {
  position: absolute;
  top: 30px;
  left: 0;
  right: 0;
  bottom: 0;
  height: calc(100% - 30px);
}
.event-item {
  margin: 2px;
  border-radius: 4px;
  padding: 2px 4px;
}
.text-truncate {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 150px; /* Adjust the max-width as needed */
}
</style>
