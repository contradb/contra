// Run this example by adding <%= javascript_pack_tag 'tree' %> (and
// <%= stylesheet_pack_tag 'tree' %> if you have styles in your component)
// to the head of your layout file,
// like app/views/layouts/application.html.erb.

import Vue from 'vue/dist/vue.esm';
import Vuex from 'vuex/dist/vuex.esm';
import { SearchEx } from '../search_ex.js';
import LibFigure from '../libfigure/libfigure.js';
import SearchExEditor from '../search_ex_editor.vue';

Vue.use(Vuex);

function selectChooserNameOptions(dialect) {
  return {
    chooser_beats: ['*',8,16,0,1,2,3,4,6,8,10,12,14,16,20,24,32,48,64],
    chooser_boolean: ['*',[true, 'yes'], [false, 'no']],
    chooser_star_grip: ['*'].concat(wristGrips.map(function(grip) { return (grip === '') ? ['', 'unspecified'] : grip; })),
    chooser_march_facing: ['*','forward','backward','forward then backward'],
    chooser_set_direction: ['*',['along', 'along the set'], ['across', 'across the set'], 'right diagonal', 'left diagonal'],
    chooser_set_direction_acrossish: ['*', ['across', 'across the set'], 'right diagonal', 'left diagonal'],
    chooser_set_direction_grid: ['*',['along', 'along the set'], ['across', 'across the set']],
    chooser_set_direction_figure_8: ['*','','above','below','across'],
    chooser_gate_direction: ['*',['up', 'up the set'], ['down', 'down the set'], ['in', 'into the set'], ['out', 'out of the set']],
    chooser_slice_return: ['*', ['straight', 'straight back'], ['diagonal', 'diagonal back'], 'none'],
    chooser_all_or_center_or_outsides: ['*', 'all', 'center', 'outsides'],
    chooser_down_the_hall_ender: ['*',
                                  ['turn-alone', 'turn alone'],
                                  ['turn-couple', 'turn as a couple'],
                                  ['circle', 'bend into a ring'],
                                  ['cozy', 'form a cozy line'],
                                  ['cloverleaf', 'bend into a cloverleaf'],
                                  ['thread-needle', 'thread the needle'],
                                  ['right-high', 'right hand high, left hand low'],
                                  ['sliding-doors', 'sliding doors'],
                                  ['', 'unspecified']],
    chooser_zig_zag_ender: ['*', ['', 'none'], ['ring', 'into a ring'], ['allemande', 'training two catch hands']],
    chooser_hey_length: ['*',
                         'full',
                         'half',
                         'less than half',
                         'between half and full'],
    chooser_swing_prefix: ['*', 'none', 'balance', 'meltdown'],
    ...LibFigure.dancerChooserNames().reduce(
      (acc, chooserName) => {
        acc[chooserName] =
          ['*'].concat(LibFigure.dancerMenuForChooser(LibFigure.chooser(chooserName)).map(dancers => [dancers, LibFigure.dancerMenuLabel(dancers, dialect)]));
        return acc;
      },
      {}
    )
  };
}

const radioChooserNameOptions = {
  chooser_boolean: ['*',[true, 'yes'], [false, 'no']],
  chooser_spin: ['*',[true, 'clockwise'], [false, 'ccw']],
  chooser_left_right_spin: ['*',[true, 'left'], [false, 'right']],
  chooser_right_left_hand: ['*',[false, 'left'], [true, 'right']],
  chooser_right_left_shoulder: ['*',[false, 'left'], [true, 'right']],
  chooser_slide: ['*',[true, 'left'], [false, 'right']],
  chooser_slice_increment: ['*', 'couple', 'dancer'],
  chooser_go_back: ['*', [true, 'forward &amp; back'], [false, 'forward']],
  chooser_give: ['*', [true,'give &amp; take'], [false,'take']],
  chooser_half_or_full: ['*', [0.5,'half'], [1.0,'full']],
};

const store = new Vuex.Store({
  state: {
    lisp: ['and', ['figure', '*'], ['progression']],
    dialect: LibFigure.defaultDialect,
    radioChooserNameOptions: Object.freeze(radioChooserNameOptions),
  },
  getters: {
    searchEx: state => SearchEx.fromLisp(state.lisp),
    selectChooserNameOptions: state => selectChooserNameOptions(state.dialect),
  },
  mutations:
  // here's what a mutation looked like before it was made generic with the reduce:
  // setFormation(state, {path, formation}) {
  //   const searchEx = SearchEx.fromLisp(state.lisp);
  //   getSearchExAtPath(searchEx, path).formation = formation; // destructive!
  //   state.lisp = searchEx.toLisp();
  // }
  SearchEx.allProps().reduce((hash, prop) => {
    if (prop !== 'op') {
      hash[SearchEx.mutationNameForProp(prop)] = function(state, payload) {
        const searchEx = SearchEx.fromLisp(state.lisp); // wish had getter access
        getSearchExAtPath(searchEx, payload.path)[prop] = payload[prop]; // destructive!
        state.lisp = searchEx.toLisp();
      };
    }
    return hash;
  }, {
    setOp(state, {path, op}) {
      const searchEx = SearchEx.fromLisp(state.lisp); // wish had getter access
      state.lisp = setSearchExAtPath(getSearchExAtPath(searchEx, path).castTo(op), searchEx, path).toLisp();
    },
    setParameter(state, {path, index, value}) {
      const rootSearchEx = SearchEx.fromLisp(state.lisp); // wish had getter access
      let searchEx = getSearchExAtPath(rootSearchEx, path);
      console.log('setParameter', searchEx, index, searchEx.subexpressions, value);
      searchEx.parameters[index] = value; // destructive!
      state.lisp = setSearchExAtPath(searchEx, rootSearchEx, path).toLisp();
    }
  }
  )
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
    template: `<div><SearchExEditor v-bind:lisp="$store.state.lisp" v-bind:path="[]" /><hr><p>state.lisp: {{$store.state.lisp}}</p><p>state.dialect: {{$store.state.dialect}}</p></div>`,
    components: {
      SearchExEditor
    },
    methods: {
      // wrap() {this.$store.commit('wrap', {name: 'wrap'});}
    }
  });
});

