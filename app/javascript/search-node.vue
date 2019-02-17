<template>
  <div class='figure-filter'>
    <select v-bind:value='tree[0]' v-on:change='setOp' class='figure-filter-op form-control'>
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
    <select v-if='tree[0] === "figure"'
            v-on:change='setFigure'
            v-model='tree[1]'
            class='figure-filter-move form-control'>
      <option value='*'>any figure</option>
      <option v-for='({term, substitution},index) in moveMenu'
              v-bind:value='term'
              v-bind:key='index'>
        {{substitution}}
      </option>
    </select>
  </div>
</template>

<script>
import {moveTermsAndSubstitutionsForSelectMenu} from './libfigure/define-figure.js'

function copyTree(tree) {
  return JSON.parse(JSON.stringify(tree));
}

const ops_with_subexpressions = ['or', 'and', '&', 'then', 'no', 'not', 'all', 'count'];

export default {
  props: ['dialect', 'tree'],
  data: function () {
    return {
      moveMenu: moveTermsAndSubstitutionsForSelectMenu(this.dialect),
    };
  },
  methods: {
    setOp(e) {
      console.log('setOp()');
      const oldTree = this.tree;
      console.log('oldTree = ', oldTree);
      const newTree = copyTree(oldTree);
      newTree[0] = e.target.value;
      const going_to_container = ops_with_subexpressions.includes(newTree[0]);
      const coming_from_container = ops_with_subexpressions.includes(oldTree[0]);
      console.log(coming_from_container, ' -> ', going_to_container, 'oldTree[0] = ', oldTree[0]);
      if (going_to_container) {
        if (coming_from_container) {
          // assume they're all like 'and': 0-n arguments so
          // take no action
        } else {
          newTree.length = 3
          newTree[1] = oldTree;
          newTree[2] = ['figure', '*']
          console.log('splicing tree', newTree);
        }
      } else {
        if (coming_from_container) {
          console.log('not implemented');
        } else {
          console.log('not implemented');
        }
      }
      this.$emit('set-tree', oldTree, newTree);
    },
    setFigure() {
      this.$emit('set-figure', this.tree, this.tree[1])
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
