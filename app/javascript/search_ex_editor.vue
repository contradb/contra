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
    <ul v-if="searchEx.subexpressions.length">
      <li v-for="(subEx, index) in searchEx.subexpressions"><SearchExEditor v-bind:path='path.concat(index)' v-bind:lisp='subEx.toLisp()' /></li>
    </ul>
    <span class='figure-filter-end-of-subfigures'></span>
  </div>
</template>

<script>



export default {
  name: 'SearchExEditor',
  props: {
    lisp: {
      type: Array,
      required: true
    },
    // searchEx: {
    //   type: Object,
    //   required: true
    // },
    path: {
      type: Array,
      required: true
    }
  },
  // components: {CheckBox},
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
        // this.$store.commit('check_mutation', {ancestors: this.ancestors});
        console.log('computed op set got value: ', value);
        this.$store.commit('setOp', {path: this.path, op: value});
      }
    }
  }
}
</script>

<style scoped>
</style>
