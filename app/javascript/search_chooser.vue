<template>
  <div>chooser</div>
</template>
<script>

import LibFigure from 'libfigure/libfigure.js';

export default {
  name: 'SearchChooser',
  props: {
  },
  data: function() {
    return {};
  },
  computed: {
  },
  methods: {
  },
  components: {
  }
}







// chooserSelect('chooser_beats', ['*',8,16,0,1,2,3,4,6,8,10,12,14,16,20,24,32,48,64]);

// chooserRadioButtons('chooser_boolean', ['*',[true, 'yes'], [false, 'no']]);


// { // dancer chooser menus
// var dcs = dancerChooserNames();
// for (var i=0; i < dcs.length; i++) {
// var substituter = function(dancers) { return [dancers, dancerMenuLabel(dancers, dialect)]; };
// chooserSelect(dcs[i], ['*'].concat(dancerCategoryMenuForChooser(chooser(dcs[i])).map(substituter)));
// }
// }

// chooserRadioButtons('chooser_spin', ['*',[true, 'clockwise'], [false, 'ccw']]);
// chooserRadioButtons('chooser_left_right_spin', ['*',[true, 'left'], [false, 'right']]);
// chooserRadioButtons('chooser_right_left_hand', ['*',[false, 'left'], [true, 'right']]);
// chooserRadioButtons('chooser_right_left_shoulder', ['*',[false, 'left'], [true, 'right']]);

// // 'chooser_text'

// // Below splicing ugliness is because we take values from JSLibFigure varaible 'wristGrips' rather than
// // just saying what we mean. At time of writing the following two lines are equivalent.
// // chooserSelect('chooser_star_grip', ['*',['', 'unspecified'],'wrist grip','hands across']);
// chooserSelect('chooser_star_grip', ['*'].concat(wristGrips.map(function(grip) { return (grip === '') ? ['', 'unspecified'] : grip; })));

// chooserSelect('chooser_march_facing', ['*','forward','backward','forward then backward']);

// chooserRadioButtons('chooser_slide', ['*',[true, 'left'], [false, 'right']]);
// chooserSelect('chooser_set_direction', ['*',['along', 'along the set'], ['across', 'across the set'], 'right diagonal', 'left diagonal']);
// chooserSelect('chooser_set_direction_acrossish', ['*', ['across', 'across the set'], 'right diagonal', 'left diagonal']);
// chooserSelect('chooser_set_direction_grid', ['*',['along', 'along the set'], ['across', 'across the set']]);
// chooserSelect('chooser_set_direction_figure_8', ['*','','above','below','across']);

// chooserSelect('chooser_gate_direction', ['*',['up', 'up the set'], ['down', 'down the set'], ['in', 'into the set'], ['out', 'out of the set']]);
// chooserSelect('chooser_slice_return', ['*', ['straight', 'straight back'], ['diagonal', 'diagonal back'], 'none']);
// chooserRadioButtons('chooser_slice_increment', ['*', 'couple', 'dancer']);

// chooserSelect('chooser_all_or_center_or_outsides', ['*', 'all', 'center', 'outsides']);

// chooserSelect('chooser_down_the_hall_ender',
// ['*',
// ['turn-alone', 'turn alone'],
// ['turn-couple', 'turn as a couple'],
// ['circle', 'bend into a ring'],
// ['cozy', 'form a cozy line'],
// ['cloverleaf', 'bend into a cloverleaf'],
// ['thread-needle', 'thread the needle'],
// ['right-high', 'right hand high, left hand low'],
// ['sliding-doors', 'sliding doors'],
// ['', 'unspecified']]);

// chooserSelect('chooser_zig_zag_ender', ['*', ['', 'none'], ['ring', 'into a ring'], ['allemande', 'training two catch hands']]);

// chooserRadioButtons('chooser_go_back', ['*', [true, 'forward &amp; back'], [false, 'forward']]);
// chooserRadioButtons('chooser_give', ['*', [true,'give &amp; take'], [false,'take']]);
// chooserRadioButtons('chooser_half_or_full', ['*', [0.5,'half'], [1.0,'full']]);

// chooserSelect('chooser_hey_length',
// ['*',
// 'full',
// 'half',
// 'less than half',
// 'between half and full']);

// chooserSelect('chooser_swing_prefix', ['*', 'none', 'balance', 'meltdown']);
// // or on screens >= 768:
// // chooserRadioButtons('chooser_swing_prefix', ['*', 'none', 'balance', 'meltdown'], 'inline');


</script>
