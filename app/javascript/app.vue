<template>
  <div id="app">
    Select a figure but not right here!
    <Figure></Figure>

    {{message}}
  </div>
</template>

<script>
import Figure from './figure';
import {moves} from './libfigure/define-figure.js'
console.log('moves', moves())

export default {
  components: {Figure},
  data: function () {
    return {
      message: "Hello Fish!",
      move: 'swing'
    }
  }
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
