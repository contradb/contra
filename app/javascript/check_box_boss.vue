<template>
  <div id="checkbox-app">
    this is the check_box_boss
    <CheckBox v-bind:color="'red'" /> Red
    <CheckBox v-bind:color="'red'" /> Red
    <CheckBox v-bind:color="'green'" /> Green
    <CheckBox v-bind:color="'blue'" /> Blue
    <CheckBox v-bind:color="'green'" /> Green
    <CheckBox v-bind:color="'blue'" /> Blue
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
