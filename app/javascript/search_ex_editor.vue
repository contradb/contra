<template>
  <span>
    {{JSON.stringify(lisp)}}
    <ul v-if="searchEx.subexpressions.length">
      <li v-for="(subEx, index) in searchEx.subexpressions"><SearchExEditor v-bind:path='path.concat(index)' v-bind:lisp='subEx.toLisp()' /></li>
    </ul>
  </span>
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
  data: function () {
    return {
    };
  },
  computed: {
    searchEx: function () {
      return SearchEx.fromLisp(this.lisp);
    }
  }
}
</script>

<style scoped>
</style>
