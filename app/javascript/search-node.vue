<template>
  <div>
    This is this figure component and here is a select thing:
    <select v-on:change='setFigure' v-model='move'>
      <option v-bind:key="index" v-for='({term, substitution},index) in moveMenu' v-bind:value='term'>{{substitution}}</option>

    </select>
  </div>
</template>

<script>
import {moveTermsAndSubstitutionsForSelectMenu} from './libfigure/define-figure.js'

export default {
  props: ['dialect', 'tree'],
  data: function () {
    return {
      moveMenu: moveTermsAndSubstitutionsForSelectMenu(this.dialect),
      move: this.tree[1]
    };
  },
  methods: {
    setFigure(x) {
      this.$emit('set-figure', this.tree, this.move)
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