////////////////////////////////////////////////////////////////
// init

$(() => store.state.dialect = JSON.parse($('#dialect-json').text()));
/////////////////////////////////////////////////////////////////
// stuff ripped from welcome.js

$(document).ready(function() {
  if (0 === $('#dances-table-vue').length) {
    return;                     // don't do any of this stuff if we're not on a page with a query.
  }

  ////////////////////// VIS TOGGLES
  // For each column in the datatable, add a corresponding button that
  // changes color and toggles column visibility when clicked.

  // duplicated code in welcome.js
  function insertVisToggles(dataTable) {
    var visToggles = $('.table-column-vis-toggles');
    visToggles.empty();
    $('#dances-table-vue thead th').each(function(index) {
      var link = $("<button class='toggle-vis toggle-vis-active btn btn-xs' href='javascript:void(0)'>"+$(this).text()+"</button>");
      link.click(function () {
        var column = dataTable.column(index);
        var activate = !column.visible();
        column.visible(activate);
        if (activate) {
          link.addClass('toggle-vis-active');
          link.removeClass('toggle-vis-inactive');
        } else {
          link.addClass('toggle-vis-inactive');
          link.removeClass('toggle-vis-active');
        }
      });
      visToggles.append(link);
    });
  }

  // duplicated code in welcome.js
  var tinyScreenColumns = ['Title', 'Choreographer'];
  var narrowScreenColumns = tinyScreenColumns.concat(['Hook']);
  var wideScreenColumns = narrowScreenColumns.concat(['Formation', 'User', 'Entered']);
  var recentlySeenColumns = null;

  // duplicated code in welcome.js
  function toggleColumnVisForResolution(dataTable, width) {
    var screenColumns = (width < 400) ? tinyScreenColumns : ((width < 768) ? narrowScreenColumns : wideScreenColumns);
    if (recentlySeenColumns === screenColumns) { return; }
    recentlySeenColumns = screenColumns;
    $('.table-column-vis-toggles button').each(function(index) {
      var $this = $(this);
      var text = $this.text();
      if (0 <= screenColumns.indexOf(text)) {
        dataTable.column(index).visible(true);
        $this.removeClass('toggle-vis-inactive');
        $this.addClass('toggle-vis-active');
      } else {
        dataTable.column(index).visible(false);
        $this.addClass('toggle-vis-inactive');
        $this.removeClass('toggle-vis-active');
      }
    });
  }

  function updateQuery() {
    // $('.figure-query-sentence').text(buildFigureSentence(lisp, dialect));
    if (dataTable) {
      dataTable.draw();
    }
  };

  store.watch(state => state.lisp, updateQuery, {deep: true});


  // duplicated code in welcome.js
  // oh, I can't use arrays in params? Fine, I'll create hashes with indexes as keys
  function arrayToIntHash (a) {
    if (Array.isArray(a)) {
      var o = { faux_array: true };
      for (var i=0; i<a.length; i++) {
        o[i] = arrayToIntHash(a[i]);
      }
      return o;
    } else {
      return a;
    }
  }

  // duplicated code in welcome.js
  var dataTable =
        $('#dances-table-vue').DataTable({
          "processing": true,
          "serverSide": true,
          "ajax": {
            url: $('#dances-table-vue').data('source'),
            type: 'POST',
            data: function(d) {
              // d.figureQuery = arrayToIntHash(['and', ['no', ['figure', 'gyre']], ['then', ['figure', 'roll away'], ['figure', 'swing']]]);
              d.figureQuery = arrayToIntHash(store.state.lisp);
            }
          },
          "pagingType": "full_numbers",
          "dom": 'f<"table-column-vis-wrap"<"table-column-vis-toggles">>t<"row"<"col-sm-6 col-md-3"i><"col-sm-6 col-md-3"l>>pr',
          language: {
            searchPlaceholder: "filter by title, choreographer, and user"
          },
          "columns": [          // mapped, in order, to <th> ordering in the html.erb
            {"data": "title"},
            {"data": "choreographer_name"},
            {"data": "hook"},
            {"data": "formation"},
            {"data": "user_name"},
            {"data": "created_at"},
            {"data": "updated_at"},
            {"data": "published"},
            {"data": "figures"}
          ],
          "order": [[ 5, "desc" ]] // 5 should = index of 'created_at' in the array above
        });

  // duplicated code in welcome.js
  if (0===$('.table-column-vis-wrap label').length) {
    $('.table-column-vis-wrap').prepend($('<label>Show columns </label>'));
  }
  insertVisToggles(dataTable);
  // This pasted code doesn't work here - TODO
  var resizeFn = function () {
    toggleColumnVisForResolution(dataTable, $(window).width());
  };
  $(window).resize(resizeFn);
  resizeFn();
});
