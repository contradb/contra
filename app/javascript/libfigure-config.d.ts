declare interface Dialect {
  moves: any
  dancers: any
}

declare type ChooserName =
  | "chooser_boolean"
  | "chooser_beats"
  | "chooser_spin"
  | "chooser_left_right_spin"
  | "chooser_right_left_hand"
  | "chooser_right_left_shoulder"
  | "chooser_revolutions"
  | "chooser_places"
  | "chooser_text"
  | "chooser_star_grip"
  | "chooser_march_facing"
  | "chooser_slide"
  | "chooser_set_direction"
  | "chooser_set_direction_acrossish"
  | "chooser_set_direction_grid"
  | "chooser_set_direction_figure_8"
  | "chooser_gate_direction"
  | "chooser_slice_return"
  | "chooser_slice_increment"
  | "chooser_down_the_hall_ender"
  | "chooser_all_or_center_or_outsides"
  | "chooser_zig_zag_ender"
  | "chooser_go_back"
  | "chooser_give"
  | "chooser_half_or_full"
  | "chooser_swing_prefix"
  | "chooser_hey_length"
  | "chooser_dancers"
  | "chooser_pair"
  | "chooser_pair_or_everyone"
  | "chooser_pairc_or_everyone"
  | "chooser_pairz"
  | "chooser_pairz_or_unspecified"
  | "chooser_pairs"
  | "chooser_pairs_or_ones_or_twos"
  | "chooser_pairs_or_everyone"
  | "chooser_dancer"
  | "chooser_role"
  | "chooser_hetero"

declare type Chooser = { name: ChooserName }

declare function chooser(chooserName: ChooserName): chooser

declare module "*"
