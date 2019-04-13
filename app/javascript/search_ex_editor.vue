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
    },
    formation: {
      get: function() { return this.searchEx.formation; },
      set: function(value) { this.$store.commit('setFormation', {path: this.path, formation: value}) }
    }
  }
}
</script>

<style scoped>
</style>
