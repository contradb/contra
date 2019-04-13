<template>
  <div class='figure-filter'>
    <select class='figure-filter-op form-control' v-model='op'>
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
    <div v-if="formation">
      <select v-model="formation" class='figure-filter-formation form-control'>
        <option>improper</option>
        <option>Becket *</option>
        <option>Becket cw</option>
        <option>Becket ccw</option>
        <option>proper</option>
        <option>everything else</option>
      </select>
    </div>
    <ul v-if="searchEx.subexpressions.length">
      <li v-for="(subEx, index) in searchEx.subexpressions"><SearchExEditor v-bind:path='path.concat(index)' v-bind:lisp='subEx.toLisp()' /></li>
    </ul>
    <span class='figure-filter-end-of-subfigures'></span>
  </div>
</template>

<script>

import { SearchEx } from 'search_ex.js';

export default {
  name: 'SearchExEditor',
  props: {
    lisp: {
      type: Array,
      required: true
    },
    path: {
      type: Array,
      required: true
    }
  },
  data: function() {
    return {
    };
  },
  computed: {
    searchEx: function() {
      return SearchEx.fromLisp(this.lisp);
    },
    op: {
      get: function() {
        return this.searchEx.op();
      },
      set: function(value) {
        this.$store.commit('setOp', {path: this.path, op: value});
      }
    },
      ...SearchEx.allProps().reduce(function(acc, prop) {
        const mutationName = mutationNameForProp(prop);
        if (prop !== 'subexpressions') {
          acc[prop] = {
            get: function() { return this.searchEx[prop]; },
            set: function(value) {
              const h = {path: this.path};
              h[prop] = value;
              this.$store.commit(mutationName, h);
            }
          };
        }
        return acc;
      }, {})
  }
}

function mutationNameForProp(propertyName) {
  if (propertyName.length >= 1) {
    return 'set' + propertyName.charAt(0).toUpperCase() + propertyName.slice(1);
  } else {
    throw new Error("propertyName is too short");
  }
}

</script>

<style scoped>
</style>
