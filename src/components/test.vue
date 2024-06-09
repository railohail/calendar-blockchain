<template>
  <div>
    <button
      class="px-4 py-2 rounded border"
      @click.stop.prevent="
        () => {
          addEvent('nani', '2020-08-04', 'bg-red-400')
        }
      "
    >
      Add Fake Event
    </button>
    <v-calendar
      ref="calendar"
      :rows="1"
      :first-day-of-week="2"
      class="w-full rounded-none border-0"
      :masks="{ weekdays: 'WWWW' }"
      :attributes="attributes"
      :key="ghettoUpdate"
    >
      <template v-slot:day-content="props">
        <div v-if="props.day.inMonth" class="h-24 min-h-24">
          <div class="p-2">
            <span class="font-semibold">{{ props.day.day }}</span>
          </div>
          <!-- <button @click="logProps(props)">Log Props</button> -->
          <div v-if="props.attributes">
            <div v-for="event in getEventsForDate(props.day.date)" :key="event.date">
              <div :class="event.class">
                {{ event.name }}
              </div>
            </div>
          </div>
        </div>
      </template>
    </v-calendar>
  </div>
</template>

<script>
export default {
  name: 'EventCalendar',
  data() {
    return {
      ghettoUpdate: 0,
      attributes: [
        {
          key: 'events',
          dates: [],
          customData: {
            events: [],
            class: 'bg-blue-500'
          }
        }
      ]
    }
  },
  mounted() {
    this.$nextTick(() => {
      this.addEvent('hi', '2020-08-04T00:00:00Z', 'bg-blue-500')
    })
  },
  methods: {
    logProps(props) {
      console.log(props)
      return ''
    },
    getEventsForDate(date) {
      const events = this.attributes[0].customData.events
      return events.filter((event) => {
        const eventDate = new Date(event.date)
        return (
          eventDate.getFullYear() === date.getFullYear() &&
          eventDate.getMonth() === date.getMonth() &&
          eventDate.getDate() === date.getDate()
        )
      })
    },
    addEvent(name, date, className) {
      // Create a new date object here with the date fed in
      // Push the date into the list
      this.attributes[0].dates.push(new Date(date))
      // Add the event and date
      this.attributes[0].customData.events.push({
        name: name,
        date: date,
        class: className
      })
      // Calendar does not seem to update here if we update the props, so use a key for now
      this.ghettoUpdate += 1
    }
  }
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
</style>
