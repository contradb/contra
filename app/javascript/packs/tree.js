/* eslint no-console: 0 */
// Run this example by adding <%= javascript_pack_tag 'tree' %> (and
// <%= stylesheet_pack_tag 'tree' %> if you have styles in your component)
// to the head of your layout file,
// like app/views/layouts/application.html.erb.

import Vue from 'vue/dist/vue.esm';
import Vuex from 'vuex/dist/vuex.esm';
import TreeManipulatorGator from '../tree_manipulator_gator.vue';

Vue.use(Vuex);

const store = new Vuex.Store({
  state: {
    tree: ['root', ['branch0'], ['branch1', ['twig']]],
    checked: null
  },
  mutations: {
    // set_color(state, {color, value}) {
    //   state[color] = !state[color];
    // }
    check_mutation(state, {ancestors}) {
      if (JSON.stringify(state.checked) === JSON.stringify(ancestors)) {
        state.checked = null;
      } else {
        state.checked = ancestors;
      }
    }
  }
});

document.addEventListener('DOMContentLoaded', () => {
  var tree = new Vue({
    el: '#tree-app',
    store,
    data: {
    },
    template: `<TreeManipulatorGator v-bind:subtree="$store.state.tree" />`,
    components: {
      TreeManipulatorGator
    }
  });
});
