<template>
  <div>
    This is this figure component and here is a select thing:
    <select>
      <option v-bind:key="index" v-for='({term, substitution},index) in moveMenu' v-bind:value='term'>{{substitution}}</option>

    </select>
  </div>
</template>

<script>
import {moveTermsAndSubstitutionsForSelectMenu} from './libfigure/define-figure.js'

export default {
  props: ['dialect'],
  data: function () {
    return {
      moveMenu: moveTermsAndSubstitutionsForSelectMenu(this.dialect)
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
