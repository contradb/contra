<template>
  <div class='figure-filter'>
    <select class='figure-filter-op form-control' v-model='op'>
      <option>figure</option>
      <option>formation</option>
      <option>progression</option>
      <option>or</option>
      <option>and</option>
      <option>&amp;</option>
      <option>then</option>
      <option>no</option>
      <option>not</option>
      <option>all</option>
      <option value='count'>number of</option>
    </select>
    <select v-if="move !== undefined" v-model="move" class="figure-filter-move form-control">
      <option v-for="{term, substitution} in moveMenu" v-bind:value="term">{{substitution}}</option>
    </select>
    <bootstrap-toggle v-if="move !== undefined" v-model="ellipsis" :options="{ on: 'more', off: 'less' }" />
    <select v-if="comparison !== undefined" v-model="comparison" class="figure-filter-count-comparison form-control">
      <option>≥</option>
      <option>≤</option>
      <option>&gt;</option>
      <option>&lt;</option>
      <option>=</option>
      <option>≠</option>
    </select>
    <select v-if="number !== undefined" v-model="number" class="figure-filter-count-number form-control">
      <option v-for="i in [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]">{{ i }}</option>
    </select>
    <select v-if="formation !== undefined" v-model="formation" class='figure-filter-formation form-control'>
      <option>improper</option>
      <option>Becket *</option>
      <option>Becket cw</option>
      <option>Becket ccw</option>
      <option>proper</option>
      <option>everything else</option>
    </select>
    <ul v-if="searchEx.subexpressions.length">
      <li v-for="(subEx, index) in searchEx.subexpressions"><SearchExEditor v-bind:path='path.concat(index)' v-bind:lisp='subEx.toLisp()' /></li>
    </ul>
    <span class='figure-filter-end-of-subfigures'></span>
  </div>
</template>

<script>

import BootstrapToggle from 'vue-bootstrap-toggle';
import { SearchEx } from 'search_ex.js';
import LibFigure from 'libfigure/libfigure.js';

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
    return {};
  },
  computed: {
    searchEx: function() {
      return SearchEx.fromLisp(this.lisp);
    },
    moveMenu: function() {
      return [{term: '*', substitution: 'any figure'}].concat(LibFigure.moveTermsAndSubstitutionsForSelectMenu(this.$store.state.dialect));
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
        const mutationName = SearchEx.mutationNameForProp(prop);
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
  },
  components: {
    BootstrapToggle
  }
}

</script>

<style scoped>
</style>
