<template>
  <span>
    <input type='checkbox' v-model='checked'>
    {{self}}
    <ul v-if="children.length">
      <li v-for="(child, index) in children"><TreeManipulatorGator v-bind:ancestors='ancestors.concat(index)' v-bind:subtree='child' /></li>
    </ul>
  </span>
</template>

<script>

export default {
  name: 'TreeManipulatorGator',
  props: {
    ancestors: {
      type: Array,              // of int
      required: false,
      default: ()=>[]           // root node
    },
    subtree: {
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
    self: function() {
      return this.subtree[0];
    },
    children: function() {
      return this.subtree.slice(1);
    },
    checked: {
      get () {return JSON.stringify(this.$store.state.checked) === JSON.stringify(this.ancestors);},
      set (value) {
        this.$store.commit('check_mutation', {ancestors: this.ancestors});
      }
    }
  }
}
</script>

<style scoped>
</style>
