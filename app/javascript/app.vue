<template>
  <div id="app">
    Select a figure:
    <select v-model="move">
      <option>swing</option>
      <option>Bar</option>
      <option>Baz</option>
    </select>
  </div>
</template>

<script>
export default {
  data: function () {
    return {
      message: "Hello Fish!",
      move: 'swing'
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
