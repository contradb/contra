<template>
  <div>
    <select v-if='chooserSelectOptions()' v-model='value' class='form-control chooser-argument'>
      <option v-for="option in chooserSelectOptions()" :value="Array.isArray(option) ? option[0] : option">
        {{Array.isArray(option) ? option[1] : option}}
      </option>
    </select>
    <div v-if='chooserRadioOptions()' class='chooser-argument'>
      <label v-for="option in chooserRadioOptions()" class='radio-inline'>
        <input type="radio" :name="uniqueName" v-model='value' :value="Array.isArray(option) ? option[0] : option">
        {{Array.isArray(option) ? option[1] : option}}
      </label>
    </div>
    <div v-if="chooserName === 'chooser_text'">
      <input v-model='value' class="form-control chooser-argument" type="string" placeholder="words...">
    </div>
  </div>
</template>
<script>

import LibFigure from 'libfigure/libfigure.js';

export default {
  name: 'SearchChooser',
  props: {
    formalParameter: {
      type: Object,
      required: true
    },
    path: {
      type: Array,
      required: true
    },
    parameterIndex: {
      type: Number,
      required: true
    },
    lisp: {
      type: Array,
      required: true
    },
  },
  data: function() {
    return {
    };
  },
  computed: {
    value: {
      get: function() {
        return this.lisp[this.parameterIndex+2]; // knows an awful lot about lisp format. :(
      },
      set: function(value) {
        this.$store.commit('setParameter', {path: this.path, index: this.parameterIndex, value: value});
      }
    },
    move: function() {return this.lisp[1];},
    chooserName: function() {return this.formalParameter.ui.name;},
    uniqueName: function() {return 'cb-' + this.path.join('-') + '-' + this.parameterIndex;}, // assumes only 1 of these per page
  },
  methods: {
    chooserSelectOptions: function() {
      if (this.chooserName === 'chooser_revolutions' || this.chooserName === 'chooser_places')
        return ['*',...LibFigure.anglesForMove(this.move).map(angle => [angle.toString(), LibFigure.degreesToWords(angle, this.move)])]
      else
        return this.$store.getters.selectChooserNameOptions[this.chooserName];
    },
    chooserRadioOptions: function() {
      return this.$store.state.radioChooserNameOptions[this.chooserName];
    },
  }
}
</script>
