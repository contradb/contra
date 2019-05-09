<template>
  <div>
    <select v-if='chooserSelectOptions()' class='form-control chooser-argument'>
      <option v-for="option in chooserSelectOptions()" :value="Array.isArray(option) ? option[0] : option">
        {{Array.isArray(option) ? option[1] : option}}
      </option>
    </select>
    <div v-if='chooserRadioOptions()' class='chooser-argument'>
      <label v-for="option in chooserRadioOptions()" class='radio-inline'>
        <input type="radio" :name="uniqueName" :value="Array.isArray(option) ? option[0] : option">
        {{Array.isArray(option) ? option[1] : option}}
      </label>
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
    move: {
      type: String,
      required: true
    }
  },
  data: function() {
    return {
    };
  },
  computed: {
    chooser: function() {return this.formalParameter.ui;},
    chooserName: function() {return this.formalParameter.ui.name;},
    uniqueName: function() {return 'cb-' + this.path.join('-') + '-' + this.parameterIndex;},
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
  },
  components: {
  }
}
</script>
