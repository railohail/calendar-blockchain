<template>
  <VCalendar
    :masks="masks"
    :attributes="attributes"
    class="w-full rounded-none border-0"
    isDark="true"
    ><template v-slot:day-content="{ day, attributes }">
      <div class="flex flex-col h-full z-10 overflow-hidden">
        <span class="day-label text-sm">{{ day.day }}</span>
        <div class="flex-grow overflow-hidden">
          <div class="attribute-container overflow-y-auto">
            <div
              v-for="attr in attributes"
              :key="attr.key"
              class="text-xs leading-tight rounded-sm p-1 mt-0 mb-1 overflow-hidden"
              :class="attr.customData.class"
            >
              {{ attr.customData.title }}
            </div>
          </div>
        </div>
      </div>
    </template>
  </VCalendar>
</template>
<script setup lang="ts">
import { ref } from 'vue'
const month = new Date().getMonth()
const year = new Date().getFullYear()
const masks = ref({
  weekdays: 'WWW'
})
const attributes = ref([
  {
    key: 1,
    customData: {
      title: 'Lunch with mom.',
      class: 'bg-red-600 text-white'
    },
    dates: new Date(year, month, 1)
  },
  {
    key: 2,
    customData: {
      title: 'Take Noah to basketball practice',
      class: 'bg-blue-500 text-white'
    },
    dates: new Date(year, month, 2)
  }
])
</script>
