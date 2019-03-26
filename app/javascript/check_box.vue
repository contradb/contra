<template>
  <div>
    <input type='checkbox' v-model:value='state'/>
  </div>
</template>

<script>

export default {
  props: ['state'],
  data: function () {
    return {
    };
  },
  methods: {
  }
}
</script>

<style scoped>
</style>
