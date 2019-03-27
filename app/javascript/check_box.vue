<template>
  <div>
    <input type='checkbox' v-model='chk'>
  </div>
</template>

<script>

export default {
  props: ['color'],
  data: function () {
    return {};
  },
  methods: {
  },
  computed: {
    chk: {
      get () {return this.$store.state[this.color];},
      set (value) {
        console.log('commit(set_color'+this.color.toString()+');');
        this.$store.commit('set_color', {color: this.color, value: value});
      }
    }
  }
}
</script>

<style scoped>
</style>
