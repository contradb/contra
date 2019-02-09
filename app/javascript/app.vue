<template>
  <div id="app">
    Select a figure:
    <Figure></Figure>

    {{message}}
  </div>
</template>

<script>
import Figure from './figure'

export default {

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
