<template>
  <div id="app">
    Select a figure but not right here!
    <SearchNode v-bind:dialect='dialect'></SearchNode>
  </div>
</template>

<script>
import SearchNode from './search-node';
console.log('moves', moves())

export default {
  components: {SearchNode},
  props: ['dialect'],
  data: function () {
    return {
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
