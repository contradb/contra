<template>
  <div id="app">
    Select a figure but not right here!
    <SearchNode v-bind:dialect='dialect' v-bind:tree="tree" v-on:set-figure='setFigure'></SearchNode>
  </div>
</template>

<script>
import SearchNode from './search-node';

export default {
  components: {SearchNode},
  props: ['dialect'],
  data: function () {
    return {
      tree: ['figure', 'swing']
    }
  },
  methods: {
    setFigure(tree, move) {
      this.tree[1] = move;
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
