// Run this example by adding <%= javascript_pack_tag 'tree' %> (and
// <%= stylesheet_pack_tag 'tree' %> if you have styles in your component)
// to the head of your layout file,
// like app/views/layouts/application.html.erb.

import Vue from 'vue/dist/vue.esm';
import Vuex from 'vuex/dist/vuex.esm';
import { SearchEx } from '../search_ex.js';
import SearchExEditor from '../search_ex_editor.vue';

window.SearchEx = SearchEx;

Vue.use(Vuex);

const store = new Vuex.Store({
  state: {
    lisp: ['and', ['figure', '*'], ['progression']]
  },
  getters: {
    searchEx: state => SearchEx.fromLisp(state.lisp)
  },
  mutations: {
    // set_color(state, {color, value}) {
    //   state[color] = !state[color];
    // }
    setOp(state, {path, op}) {
      const searchEx = SearchEx.fromLisp(state.lisp); // argh! no getter access in mutations because ... reasons
      state.lisp = setSearchExAtPath(getSearchExAtPath(searchEx, path).castTo(op), searchEx, path).toLisp();
    },
    setFormation(state, {path, formation}) {
      const searchEx = SearchEx.fromLisp(state.lisp);
      getSearchExAtPath(searchEx, path).formation = formation; // destructive!
      state.lisp = searchEx.toLisp();
    }
  }
});

function getSearchExAtPath(rootSearchEx, path) {
  return path.reduce((searchEx, subExIndex) => searchEx.subexpressions[subExIndex], rootSearchEx);
}

// modifies substructure, AND you have to pay attention to the return value.
function setSearchExAtPath(valueSearchEx, rootSearchEx, path) {
  if (path.length) {
    let searchEx = rootSearchEx;
    for (let i=0; i<path.length-1; i++) {
      searchEx = searchEx.subexpressions[path[i]];
    }
    searchEx.subexpressions[path[path.length-1]] = valueSearchEx;
    return rootSearchEx;
  } else {
    return valueSearchEx;
  }
}

document.addEventListener('DOMContentLoaded', () => {
  var search = new Vue({
    el: '#search-app',
    store,
    data: {},
    template: `<div><SearchExEditor v-bind:lisp="$store.state.lisp" v-bind:path="[]" /><hr><p>state: {{$store.state.lisp}}</p></div>`,
    components: {
      SearchExEditor
    },
    methods: {
      // wrap() {this.$store.commit('wrap', {name: 'wrap'});}
    }
  });
});
