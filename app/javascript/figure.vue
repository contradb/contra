<template>
  <div>
    This is this figure component and here is a select thing:
    <select>
      <option v-bind:key="move" v-for='move in moveList'>{{move}}</option>

    </select>
  </div>
</template>

<script>
import {moves} from './libfigure/define-figure.js'
// console.log('moves', moves())

// const moveList = moves();

export default {
  data: function () {
    return {
      moveList: moves()
    };
  }
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
