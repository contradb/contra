<template>
  <div id="checkbox-app">
    this is the check_box_boss
    <CheckBox v-bind:state=red />
    <CheckBox v-bind:state=green />
    <CheckBox v-bind:state=blue />
  </div>
</template>

<script>
import CheckBox from './check_box';

export default {
  components: {CheckBox},
  data: function () {
    return {
      red: false,
      green: false,
      blue: false
    };
  },
  methods: {
  }
}
</script>

<style scoped>
</style>
