<template>
  <div class='figure-filter'>
    <select v-if='isNumeric' class='figure-filter-op form-control' v-model='op'>
      <option>constant</option>
      <option>tag</option>
    </select>
    <select v-else class='figure-filter-op form-control' v-model='op'>
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
      <option>compare</option>
    </select>
    <select v-if="move !== undefined" v-model="move" class="figure-filter-move form-control">
      <option v-for="{term, substitution} in moveMenu" v-bind:value="term">{{substitution}}</option>
    </select>
    <span v-if="op==='figure' && move !== '*'"><bootstrap-toggle v-model="ellipsis" :options="{ on: 'more', off: 'less' }" /></span>

    <span v-if="left !== undefined"><SearchExEditor v-bind:path='path.concat(0)' v-bind:lisp='left.toLisp()' /></span>

    <select v-if="comparison !== undefined" v-model="comparison" class="figure-filter-count-comparison form-control">
      <option>≥</option>
      <option>≤</option>
      <option>&gt;</option>
      <option>&lt;</option>
      <option>=</option>
      <option>≠</option>
    </select>

    <span v-if="right !== undefined"><SearchExEditor v-bind:path='path.concat(1)' v-bind:lisp='right.toLisp()' /></span>

    <select v-if="number !== undefined" v-model="number" class="figure-filter-count-number form-control">
      <option v-for="i in [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,20,22,24,26,28,30,32,40,48,56,64,80,96]">{{ i }}</option>
    </select>

    <select v-if="op==='tag'" v-model="tag" class="figure-filter-count-number form-control">
      <option v-for="tagName in this.$store.state.tagNames">{{ tagName }}</option>
    </select>

    <select v-if="formation !== undefined" v-model="formation" class='figure-filter-formation form-control'>
      <option>improper</option>
      <option>Becket *</option>
      <option>Becket cw</option>
      <option>Becket ccw</option>
      <option>proper</option>
      <option>everything else</option>
    </select>
    <div class="btn-group">
      <button type="button" class="btn btn-default dropdown-toggle figure-filter-menu-hamburger" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
        <span class="glyphicon glyphicon-option-vertical" aria-label="expression actions"></span>
      </button>
      <ul class="dropdown-menu figure-filter-menu">
        <li><a href="#">Action</a></li>
        <li><a href="#">Another action</a></li>
        <li><a href="#">Something else here</a></li>
        <li v-if="deleteEnabled()"><a class='figure-filter-menu-delete'v-on:click="clickDelete()">X</a></li>
      </ul>
    </div>
    <table v-if="ellipsis" class='figure-filter-accordion'>
      <tr v-for="(formalParameter, parameterIndex) in formalParameters(move)" class='chooser-row'>
        <td class="chooser-label-text">
          {{ parameterLabel(move, parameterIndex) }}
        </td>
        <td>
          <SearchChooser :formal-parameter='formalParameter' :path='path' :parameterIndex='parameterIndex' :lisp='lisp'/>
        </td>
      </tr>
    </table>
    <ul v-if="subordinateSubexpressionLayout">
      <li v-for="(subEx, index) in searchEx.subexpressions"><SearchExEditor v-bind:path='path.concat(index)' v-bind:lisp='subEx.toLisp()' /></li>
    </ul>
    <span class='figure-filter-end-of-subfigures'></span>
  </div>
</template>

<script>

import LibFigure from 'libfigure/libfigure.js';
import { SearchEx, NumericEx } from 'search_ex.js';
import SearchChooser from 'search_chooser.vue'
import BootstrapToggle from 'vue-bootstrap-toggle';


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
    parentSearchEx: function() {
      if (0 === this.path.length)
        return null;
      else {
        let ancestor = this.$store.getters.searchEx;
        for (let i=0; i<this.path.length-1; i++)
          ancestor = ancestor.subexpressions[this.path[i]];
        return ancestor;
      }
    },
    isNumeric: function() {
      return this.searchEx instanceof NumericEx;
    },
    subordinateSubexpressionLayout: function() {
      let searchEx = this.searchEx;
      return searchEx.subexpressions.length && !searchEx.left && !searchEx.right
    },
    moveMenu: function() {
      return [{term: '*', substitution: 'any figure'}].concat(LibFigure.moveTermsAndSubstitutionsForSelectMenu(this.$store.state.dialect));
    },
    op: {
      get: function() {
        return this.searchEx.op();
      },
      set: function(value) {
        this.$store.dispatch('setOp', {path: this.path, op: value});
      }
    },
    left: { get: function() {return this.searchEx.left;} },
    right: { get: function() {return this.searchEx.right;} },
      ...SearchEx.allProps().reduce(function(acc, prop) {
        const mutationName = SearchEx.mutationNameForProp(prop);
        if (prop !== 'subexpressions') {
          acc[prop] = {
            get: function() { return this.searchEx[prop]; },
            set: function(value) {
              const h = {path: this.path};
              h[prop] = value;
              this.$store.dispatch(mutationName, h);
            }
          };
        }
        return acc;
      }, {})
  },
  methods: {
    formalParameters: LibFigure.formalParameters,
    parameterLabel: LibFigure.parameterLabel,
    clickDelete: function() {
      this.$store.dispatch('deleteSearchEx', {path: this.path});
    },
    deleteEnabled: function() {
      return this.path.length && this.parentSearchEx.subexpressions.length > this.parentSearchEx.minSubexpressions();
    }
  },
  components: {
    BootstrapToggle,
    SearchChooser,
  }
}

</script>

<style scoped>
</style>
