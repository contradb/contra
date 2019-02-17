<template>
  <div class='figure-filter'>
    <select v-model='operator' class='figure-filter-op form-control'>
      <option>figure</option>
      <option>formation</option>
      <option>progression</option>
      <option>or</option>
      <option>and</option>
      <option>&</option>
      <option>then</option>
      <option>no</option>
      <option>not</option>
      <option>all</option>
      <option value='count'>number of</option>
    </select>
    <select v-on:change='setFigure' v-model='move' class='figure-filter-move form-control'>
      <option v-bind:key="index" v-for='({term, substitution},index) in moveMenu' v-bind:value='term'>
        {{substitution}}
      </option>
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
      operator: this.tree[0],
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
